# pylint: disable=no-member
import requests
from django.shortcuts import render, redirect
from django.http import JsonResponse
from django.views import View
from rest_framework import generics
from pathlib import Path
import os
from ..models import *
from ..serializers import *
import json
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAdminUser
from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated
from rest_framework.exceptions import AuthenticationFailed
from rest_framework.decorators import permission_classes, api_view
from rest_framework.permissions import AllowAny

BASE_URL_OD = "https://analisi.transparenciacatalunya.cat/resource/"
headers_OD = {"X-App-Token" : os.environ.get('APP_ID')}

BASE_URL_AJT = "https://opendata-ajuntament.barcelona.cat/data/api/action/datastore_search?resource_id="
ID_ESTACIONS_TRANSPORT = "e07dec0d-4aeb-40f3-b987-e1f35e088ce2"
headers_AJT = {"Authorization" : os.environ.get('API_TOKEN_AJT'), "Accept" : "application/json"} 


@method_decorator(csrf_exempt, name='dispatch')
class FinalFormTransports(View):

    #POST final form
    def post(self, request):
        if request.method == 'POST':
            
            #This lines will be replaced by the user logged in
            '''try: 
                dummy_user = User.objects.get(username='dummy')
            except User.DoesNotExist:
                dummy_user = User.objects.create(username='dummy', email='dummy@example.com')
                dummy_user.set_password('dummy_password')
                dummy_user.save()'''

            # Authenticate the user
            token_auth = TokenAuthentication()
            try:
                user, token = token_auth.authenticate(request)
            except AuthenticationFailed:
                return JsonResponse({'error': 'Invalid token'}, status=401)

            data = json.loads(request.body)
            transports = data['selectedTransports']
            total_distance = data['totalDistance']
            
            update_fields = { 
                    'km_Walked': 0.0,
                    'km_Bus': 0.0,
                    'km_PublicTransport': 0.0,
                    'km_Biked': 0.0,
                    'km_Car': 0.0,
                    'km_Motorcycle': 0.0,
                    'km_ElectricCar': 0.0,
                    'km_Totals': 0.0,
                }
            
            if (len(transports) != 0):
                total_transports = len(transports)
                transport_modes = ['Walking', 'Bus', 'Train, Metro, Tram, FGC', 'Bike', 'Car', 'Motorcycle', 'Electric Car']
                
                percentage = 100 / total_transports / 100 
                km_mode = percentage * total_distance

                transport_percentages = {}
                for mode in transport_modes:
                    if mode in transports:
                        transport_percentages[mode] = km_mode
                    else:
                        transport_percentages[mode] = 0.0


                field_mapping = {
                    'Walking': 'km_Walked',
                    'Bus': 'km_Bus',
                    'Train, Metro, Tram, FGC': 'km_PublicTransport',
                    'Bike': 'km_Biked',
                    'Car': 'km_Car',
                    'Motorcycle': 'km_Motorcycle',
                    'Electric Car': 'km_ElectricCar'
                }
                
                
                for key, value in transport_percentages.items():
                    update_fields[field_mapping[key]] = value

                update_fields['km_Totals'] = total_distance
                
            try: 
                user_statics = Statistics.objects.get(username=user)
                for key, value in update_fields.items():
                    current_value = getattr(user_statics, key, 0)
                    setattr(user_statics, key, current_value + value)
                user_statics.save()
            except Statistics.DoesNotExist:
                user_statics = Statistics.objects.create(username=user, **update_fields)
                user_statics.save()
                
            return JsonResponse({'status': 'success'})

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

        data = {}

        queryset_pt = PublicTransportStation.objects.all()
        serializer_pt = PublicTransportStationSerializer(queryset_pt, many=True)
        data['publicTransportStations'] = serializer_pt.data

        queryset_bus = BusStation.objects.all()
        serializer_bus = BusStationSerializer(queryset_bus, many=True)
        data['busStations'] = serializer_bus.data

        queryset_bicing = BicingStation.objects.all()
        serializer_bicing = BicingStationSerializer(queryset_bicing, many=True)
        data['bicingStations'] = serializer_bicing.data

        queryset_charging = ChargingStation.objects.all()
        serializer_charging = ChargingStationSerializer(queryset_charging, many=True)
        data['chargingStations'] = serializer_charging.data

        return JsonResponse({'stations':data}, safe=False)

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

class TestView(View):
    def get(self, request):
        response = requests.get(url=(BASE_URL_AJT + ID_ESTACIONS_TRANSPORT + "&limit=700"));
        data = response.json()
        return JsonResponse(data, safe=False)

