from django.http import JsonResponse
from rest_framework.views import APIView
from .models import *
from .serializers import *

class CityView(APIView):
    def init_neighborhoods(self):
        names = ['Nou Barris', 'Horta-Guinardó', 'Sants-Montjuïc', 'Sarrià-StGervasi', 'Les Corts', 'Sant Andreu', 'Sant Martí', 'Gràcia', 'Ciutat Vella', 'Eixample']
        neighborhoods_data = [
            {'name': names[i], 'path': f'nhood_{i+1}.glb'} for i in range(len(names))
        ]
        for neighborhood_data in neighborhoods_data:
            Neighborhood.objects.get_or_create(**neighborhood_data)

    def init_levels(self, user):
        if not Level.objects.filter(user=user).exists():
            points_total = [100, 150, 250, 400, 550, 700, 900, 1100, 1350, 1500]
            for i in range(1, 9):
                neighborhood = Neighborhood.objects.get(path=f'nhood_{i}.glb')
                Level.objects.create(
                    number=i,
                    completed=False,
                    current=(i == 1),
                    points_user=0,
                    points_total = points_total[i-1],
                    user=user,
                    neighborhood=neighborhood
                )

    def getCurrentLevel(self, user):
        self.init_levels(user)
        try:
            return Level.objects.get(user=user, current=True)
        except Level.DoesNotExist:
            print("no ha encontrado el level")

    def getNeighborhood(self, level):
        return Neighborhood.objects.get(id=level.neighborhood_id)
    
    def get(self, request):
        self.init_neighborhoods()
        user = self.request.user
        level = self.getCurrentLevel(user)
        level_data = LevelSerializer(level).data
        return JsonResponse(level_data)
    
    def update_points(self, user, new_points):
        level = self.getCurrentLevel(user)

        if new_points is not None:
            level.points_user = new_points 
            level.save()

            level = self.updateLevel(user)

            level_data = LevelSerializer(level).data
            return level_data
      
    def add_points(self, user, new_points):
        level = self.getCurrentLevel(user)

        if new_points is not None:
            level.points_user += new_points  

            level = self.updateLevel(user)

            level_data = LevelSerializer(level).data
            return level_data

    def updateLevel(self, user):
        current_level = self.getCurrentLevel(user)
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
                print("next level")
            except Level.DoesNotExist:
                print("No se encontró el siguiente nivel")

        return self.getCurrentLevel(user)
    
    def put(self, request):
        user = self.request.user
        new_points = request.data.get('points_user')

        if new_points is not None:
            level_data = self.update_points(user, new_points)
            return JsonResponse(level_data)
        else:
            return Response({'error': 'No se proporcionaron nuevos puntos.'}, status=status.HTTP_400_BAD_REQUEST)