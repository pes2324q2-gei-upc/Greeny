from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet
from .models import Statistics, CO2Consumed
from .serializers import StatisticsSerializer, CO2ConsumedSerializer

class StatisticsViewSet(ModelViewSet):
    serializer_class = StatisticsSerializer
    def get_queryset(self):
        user = self.request.user
        first_co2_consumed = CO2Consumed.objects.first()

        queryset = Statistics.objects.filter(user=user)

        return queryset, first_co2_consumed

    def list(self, request, *args, **kwargs):
        queryset, first_co2_consumed = self.get_queryset()

        statistics_serializer = self.serializer_class(queryset, many=True)
        co2_consumed_serializer = CO2ConsumedSerializer(first_co2_consumed)

        combined_data = {
            'statistics': statistics_serializer.data,
            'first_co2_consumed': co2_consumed_serializer.data
        }

        return Response(combined_data)
