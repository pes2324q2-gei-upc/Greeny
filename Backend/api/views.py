# pylint: disable=no-member
import requests
from django.shortcuts import render, redirect
from django.http import JsonResponse
from django.views import View
from rest_framework import generics
from pathlib import Path
import os
from .models import *
from .serializers import *
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
    
class CityView(APIView):
    def getCurrentLevel(self, user):
        if not Level.objects.filter(user=user).exists():
            # Inicializar la tabla Level si está vacía para el usuario
            for i in range(1, 9):  # Crear 8 niveles, con números del 1 al 8
                Level.objects.create(
                    number=i,
                    completed=False,
                    current=(i == 1),  # El primer nivel (number=1) tendrá current=True
                    points_user=0.0,
                    user=user,
                    Neighborhood=Neighborhood.objects.get(path='path1')  # Replace with the actual neighborhood object
                )
        try:
            return Level.objects.get(user=user, current=True)
        except Level.DoesNotExist:
            print("no funciona")

    def getNeighborhood(self, level):
        return Neighborhood.objects.get(id=level.Neighborhood_id)

    def init_neighborhoods(self):
        try:
            Neighborhood.objects.get(path='path1')
        except Neighborhood.DoesNotExist:
            neighborhoods_data = [
                {'points_total': 100.0, 'path': 'path1'},
                {'points_total': 200.0, 'path': 'path2'},
                # ... add all 8 neighborhoods
            ]
            for neighborhood_data in neighborhoods_data:
                neighborhood = Neighborhood.objects.create(**neighborhood_data)
                neighborhood.save()

    def get(self, request):
        self.init_neighborhoods()

        # token_auth = TokenAuthentication()
        # try:
        #     user, token = token_auth.authenticate(request)
        # except AuthenticationFailed:
        #     return JsonResponse({'error': 'Invalid token'}, status=401)

        user = self.request.user
        level = self.getCurrentLevel(user)
        neighborhood = self.getNeighborhood(level)
        serializer = NeighborhoodSerializer(neighborhood)
        return JsonResponse(serializer.data)
