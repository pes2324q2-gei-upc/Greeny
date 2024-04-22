# pylint: disable=no-member
import requests
from django.shortcuts import redirect
from django.http import JsonResponse
from django.views import View
from rest_framework import generics
import os
from .models import *
from .serializers import *
import json
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework import status
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated
from rest_framework.exceptions import AuthenticationFailed
from rest_framework.permissions import AllowAny

@method_decorator(csrf_exempt, name='dispatch')
class StatisticsView(View):

    def getUser(self, request):
        token_auth = TokenAuthentication()
        try:
            user, token = token_auth.authenticate(request)
        except AuthenticationFailed:
            return JsonResponse({'error': 'Invalid token'}, status=401)

        return user, token

    #POST final form
    def post(self, request):
        if request.method == 'POST':

            user, token = self.getUser(request)

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
                user_statics = Statistics.objects.get(user=user)
                for key, value in update_fields.items():
                    current_value = getattr(user_statics, key, 0)
                    setattr(user_statics, key, current_value + value)
                user_statics.save()
            except Statistics.DoesNotExist:
                user_statics = Statistics.objects.create(user=user, **update_fields)
                user_statics.save()
                
            return JsonResponse({'status': 'success'})

    def get(self, request):

        user, token = self.getUser(request)

        try:
            user_statistics = Statistics.objects.get(user=user)
        except Statistics.DoesNotExist:
            user_statistics = Statistics.objects.create(
                user=user,
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