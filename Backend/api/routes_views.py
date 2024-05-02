from datetime import datetime
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
import pytz
from .utils import (calculate_co2_consumed, calculate_car_co2_consumed,
                    calculate_statistics, calculate_points)
from .city_views import CityView
from .models import Statistics, Route
from .serializers import RouteSerializer

class RoutesView(APIView):

    # POST final form --> save new route
    def post(self, request):
        user = self.request.user

        data = request.data

        transports_percentages = data['transportPercentages']
        total_distance = data['totalDistance']
        started_at = data['startedAt']

        started_at = datetime.strptime(started_at, '%Y-%m-%dT%H:%M:%S.%f')
        spain_tz = pytz.timezone('Europe/Madrid')
        started_at = spain_tz.localize(started_at)
        ended_at = datetime.now(spain_tz)

        consumed_co2 = 0.0
        car_consumed_co2 = 0.0

        if len(transports_percentages) != 0:
            consumed_co2 = calculate_co2_consumed(transports_percentages, total_distance)
            car_consumed_co2 = calculate_car_co2_consumed(total_distance)

            # si no responen el form, tenen 0 punts --> No se si ho farem aixi al final
            points = calculate_points(consumed_co2, car_consumed_co2)
            city_view = CityView()
            city_view.add_points(user, points)


        Route.objects.create(
            user=user,
            distance=total_distance,
            transports=list(transports_percentages.keys()),
            consumed_co2=consumed_co2,
            car_consumed_co2=car_consumed_co2,
            started_at=started_at,
            ended_at=ended_at,
        )

        update_fields = calculate_statistics(transports_percentages, total_distance)

        try:
            user_statics = Statistics.objects.get(user=user)
            for key, value in update_fields.items():
                current_value = getattr(user_statics, key, 0)
                setattr(user_statics, key, current_value + value)
            setattr(user_statics, 'kg_CO2_consumed',
                    user_statics.kg_CO2_consumed + consumed_co2)
            setattr(user_statics, 'kg_CO2_car_consumed',
                    user_statics.kg_CO2_car_consumed + car_consumed_co2)
            user_statics.save()
        except Statistics.DoesNotExist:
            user_statics = Statistics.objects.create(user=user, **update_fields,
                                                     kg_CO2_consumed=consumed_co2,
                                                     kg_CO2_car_consumed=car_consumed_co2)
            user_statics.save()

        return Response({'status': 'success'})

    def get_queryset(self):
        user = self.request.user
        routes = Route.objects.filter(user=user)
        return routes

    def get(self, request):
        routes = self.get_queryset()
        serializer = RouteSerializer(routes, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
