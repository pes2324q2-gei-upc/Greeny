import requests
from django.shortcuts import render, redirect
from django.http import JsonResponse
from django.views import View
from rest_framework import generics
from pathlib import Path
#from .serializers import MetroSerializer
import os

from .models import *
from .serializers import *

BASE_URL_OD = "https://analisi.transparenciacatalunya.cat/resource/"
headers_OD = {"X-App-Token" : os.environ.get('APP_ID')}

BASE_URL_AJT = "https://opendata-ajuntament.barcelona.cat/data/api/action/datastore_search?resource_id="
ID_ESTACIONS_TRANSPORT = "e07dec0d-4aeb-40f3-b987-e1f35e088ce2"
headers_AJT = {"Authorization" : os.environ.get('API_TOKEN_AJT'), "Accept" : "application/json"}
# Create your views here.

#GET carregadors electrics
class CarregadorsElectricsView(View):
    def get(self, request):
        response = requests.get(url=(BASE_URL_OD + "tb2m-m33b.json?" + "$limit=1000"), headers=headers_OD);
        data = response.json()

        for point in data:
            ChargingStation.objects.create(
                name = point.get("designaci_descriptiva"),
                latitude = point.get("latitud"),
                longitude = point.get("longitud"),
                acces = point.get("acces"),
                charging_velocity = point.get("tipus_velocitat"),
                power = point.get("kw"),
                current_type = point.get("ac_dc"),
                connexion_type = point.get("tipus_connexi")
            )
        data = {"status" : "fetched_successfully"}
        return JsonResponse(data, safe=False)
    
# #GET estacions Transport Public Barcelona (METRO, TRAM, FGC, RENFE)
class FetchPublicTransportStations(View):
    def getType(self, type):
        try:
            trans_type = TransportType.objects.get(type=type)
        except TransportType.DoesNotExist:
            trans_type = TransportType.objects.create(type=type)
        return trans_type
            
    def createPublicTransportStation(self, item, station_name):
        new_station_tp = PublicTransportStation.objects.create(
                        name = station_name,
                        latitude = item.get('LATITUD'),
                        longitude = item.get('LONGITUD'),
                    )
        
        return new_station_tp

    def getPublicTransportStation(self, station_name):
        try:
            station = PublicTransportStation.objects.get(name__iexact=station_name)
        except PublicTransportStation.DoesNotExist:
            station = None
        return station

    def get(self, request):
        response = requests.get(url=(BASE_URL_AJT + ID_ESTACIONS_TRANSPORT + "&limit=700"));
        data = response.json()

        stations = data.get("result").get("records")

        for item in stations:
            full_name = item.get("EQUIPAMENT")
            #Metro: ej METRO (L1) - CATALUNYA
            if "METRO" in full_name:
                station_name = full_name.split(" - ")[1].replace("-","");
                line = [full_name.split("(")[1].split(")")[0]];


                #Miramos si existe el tipo Metro, sino creamos la instancia
                trans_type = self.getType(TransportType.TTransport.METRO)

                #Buscamos por nombre por si ya existe la parada
                station = self.getPublicTransportStation(station_name)
                
                if station is None:                     #Si no existe estacionTPublic la creamos
                    
                    new_station_tp = self.createPublicTransportStation(item, station_name)

                    #Creamos la parada asociada a la estacion
                    Stop.objects.create(
                        station = new_station_tp,
                        transport_type = trans_type,
                        lines = line
                    )

                else:                                   #Si existe la parada, actualizamos las lineas del Metro Asociado     
                    
                    try:
                        stop = Stop.objects.get(station=station, transport_type=trans_type)
                        stop.lines = stop.lines + line
                        stop.save()
                    except:
                        Stop.objects.create(station=station, transport_type=trans_type, lines=line)

            
            #Tramvia: ej TRAMVIA (T1,T2) - LES AIGÜES- 
            if "TRAM" in full_name:
                station_name = full_name.split(" - ")[1].replace("-","");
                stop_lines = full_name.split(" - ")[0].replace(" ", "").split("(")[1].replace(")", "").split(",")

                if station_name == "Mª CRISTINA":
                    station_name = "MARIA CRISTINA"
                elif station_name == "TORREBLANCA":
                    stop_lines = [full_name.split(" - ")[0].split(" ")[2].replace(")", "")]

                #Buscamos si existe la estacion; sino la creamos
                station = self.getPublicTransportStation(station_name)

                trans_type = self.getType(TransportType.TTransport.TRAM)

                if station is None:
                    station = self.createPublicTransportStation(item, station_name)

                #creamos parada asociada
                Stop.objects.create(station=station, transport_type=trans_type, lines=stop_lines)
            
            # RENFE: ej RENFE - CATALUNYA-
            elif "RENFE" in full_name:
                print(full_name)
                if "(RENFE)" in full_name:
                    station_name = full_name.split(" (")[0]
                else: 
                    try:   
                        station_name = full_name.split(" - ")[1].replace("-","");
                    except:
                        continue
                
                
                station = self.getPublicTransportStation(station_name)
                
                trans_type = self.getType(TransportType.TTransport.RENFE)
                
                if station is None:
                    station = self.createPublicTransportStation(item, station_name)
                
                try:
                    stop = Stop.objects.get(station=station, transport_type=trans_type)
                except:
                    Stop.objects.create(station=station, transport_type=trans_type, lines=[]) 
            
            #FGC ej: FGC - CATALUNYA (C. de Rossello)-
            #       FGC - L'HOSPITALET-AV.CARRILET-
            #       FGC - ESPANYA-
            elif "FGC" in full_name:

                if "/ FGC" in full_name:
                    station_name = "DIAGONAL"
                elif "- FGC-" in full_name:
                    station_name = full_name.split(" - ")[0]
                else :
                    station_name = full_name.split(" - ")[1][:-1]
                    if '(' in station_name:
                        station_name = station_name.split(" (")[0]

                print(station_name)

                station = self.getPublicTransportStation(station_name)
                
                trans_type = self.getType(TransportType.TTransport.FGC)
                
                if station is None:
                    station = self.createPublicTransportStation(item, station_name)
                
                try:
                    stop = Stop.objects.get(station=station, transport_type=trans_type)
                except:
                    Stop.objects.create(station=station, transport_type=trans_type, lines=[]) 

        return redirect('bus_stops')