class StatsView(View):
    def get(self, request):
        
        #This lines will be replaced by the user logged in
        '''try: 
            dummy_user = User.objects.get(username=username)
        except User.DoesNotExist:
            dummy_user = User.objects.create(username=username, email='dummy@example.com')
            dummy_user.set_password('dummy_password')
            dummy_user.save()'''
        
        token_auth = TokenAuthentication()
        try:
            user, token = token_auth.authenticate(request)
        except AuthenticationFailed:
            return JsonResponse({'error': 'Invalid token'}, status=401)
        
        try:
            user_statistics = Statistics.objects.get(username=user)
        except Statistics.DoesNotExist:
            user_statistics = Statistics.objects.create(
                username=user,
                kg_CO2=0.0,
                km_Totals=0.0,
                km_Walked=0.0,
                km_Biked=0.0,
                km_ElectricCar=0.0,
                km_PublicTransport=0.0,
                km_Bus=0.0,
                km_Motorcycle=0.0,
                km_Car=0.0
            )
            user_statistics.save()
        
        serializer = statisticsSerializer(user_statistics)
        return JsonResponse(serializer.data)
    

class UserView(APIView):
    authentication_classes = [TokenAuthentication]

    def get_permissions(self):
        if self.request.method == 'POST':
            self.permission_classes = [AllowAny]
        else:
            self.permission_classes = [IsAuthenticated]
        return super(UserView, self).get_permissions()

    def get(self, request):
        token_auth = TokenAuthentication()
        try:
            user, token = token_auth.authenticate(request)
        except AuthenticationFailed:
            return JsonResponse({'error': 'Invalid token'}, status=401)
        
        serializer = UserSerializer(user)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid(raise_exception=ValueError):
            serializer.create(validated_data=request.data)
            return Response(
                serializer.data,
                status=status.HTTP_201_CREATED
            )
        return Response(
            {
                "error": True,
                "error_msg": serializer.error_messages,
            },
            status=status.HTTP_400_BAD_REQUEST
        )
    
    def patch(self, request):
        token_auth = TokenAuthentication()
        try:
            user, token = token_auth.authenticate(request)
        except AuthenticationFailed:
            return JsonResponse({'error': 'Invalid token'}, status=401)
        
        serializer = UserSerializer(user, data=request.data, partial=True)
        if serializer.is_valid(raise_exception=ValueError):
            serializer.update(instance=user, validated_data=request.data)
            return Response(
                serializer.data,
                status=status.HTTP_200_OK
            )
        return Response(
            {
                "error": True,
                "error_msg": serializer.error_messages,
            },
            status=status.HTTP_400_BAD_REQUEST
        )


def send_friend_request(request, userID):
    token_auth = TokenAuthentication()
    try:
        user, token = token_auth.authenticate(request)
    except AuthenticationFailed:
        return JsonResponse({'error': 'Invalid token'}, status=401)
    
    from_user = user
    to_user = User.objects.get(id=userID)
    friend_request, created = Friend_Request.objects.get_or_create(from_user=from_user, to_user=to_user)

    if created:
        return JsonResponse({'message': 'friend request sent'}, status=200)
    else:
        return JsonResponse({'message': 'friend request already sent'}, status=409)  # conflicts error
    
    
def accept_friend_request(request, requestID):
    token_auth = TokenAuthentication()
    try:
        user, token = token_auth.authenticate(request)
    except AuthenticationFailed:
        return JsonResponse({'error': 'Invalid token'}, status=401)
    
    friend_request = Friend_Request.objects.get(id=requestID)
    if friend_request.to_user == user:
        friend_request.to_user.friends.add(friend_request.from_user)
        friend_request.from_user.friends.add(friend_request.to_user)
        friend_request.delete()
        return JsonResponse({'message': 'friend request accepted'}, status=200)
    else:
        return JsonResponse({'message': 'friend request not accepted'}, status=409)  # conflicts error
    
def retrieve_friend_requests(request):
    token_auth = TokenAuthentication()
    try:
        user, token = token_auth.authenticate(request)
    except AuthenticationFailed:
        return JsonResponse({'error': 'Invalid token'}, status=401)
    
    friend_requests = Friend_Request.objects.filter(to_user=user.id)
    serializer = FriendRequestSerializer(friend_requests, many=True)
    return JsonResponse(serializer.data, safe=False)

def get_friends(request):

    token_auth = TokenAuthentication()
    try:
        user, token = token_auth.authenticate(request)
    except AuthenticationFailed:
        return JsonResponse({'error': 'Invalid token'}, status=401)
    
    friends = user.friends.all()
    serializer = FriendSerializer(friends, many=True)
    return JsonResponse(serializer.data, safe=False)