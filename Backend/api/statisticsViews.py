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

class StatisticsView(APIView):

    def get(self):
        try:
            user, token = self.request.user, self.request.auth
        except AuthenticationFailed:
            return JsonResponse({'error': 'Invalid token'}, status=401)

        try:
            user_statistics = Statistics.objects.get(user=user)
        except Statistics.DoesNotExist:
            user_statistics = Statistics.objects.create(
                user=user,
                kg_CO2_consumed=0.0,
                kg_CO2_car_consumed=0.0,
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