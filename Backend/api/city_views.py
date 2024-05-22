from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Neighborhood, Level
from .serializers import LevelSerializer

class CityView(APIView):

    def get_current_level(self, user):
        try:
            level = Level.objects.get(user=user, current=True)  # Retorna una instancia específica
            return level
        except Level.DoesNotExist:
            return None  # Asegúrate de manejar el caso en que no exista el nivel


    def get_neighborhood(self, level):
        return Neighborhood.objects.get(id=level.neighborhood_id)

    def get(self, request):
        user = self.request.user
        level = self.get_current_level(user)
        levels = Level.objects.filter(user=user)
        all_completed = all(level.completed for level in levels)
        if all_completed:
            user_data = {
                "user_name": user.username,
                "is_staff": user.is_staff
            }
            response_data = {"status": "all_completed"}
            response_data.update(user_data)  # Agrega los datos del usuario a la respuesta
            return Response(response_data)
        if level is None:
            return Response({"message": "No current level"})
        level_data = LevelSerializer(level).data
        return Response(level_data)

    def update_points(self, user, new_points):
        level = self.get_current_level(user)

        if new_points is not None and level is not None:
            level.points_user = new_points
            level.save()

            if level.number == 10 and new_points >= 1500:
                level.completed = True
                level.current = False
                level.save()
                user_data = {
                    "user_name": user.username,
                    "is_staff": user.is_staff
                }
                response_data = {"status": "all_completed"}
                response_data.update(user_data) 
                return response_data
            next_level = self.update_level(user)
            if next_level:
                level_data = LevelSerializer(next_level).data
                return level_data

        levels = Level.objects.filter(user=user)
        all_completed = all(level.completed for level in levels)
        if all_completed:
            user_data = {
                "user_name": user.username,
                "is_staff": user.is_staff
            }
            response_data = {"status": "all_completed"}
            response_data.update(user_data)  # Agrega los datos del usuario a la respuesta
            return response_data

        return {"message": "No updates performed."}


    def update_level(self, user):
        current_level = self.get_current_level(user)
        if current_level.points_user >= current_level.points_total:
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
                return None

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
