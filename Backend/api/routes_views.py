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
from django.utils.decorators import method_decorator
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework import status
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated
from rest_framework.exceptions import AuthenticationFailed
from rest_framework.permissions import AllowAny
from datetime import datetime
import pytz
from .utils import calculate_co2_consumed, calculate_car_co2_consumed, calculate_statistics, calculate_points
# from . import city_views

class RoutesView(APIView):

    # POST final form --> save new route
    def post(self, request):
        user = self.request.user

        data = request.data

        transports = data['selectedTransports']
        total_distance = data['totalDistance']
        started_at = data['startedAt']

        started_at = datetime.strptime(started_at, '%Y-%m-%dT%H:%M:%S.%f')
        spain_tz = pytz.timezone('Europe/Madrid')
        started_at = spain_tz.localize(started_at)
        ended_at = datetime.now(spain_tz)

        consumed_co2 = 0.0
        car_consumed_co2 = 0.0

        if len(transports) != 0:
            consumed_co2 = calculate_co2_consumed(transports, total_distance)
            car_consumed_co2 = calculate_car_co2_consumed(total_distance)

            # si no responen el form, tenen 0 punts --> No se si ho farem aixi al final
            points = calculate_points(consumed_co2, car_consumed_co2)
            #points = city_views.update_points(points, user)

        Route.objects.create(
            user=user,
            distance=total_distance,
            transports=transports,
            consumed_co2=consumed_co2,
            car_consumed_co2=car_consumed_co2,
            started_at=started_at,
            ended_at=ended_at,
        )

        update_fields = calculate_statistics(transports, total_distance)

        try:
            user_statics = Statistics.objects.get(user=user)
            for key, value in update_fields.items():
                current_value = getattr(user_statics, key, 0)
                setattr(user_statics, key, current_value + value)
            setattr(user_statics, 'kg_CO2_consumed', user_statics.kg_CO2_consumed + consumed_co2)
            setattr(user_statics, 'kg_CO2_car_consumed', user_statics.kg_CO2_car_consumed + car_consumed_co2)
            user_statics.save()
        except Statistics.DoesNotExist:
            user_statics = Statistics.objects.create(user=user, **update_fields, kg_CO2_consumed=consumed_co2,
                                                     kg_CO2_car_consumed=car_consumed_co2)
            user_statics.save()

        return JsonResponse({'status': 'success'})

    def get_queryset(self):
        user = self.request.user
        routes = Route.objects.filter(user=user)
        return routes

    def get(self, request):
        routes = self.get_queryset()
        serializer = RouteSerializer(routes, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)