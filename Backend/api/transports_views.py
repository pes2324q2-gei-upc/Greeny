# Third-party imports
import requests
from django.views import View
from django.conf import settings
from django.contrib.gis.db.models.functions import Distance
from django.contrib.gis.geos import Point
from django.contrib.gis.geos import Polygon
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny

from tqdm import tqdm
from fuzzywuzzy import fuzz

# Local application/library specific imports
from .models import (PublicTransportStation, Stop, BusStation,
                     Station, ChargingStation, TransportType, BicingStation, FavoriteStation)
from .serializers import (PublicTransportStationSerializer, BusStationSerializer,
                          BicingStationSerializer, ChargingStationSerializer,
                          PublicTransportStationSimpleSerializer, StationSimpleSerializer)
from .line_station_utils import LineStationUtils

#from .data.neighborhood_data import lines

headers_OD = {"X-App-Token": settings.APP_ID}
headers_AJT = {"Authorization": settings.API_TOKEN_AJT, "Accept": "application/json"}


#GET estacions Transport Public Barcelona (METRO, TRAM, FGC, RENFE)
class FetchPublicTransportStations(View):
    def get_type(self, transport_type):
        try:
            trans_type = TransportType.objects.get(type=transport_type)
        except TransportType.DoesNotExist:
            trans_type = TransportType.objects.create(type=transport_type)
        return trans_type

    def create_public_transport_station(self, item, station_name):
        new_station_tp = PublicTransportStation.objects.create(
            name=station_name,
            location=Point(float(item.get('LONGITUD')), float(item.get('LATITUD'))),
        )

        return new_station_tp

    def get_public_transport_station(self, station_name):
        try:
            station = PublicTransportStation.objects.get(name__iexact=station_name)
        except PublicTransportStation.DoesNotExist:
            station = None
        return station

    def fetch_buses(self):
        # Fetch Buses
        response = requests.get(url=(settings.BASE_URL_AJT +
                                     "2d190658-93ac-4c43-a23f-c5d313b1ae9c"
                                     + "&limit=3226"),
                                timeout=5)

        data = response.json().get("result").get("records")

        for bus in data:
            if "Estació" in bus.get("EQUIPAMENT"):
                continue
            lines_bus = bus.get("EQUIPAMENT").split(" -")[1].replace("--", "").split("-")
            loc = Point(float(bus.get("LONGITUD")), float(bus.get("LATITUD")))
            try:
                stat = Station.objects.get(location=loc)
            except Station.DoesNotExist:
                stat = None

            if stat is None:
                BusStation.objects.create(
                    name="BUS " + str(bus.get("_id")) + " (" + bus.get("NOM_BARRI") + ")",
                    location=loc,
                    lines=lines_bus
                )
            else:
                bus_station = BusStation.objects.get(station_ptr_id=stat.id)
                bus_station.lines = bus_station.lines + lines_bus
                bus_station.save()

    def fetch_charging_stations(self):
        # Fetch Charging Stations
        response = requests.get(url=(settings.BASE_URL_OD
                                     + "tb2m-m33b.json?"
                                     + "$limit=1000"),
                                headers=headers_OD,
                                timeout=5)
        data = response.json()

        for point in data:
            ChargingStation.objects.create(
                name=point.get("designaci_descriptiva"),
                location=Point(float(point.get("longitud")), float(point.get("latitud"))),
                acces=point.get("acces"),
                charging_velocity=point.get("tipus_velocitat"),
                power=point.get("kw"),
                current_type=point.get("ac_dc"),
                connexion_type=point.get("tipus_connexi")
            )

    def fetch_bicing(self):
        # Fetch Bicing

        response = requests.get(url=settings.URL_BICING, headers=headers_AJT, timeout=5)
        response.raise_for_status()
        data = response.json().get("data").get("stations")

        for stop in data:
            BicingStation.objects.create(
                name=stop.get("name"),
                location=Point(float(stop.get("lon")), float(stop.get("lat"))),
                capacitat=stop.get("capacity")
            )

    def fetch_public_stations(self):
        response = requests.get(url=(settings.BASE_URL_AJT
                                     + settings.ID_ESTACIONS_TRANSPORT
                                     + "&limit=700"),
                                timeout=10)
        data = response.json()

        stations = data.get("result").get("records")

        for item in tqdm(stations, desc="Fetching stations"):
            full_name = item.get("EQUIPAMENT")
            if "METRO" in full_name:
                self.process_metro(item, full_name)
            elif "TRAM" in full_name:
                self.process_tram(item, full_name)
            elif "RENFE" in full_name:
                self.process_renfe(item, full_name)
            elif "FGC" in full_name:
                self.process_fgc(item, full_name)

    def process_metro(self, item, full_name):
        station_name = full_name.split(" - ")[1].replace("-", "")
        line = [full_name.split("(")[1].split(")")[0]]

        #Miramos si existe el tipo Metro, sino creamos la instancia
        trans_type = self.get_type(TransportType.TTransport.METRO)

        #Buscamos por nombre por si ya existe la parada
        station = self.get_public_transport_station(station_name)

        if station is None:  #Si no existe estacionTPublic la creamos

            new_station_tp = self.create_public_transport_station(item, station_name)

            #Creamos la parada asociada a la estacion
            Stop.objects.create(
                station=new_station_tp,
                transport_type=trans_type,
                lines=line
            )

        else:  #Si existe la parada, actualizamos las lineas del Metro Asociado
            try:
                stop = Stop.objects.get(station=station, transport_type=trans_type)
                stop.lines = stop.lines + line
                stop.save()
            except Stop.DoesNotExist:
                Stop.objects.create(station=station, transport_type=trans_type, lines=line)

    def process_tram(self, item, full_name):
        station_name = full_name.split(" - ")[1].replace("-", "")
        stop_lines = (full_name.split(" - ")[0].replace(" ", "")
                      .split("(")[1].replace(")", "").split(","))

        if station_name == "Mª CRISTINA":
            station_name = "MARIA CRISTINA"
        elif station_name == "TORREBLANCA":
            stop_lines = [full_name.split(" - ")[0].split(" ")[2].replace(")", "")]

        #Buscamos si existe la estacion; sino la creamos
        station = self.get_public_transport_station(station_name)

        trans_type = self.get_type(TransportType.TTransport.TRAM)

        if station is None:
            station = self.create_public_transport_station(item, station_name)

        #creamos parada asociada
        Stop.objects.create(station=station, transport_type=trans_type, lines=stop_lines)

    def process_renfe(self, item, full_name):
        if "(RENFE)" in full_name:
            station_name = full_name.split(" (")[0]
        else:
            try:
                station_name = full_name.split(" - ")[1].replace("-", "")
            except IndexError:
                return None

        station = self.get_public_transport_station(station_name)
        trans_type = self.get_type(TransportType.TTransport.RENFE)

        if station is None:
            station = self.create_public_transport_station(item, station_name)

        Stop.objects.get_or_create(station=station,
                                   transport_type=trans_type,
                                   defaults={'lines': []})
        return None

    def process_fgc(self, item, full_name):
        if "/ FGC" in full_name:
            station_name = "DIAGONAL"
        elif "- FGC-" in full_name:
            station_name = full_name.split(" - ")[0]
        else:
            station_name = full_name.split(" - ")[1][:-1]
            if '(' in station_name:
                station_name = station_name.split(" (")[0]

        station_name = station_name.replace('<center>', '')

        station = self.get_public_transport_station(station_name)
        trans_type = self.get_type(TransportType.TTransport.FGC)

        if station is None:
            station = self.create_public_transport_station(item, station_name)

        Stop.objects.get_or_create(station=station,
                                   transport_type=trans_type,
                                   defaults={'lines': []})

    def is_similar(self, name1, name2):
        threshold = 75
        similarity = fuzz.ratio(name1.lower(), name2.lower())
        return similarity > threshold

    def get_transport_lines(self):

        stops = Stop.objects.all()

        lsu = LineStationUtils()
        lines = lsu.lines_stations  # diccionario {'linia' : ['estaciones']}

        for stop in tqdm(stops, desc="Assigning the lines to each stop..."):
            if stop.transport_type.type in ['FGC', 'RENFE']:
                for line, stations in lines.items():
                    if any(self.is_similar(stop.station.name, station) for station in stations):
                        if stop.transport_type.type == "FGC" and line[0] != 'R':
                            stop.lines = stop.lines + [line]
                            stop.save()
                        elif stop.transport_type.type == "RENFE" and line[0] not in ['S', 'L']:
                            stop.lines = stop.lines + [line]
                            stop.save()
    def get(self, request):

        self.fetch_public_stations()
        self.fetch_buses()
        self.fetch_bicing()
        self.fetch_charging_stations()

        return Response({"status": "fetched_successfully"}, status.HTTP_200_OK)


