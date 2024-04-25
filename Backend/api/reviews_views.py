from rest_framework.viewsets import ModelViewSet
from .models import *
from .serializers import *
from rest_framework.response import Response
from rest_framework import status


class ReviewsViews(ModelViewSet):
    serializer_class = reviewsSerializer

    def create(self, request, *args, **kwargs):
        user = self.request.user
        station_id = self.kwargs['station_id']
        station = Station.objects.get(id=station_id)
        serializer = self.get_serializer(data=request.data)

        self.update_station_rating(station)

        if serializer.is_valid():
            serializer.save(author=user, station=station)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def update_station_rating(self, station):
        reviews = Review.objects.filter(station=station)
        total = 0
        for review in reviews:
            total += review.puntuation
        station.rating = total / len(reviews)
        station.save()

    def get_queryset(self):
        station_id = self.kwargs['station_id']
        station = Station.objects.get(id=station_id)
        reviews = Review.objects.filter(station=station)
        return reviews