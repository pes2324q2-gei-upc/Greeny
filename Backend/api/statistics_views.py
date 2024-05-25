from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet
from .models import Statistics, CO2Consumed
from .serializers import StatisticsSerializer, CO2ConsumedSerializer

class StatisticsViewSet(ModelViewSet):
    serializer_class = StatisticsSerializer
    
    def get_queryset(self):
        user = self.request.user
        
        # Obtener el primer objeto de CO2Consumed
        first_co2_consumed = CO2Consumed.objects.first()

        # Filtrar las estadísticas del usuario actual
        queryset = Statistics.objects.filter(user=user)
        
        # Devolver tanto el queryset de Statistics como el primer objeto de CO2Consumed
        return queryset, first_co2_consumed

    def list(self, request, *args, **kwargs):
        queryset, first_co2_consumed = self.get_queryset()
        
        # Serializar los datos
        statistics_serializer = self.serializer_class(queryset, many=True)
        co2_consumed_serializer = CO2ConsumedSerializer(first_co2_consumed)
        
        # Crear la respuesta combinada
        combined_data = {
            'statistics': statistics_serializer.data,
            'first_co2_consumed': co2_consumed_serializer.data
        }
        
        print(combined_data)
        
        return Response(combined_data)
