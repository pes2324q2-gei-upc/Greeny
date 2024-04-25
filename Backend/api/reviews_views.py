from rest_framework.viewsets import ModelViewSet
from .models import *
from .serializers import *

class reviews_views(ModelViewSet):
    serializer_class = reviewsSerializer

    def get_queryset(self):
        queryset = Review.objects.all()
        return queryset