class StationsView(APIView):
    def get_station(self, pk, station_type):
        try:
            station = station_type.objects.get(pk=pk)
            return station
        except station_type.DoesNotExist:
            return None

    def get_viewport(self, request):
        margin = 0.01

        min_lng = request.GET.get('min_lng')
        min_lat = request.GET.get('min_lat')
        max_lng = request.GET.get('max_lng')
        max_lat = request.GET.get('max_lat')

        if min_lng and min_lat and max_lng and max_lat:
            min_lng = float(min_lng) - margin
            min_lat = float(min_lat) - margin
            max_lng = float(max_lng) + margin
            max_lat = float(max_lat) + margin
            return Polygon.from_bbox((min_lng, min_lat, max_lng, max_lat))

        return Polygon.from_bbox((-180, -90, 180, 90))

    def get_all_stations(self, request):
        viewport = self.get_viewport(request)

        data = {}

        queryset_pt = PublicTransportStation.objects.filter(location__within=viewport)
        serializer_pt = PublicTransportStationSimpleSerializer(queryset_pt, many=True)
        data['publicTransportStations'] = serializer_pt.data

        queryset_bus = BusStation.objects.filter(location__within=viewport)
        serializer_bus = StationSimpleSerializer(queryset_bus, many=True)
        data['busStations'] = serializer_bus.data

        queryset_bicing = BicingStation.objects.filter(location__within=viewport)
        serializer_bicing = StationSimpleSerializer(queryset_bicing, many=True)
        data['bicingStations'] = serializer_bicing.data

        queryset_charging = ChargingStation.objects.filter(location__within=viewport)
        serializer_charging = StationSimpleSerializer(queryset_charging, many=True)
        data['chargingStations'] = serializer_charging.data

        return data

    def get(self, request, pk=None):
        if pk:
            station = self.get_station(pk, PublicTransportStation)
            if station:
                serializer = PublicTransportStationSerializer(station)
                return Response(serializer.data)

            station = self.get_station(pk, BusStation)
            if station:
                serializer = BusStationSerializer(station)
                return Response(serializer.data)

            station = self.get_station(pk, BicingStation)
            if station:
                serializer = BicingStationSerializer(station)
                return Response(serializer.data)

            station = self.get_station(pk, ChargingStation)
            if station:
                serializer = ChargingStationSerializer(station)
                return Response(serializer.data)

            r = Response(status=status.HTTP_404_NOT_FOUND)
        else:
            data = self.get_all_stations(request)
            r = Response({'stations': data})
        return r

    def post(self, request, pk=None):
        if pk:
            stat = Station.objects.get(pk=pk)
            favorite_station, created = FavoriteStation.objects.get_or_create(
                user=request.user,
                station=stat)
            if not created:
                favorite_station.delete()

            return Response(status=status.HTTP_200_OK)
        return Response(status=status.HTTP_400_BAD_REQUEST)


