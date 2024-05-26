from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.decorators import api_view

from django.contrib.gis.geos import GEOSGeometry

from .models import Neighborhood, Level
from .serializers import LevelSerializer, HistorySerializer
from .adapters.airmon_adapter import ICQAAirmonAdapter


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
            current_level_number = Level.objects.filter(user=user).last().number
            previous_level_number = current_level_number - 1
            previous_level_name = None
            if previous_level_number > 0:
                previous_level = Level.objects.get(user=user, number=previous_level_number)
                if previous_level:
                    previous_level_name = self.get_neighborhood(previous_level).name
            user_data = {
                "user_name": user.username,
                "is_staff": user.is_staff,
                "status": "all_completed",
                "previous_lvl_just_passed": user.previous_lvl_just_passed,
                "previous_level_name": previous_level_name
            }
            if user.previous_lvl_just_passed:
                user.previous_lvl_just_passed = False
                user.save()
            return Response(user_data)

        level = self.get_current_level(user)
        if level is None:
            response_data = {"message": "No current level"}
        else:
            level_data = LevelSerializer(level).data
            previous_lvl_number = level.number - 1
            previous_level_name = None
            if previous_level_number > 0:
                previous_level = Level.objects.filter(user=user, number=previous_lvl_number).first()
                if previous_level:
                    previous_level_name = self.get_neighborhood(previous_level).name
            response_data = {
                **level_data,
                "previous_lvl_just_passed": user.previous_lvl_just_passed,
                "previous_level_name": previous_level_name
            }
            if user.previous_lvl_just_passed:
                user.previous_lvl_just_passed = False
                user.save()
        return Response(response_data)

    def update_points(self, user, new_points):
        if user.previous_lvl_just_passed:
                user.previous_lvl_just_passed = False
                user.save()
        user.points += new_points
        user.save()
        level = self.get_current_level(user)
        response_data = {}
        if new_points is not None:
            level.points_user += new_points
            level.save()
            if level.points_user < 0:
                lvlnb = level.number - 1
                level.points_user = 0
                level.save()
                if lvlnb > 0:
                    previous_level = Level.objects.filter(user=user, number=lvlnb).first()
                    level.current = False
                    level.completed = False
                    level.save()
                    previous_level.current = True
                    previous_level.completed = False
                    previous_level.save()
                    response_data = LevelSerializer(previous_level).data
                else:
                    response_data = LevelSerializer(level).data

            elif level.number == 10 and level.points_user >= 1500:
                level.completed = True
                level.current = False
                level.save()
                if user.mastery < 3:
                    user.mastery += 1
                user.previous_lvl_just_passed = True
                user.save()
                user_data = {
                    "user_name": user.username,
                    "is_staff": user.is_staff,
                    "status": "all_completed",
                    "mastery": user.mastery,
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
            user.previous_lvl_just_passed = True
            user.save()
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
            # Asumiendo que tienes un método para obtener el vecindario del nivel
            neighborhood = self.get_neighborhood(first_level)
            level_data = {
                'points_user': first_level.points_user,
                'points_total': first_level.points_total,
                'number': first_level.number,
                'neighborhood': {
                    'name': neighborhood.name,
                    'path': neighborhood.path
                },
                'user_name': user.username,  # Incluye el nombre de usuario
                'is_staff': user.is_staff,   # Incluye el estado de staff
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
        if request.data.get('reset'):
            return self.reset_levels(user)

        new_points = request.data.get('points_user')
        if new_points is not None:
            level_data = self.update_points(user, new_points)
            if user.previous_lvl_just_passed:
                user.previous_lvl_just_passed = False
                user.save()
            return Response(level_data)

        return Response({'error': 'No se proporcionaron nuevos puntos o acciones.'},
                        status=status.HTTP_400_BAD_REQUEST)

class NeighborhoodsView(APIView):

    def get(self, request):
        #neighborhoods = Neighborhood.objects.all()
        levels = Level.objects.filter(user=self.request.user).order_by('number')
        serializer = HistorySerializer(levels, many=True)
        return Response(serializer.data)

@api_view(['POST'])
def get_icqa(request):
    request = request.data
    nhood = Neighborhood.objects.get(name=request['name'])
    coords = nhood.coords.replace('{', '').replace('}', '').split(':')

    parsed_coords = []
    for coord in coords:
        pnt = GEOSGeometry(coord)
        parsed_coords.append({"latitude": pnt.y, "longitude": pnt.x})

    return Response(ICQAAirmonAdapter.get_icqa(parsed_coords), status=status.HTTP_200_OK)
