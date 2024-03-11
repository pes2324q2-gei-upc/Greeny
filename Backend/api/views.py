import requests
from django.shortcuts import render
from django.http import JsonResponse
from django.views import View
from pathlib import Path
#from .serializers import MetroSerializer
import os

from .models import *

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
        return JsonResponse(data, safe=False)
    
# #GET estacions Transport Public Barcelona (METRO, TRAM, FGC, RENFE)
# class FetchEstacionsTransportPublic(View):
#     def get(self, request):
#         response = requests.get(url=(BASE_URL_AJT + ID_ESTACIONS_TRANSPORT + "&limit=700"));
#         data = response.json()

#         estacions = data.get("result").get("records")

#         for item in estacions:
#             # if "METRO" in item.get('EQUIPAMENT'):
#             #     full_name = item.get('EQUIPAMENT');
#             #     nom_parada = full_name.split(" - ")[1].replace("-","");
#             #     linia = [full_name.split("(")[1].split(")")[0]];


#             #     #Buscamos por nombre por si ya existe la parada
                
#             #     try:
#             #         estacio = Estacio.objects.get(nom=nom_parada)
#             #     except Estacio.DoesNotExist:
#             #         estacio = None
                
#             #     if estacio is None:                     #Si no existe parada la creamos
#             #         Metro.objects.create(
#             #             nom = nom_parada,
#             #             latitud = item.get('LATITUD'),
#             #             longitud = item.get('LONGITUD'),
#             #             linies = linia
#             #         )
#             #         #print("Create Metro")
#             #     else:                                   #Si existe la parada, actualizamos las lineas del Metro Asociado     
#             #         estacio.metro.linies.append(linia[0])
#             #         estacio.metro.save()
            
#             #Tramvia: ej TRAMVIA (T1,T2) - LES AIGÜES- 
#             if "TRAM" in item.get('EQUIPAMENT'):
#                 full_name = item.get('EQUIPAMENT');
#                 nom_parada = full_name.split(" - ")[1].replace("-","");
#                 #linies_parada = full_name.split(" - ")[0].split(" ")[1].replace("(","").replace(")","").split(",");
#                 linies_parada = full_name.split(" - ")[0].replace(" ", "").split("(")[1].replace(")", "").split(",")

#                 if nom_parada == "Mª CRISTINA":
#                     nom_parada = "MARIA CRISTINA"
#                 elif nom_parada == "TORREBLANCA":
#                     linies_parada = [full_name.split(" - ")[0].split(" ")[2].replace(")", "")]

#                 print(nom_parada, linies_parada)

#                 try:
#                     estacio = Estacio.objects.get(nom__iexact=nom_parada)
#                 except Estacio.DoesNotExist:
#                     estacio = None

#                 if estacio is None:
#                     Tram.objects.create(
#                         nom = nom_parada,
#                         latitud = item.get('LATITUD'),
#                         longitud = item.get('LONGITUD'),
#                         linies = linies_parada,
#                     )
#                     #print("Nueva estación creada: " + nom_parada)
#                 else:
#                     new_tram = Tram(linies=linies_parada, estacio_ptr_id=estacio.id)
#                     new_tram.save()
#                     #print("Creamos nuevo TRAM asociado a la estacion: " + nom_parada + " con linias: " + str(linies_parada))
                
#             # elif "FGC" in item.get('EQUIPAMENT'):
#             #     FGC.objects.create(
#             #         nom = item.get('EQUIPAMENT'),
#             #         latitud = item.get('LATITUD'),
#             #         longitud = item.get('LONGITUD')
#             #     )
#             # elif "RENFE" in item.get('EQUIPAMENT'):
#             #     RENFE.objects.create(
#             #         nom = item.get('EQUIPAMENT'),
#             #         latitud = item.get('LATITUD'),
#             #         longitud = item.get('LONGITUD')]
#             #     )
#         return JsonResponse(data, safe=False)

# def getParadesMetro(request):
#     elements = Metro.objects.all();
#     serializer = MetroSerializer(elements, many=True)
#     return JsonResponse(serializer.data, safe=False)

    
#GET parades de bus Barcelona
class ParadesBus(View):
    def get(self, request):
        response = requests.get(url=(BASE_URL_AJT + "2d190658-93ac-4c43-a23f-c5d313b1ae9c" + "$limit=3250"));
        data = response.json()
        return JsonResponse(data, safe=False)

#GET estacions Bicing
class EstacionsBicing(View):
    def get(self, request):
        url = "https://opendata-ajuntament.barcelona.cat/data/dataset/informacio-estacions-bicing/resource/f60e9291-5aaa-417d-9b91-612a9de800aa/download/Informacio_Estacions_Bicing_securitzat.json"
        response = requests.get(url=url, headers=headers_AJT)
        response.raise_for_status()
        data = response.json()
        print(data)
        return JsonResponse(data)