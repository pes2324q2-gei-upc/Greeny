from rest_framework.viewsets import ModelViewSet
from rest_framework.response import Response
from rest_framework.decorators import api_view

from rest_framework import status
from .models import Review, Station, User
from .serializers import ReviewSerializer
from profanity_check import predict_prob
from .utils import check_for_ban, translate
from ftlangdetect import detect
import logging

logger = logging.getLogger(__name__)

class ReviewsViews(ModelViewSet):
    serializer_class = ReviewSerializer

    def create(self, request, *args, **kwargs):
        user = self.request.user
        station_id = self.kwargs['station_id']
        station = Station.objects.get(id=station_id)
        serializer = self.get_serializer(data=request.data)

        if serializer.is_valid():
            serializer.save(author=user, station=station)
            self.update_station_rating(station)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def update_station_rating(self, station):
        reviews = Review.objects.filter(station=station)
        total = 0
        for review in reviews:
            total += review.puntuation
        station.rating = round((total / len(reviews)), 2)
        station.save()

    def get_queryset(self):
        station_id = self.kwargs['station_id']
        station = Station.objects.get(id=station_id)
        reviews = Review.objects.filter(station=station).order_by('-creation_date')
        return reviews

@api_view(['POST'])
def profanity_filter(request, station_id, review_id):
    review = Review.objects.get(id=review_id)
    body = review.body

    lang = detect(text=body, low_memory=False)['lang']
    if lang != 'en':
        try:
            body = translate(body, lang)
        except Exception as e:
            logger.error(f'Couldn\'t detect de language of the reported review with ID: {review.id}, please check it')
            return Response({'message':'Review pending of evaluation'})


    if predict_prob([body]) >= 0.75:
        # Añadimos report al user
        user = request.user
        user.reports = user.reports + 1
        user.save()

        # Eliminamos la review
        review.delete()

        if check_for_ban(user):
            # redirect to BAN Screen
            return Response({'message': 'User has been banned'}, status=status.HTTP_423_LOCKED)

        return Response({'message': 'Review has been deleted due to profanity'}, status=status.HTTP_200_OK)
    return Response({'message': 'No profanity detected'}, status=status.HTTP_200_OK)
