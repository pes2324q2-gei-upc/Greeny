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


    def update_points(self, user, new_points):
        level = self.get_current_level(user)
        response_data = {}
        if new_points is not None:
            if new_points < 0:
                level.points_user = 0
                level.save()
                if level.number > 1:
                    lvlnb = level.number - 1
                    previous_level = Level.objects.filter(user=user, number=lvlnb - 1).first()
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