# def getParadesMetro(request):
#     elements = Metro.objects.all();
#     serializer = MetroSerializer(elements, many=True)
#     return JsonResponse(serializer.data, safe=False)

class GetStations(generics.ListAPIView):
    def get(self, request):
        queryset = PublicTransportStation.objects.all()
        serializer = PublicTransportStationSerializer(queryset, many=True)
        return JsonResponse({'stations':serializer.data}, safe=False)

#GET parades de bus Barcelona
class ParadesBus(View):
    def get(self, request):
        response = requests.get(url=(BASE_URL_AJT + "2d190658-93ac-4c43-a23f-c5d313b1ae9c" + "&limit=3226"));
        data = response.json().get("result").get("records")

        for bus in data:
            if "Estació" in bus.get("EQUIPAMENT"):
                continue
            lines_bus = bus.get("EQUIPAMENT").split(" -")[1].replace("--", "").split("-")
            lat = bus.get("LATITUD")
            long = bus.get("LONGITUD")

            try:
                stat = Station.objects.get(latitude=lat, longitude=long)
            except Station.DoesNotExist:
                stat = None
            
            if stat is None:
                BusStation.objects.create(
                    name = "BUS " + str(bus.get("_id")) + " (" + bus.get("NOM_BARRI") + ")",
                    latitude = lat,
                    longitude = long,
                    lines = lines_bus
                )
            
            else:
                bus_station = BusStation.objects.get(station_ptr_id=stat.id)
                bus_station.lines = bus_station.lines + lines_bus
                bus_station.save()

        return redirect('bicing')

#GET estacions Bicing
class EstacionsBicing(View):
    def get(self, request):
        url = "https://opendata-ajuntament.barcelona.cat/data/dataset/informacio-estacions-bicing/resource/f60e9291-5aaa-417d-9b91-612a9de800aa/download/Informacio_Estacions_Bicing_securitzat.json"
        response = requests.get(url=url, headers=headers_AJT)
        response.raise_for_status()
        data = response.json().get("data").get("stations")

        for stop in data:
            BicingStation.objects.create(
                name = stop.get("name"),
                latitude = stop.get("lat"),
                longitude = stop.get("lon"),
                capacitat = stop.get("capacity")
            )

        return redirect('charging_points')