class ThirdPartyChargingStationInfoView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        return Response(status=status.HTTP_403_FORBIDDEN)

    def post(self, request, *args, **kwargs):
        lat = request.data['lat']
        longi = request.data['long']
        e = request.data['exact']
        user_location = Point(float(longi), float(lat), srid=4326)

        if not e == 'true':
            try:
                # Get the nearest station within a certain radius
                charging_station = Station.objects.annotate(
                    distance=Distance('location', user_location)).order_by('distance').first()

                if charging_station is None:
                    raise Station.DoesNotExist

                favs = FavoriteStation.objects.filter(station_id=charging_station.id).count()

                return Response({"data": {
                    "name": charging_station.name,
                    "faved_by": favs
                }}, status=status.HTTP_200_OK)

            except Station.DoesNotExist:
                return Response({"error": "Charging station not found within the specified radius"},
                                status=status.HTTP_404_NOT_FOUND)

        else:

            try:
                charging_station = Station.objects.get(location=user_location)

                favs = FavoriteStation.objects.filter(station_id=charging_station.id).count()

                return Response({"data": {
                    "name": charging_station.name,
                    "faved_by": favs
                }}, status=status.HTTP_200_OK)

            except ChargingStation.DoesNotExist:
                return Response({"error": "Charging station not found in provided coordinates"},
                                status=status.HTTP_404_NOT_FOUND)

    def put(self, request, *args, **kwargs):
        return Response(status=status.HTTP_403_FORBIDDEN)

    def delete(self, request, *args, **kwargs):
        return Response(status=status.HTTP_403_FORBIDDEN)
