from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Neighborhood, Level
from .serializers import LevelSerializer, HistorySerializer

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
        user = request.user
        levels = Level.objects.filter(user=user)
        all_completed = all(level.completed for level in levels)
        if all_completed:
            user_data = {
                "user_name": user.username,
                "is_staff": user.is_staff,
                "status": "all_completed"
            }
            return Response(user_data)

        level = self.get_current_level(user)
        if level is None:
            response_data = {"message": "No current level"}
        else:
            response_data = LevelSerializer(level).data

        return Response(response_data)

    def add_points(self, user, new_points):
        level = self.get_current_level(user)

        if new_points is not None:
            level.points_user += new_points
            level.save()

            level = self.update_level(user)

            level_data = LevelSerializer(level).data
            return level_data
        return "No level data"

    def update_points(self, user, new_points):
        level = self.get_current_level(user)
        response_data = {}
        if new_points is not None:
            if new_points < 0:
                level.points_user = 0
                level.save()
                if level.number > 1:
                    lvlnb = level.number - 1
                    previous_level = Level.objects.filter(user=user, number=lvlnb).first()
                    if previous_level:
                        level.current = False
                        level.completed = False
                        level.save()
                        previous_level.current = True
                        previous_level.completed = False
                        previous_level.save()
                        response_data = LevelSerializer(previous_level).data
                    else:
                        response_data = {"message": "No previous level found"}
                else:
                    response_data = LevelSerializer(level).data
            else:
                level.points_user = new_points
                level.save()
                if level.number == 10 and new_points >= 1500:
                    level.completed = True
                    level.current = False
                    level.save()
                    user_data = {
                        "user_name": user.username,
                        "is_staff": user.is_staff,
                        "status": "all_completed"
                    }
                    response_data = user_data
                else:
                    next_level = self.update_level(user)
                    if next_level:
                        response_data = LevelSerializer(next_level).data
                    else:
                        response_data = {"message": "Failed to update level"}

        levels = Level.objects.filter(user=user)
        all_completed = all(l.completed for l in levels)
        if all_completed:
            user_data = {
                "user_name": user.username,
                "is_staff": user.is_staff,
                "status": "all_completed"
            }
            response_data.update(user_data)

        return response_data if response_data else {"message": "No updates performed."}

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
    
    def reset_levels(self, user):
        levels = Level.objects.filter(user=user)
        for level in levels:
            level.completed = False
            level.current = False
            level.points_user = 0
            level.save()

        if levels.exists():
            first_level = levels.first()
            first_level.current = True
            first_level.save()
            neighborhood = self.get_neighborhood(first_level)  # Asumiendo que tienes un método para obtener el vecindario del nivel
            level_data = {
                'points_user': first_level.points_user,
                'points_total': first_level.points_total,
                'number': first_level.number,
                'neighborhood': {
                    'name': neighborhood.name,
                    'path': neighborhood.path
                },
                'user_name': user.username,  # Incluye el nombre de usuario
                'is_staff': user.is_staff    # Incluye el estado de staff
            }
        else:
            return Response({
                "status": "error",
                "message": "No levels found for user."
            }, status=status.HTTP_404_NOT_FOUND)

        return Response({
            "status": "levels_reset",
            "message": "All levels have been reset successfully.",
            **level_data  # Descomprime el diccionario de level_data aquí
        })

    def put(self, request):
        user = request.user
        print(request.data)
        if request.data.get('reset'):
            return self.reset_levels(user)
        else:
            new_points = request.data.get('points_user')
            if new_points is not None:
                level_data = self.update_points(user, new_points)
                return Response(level_data)
            else:
                return Response({'error': 'No se proporcionaron nuevos puntos o acciones.'},
                                status=status.HTTP_400_BAD_REQUEST)

class NeighborhoodsView(APIView):

    def get(self, request):
        #neighborhoods = Neighborhood.objects.all()
        levels = Level.objects.filter(user=self.request.user).order_by('number')
        serializer = HistorySerializer(levels, many=True)
        return Response(serializer.data)
