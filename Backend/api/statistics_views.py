from rest_framework.viewsets import ModelViewSet
from .models import Statistics
from .serializers import StatisticsSerializer

class StatisticsView(ModelViewSet):
    serializer_class = StatisticsSerializer
    def get_queryset(self):
        user = self.request.user
        return Statistics.objects.filter(user=user)
