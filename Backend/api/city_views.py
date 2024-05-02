from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Neighborhood, Level
from .serializers import LevelSerializer

class CityView(APIView):

    def get_current_level(self, user):
        try:
            return Level.objects.get(user=user, current=True)
        except Level.DoesNotExist:
            return "Next level not found"

    def get_neighborhood(self, level):
        return Neighborhood.objects.get(id=level.neighborhood_id)

    def get(self, request):
        user = self.request.user
        level = self.get_current_level(user)
        level_data = LevelSerializer(level).data
        return Response(level_data)

    def update_points(self, user, new_points):
        level = self.get_current_level(user)

        if new_points is not None:
            level.points_user = new_points
            level.save()

            level = self.update_level(user)

            level_data = LevelSerializer(level).data
            return level_data
        return "No level data"

    def add_points(self, user, new_points):
        level = self.get_current_level(user)

        if new_points is not None:
            level.points_user += new_points
            level.save()

            level = self.update_level(user)

            level_data = LevelSerializer(level).data
            return level_data
        return "No level data"

    def update_level(self, user):
        current_level = self.get_current_level(user)
        if current_level.points_user > current_level.points_total:
            current_level.completed = True
            current_level.current = False
            current_level.points_user = current_level.points_total
            current_level.save()
            next_level_number = current_level.number + 1
            try:
                next_level = Level.objects.get(user=user, number=next_level_number)
                next_level.current = True
                next_level.save()
            except Level.DoesNotExist:
                return "Next level not found"

        return self.get_current_level(user)

    def put(self, request):
        user = self.request.user
        new_points = request.data.get('points_user')

        if new_points is not None:
            level_data = self.update_points(user, new_points)
            r = Response(level_data)
        else:
            r = Response({'error': 'no se proporcionaron nuevos puntos.'},
                            status=status.HTTP_400_BAD_REQUEST)
        return r
