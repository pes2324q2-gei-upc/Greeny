from django.http import JsonResponse
from rest_framework.views import APIView
from .models import *
from .serializers import *

class CityView(APIView):
    def init_neighborhoods(self):
        names = ['Nou Barris', 'Horta-Guinardó', 'Sants-Montjuïc', 'Sarrià-StGervasi', 'Les Corts', 'Sant Andreu', 'Sant Martí', 'Gràcia', 'Ciutat Vella', 'Eixample']
        neighborhoods_data = [
            {'name': names[i], 'points_total': 100.0, 'path': f'nhood_{i+1}.glb'} for i in range(len(names))
        ]
        for neighborhood_data in neighborhoods_data:
            Neighborhood.objects.get_or_create(**neighborhood_data)
    def getCurrentLevel(self, user):
        if not Level.objects.filter(user=user).exists():
            for i in range(1, 9):
                neighborhood = Neighborhood.objects.get(path=f'nhood_{i}.glb')
                Level.objects.create(
                    number=i,
                    completed=False,
                    current=(i == 1),
                    points_user=0.0,
                    user=user,
                    Neighborhood=neighborhood
                )
        try:
            return Level.objects.get(user=user, current=True)
        except Level.DoesNotExist:
            print("no ha encontrado el level")

    def getNeighborhood(self, level):
        return Neighborhood.objects.get(id=level.Neighborhood_id)

    def get(self, request):
        self.init_neighborhoods()
        user = self.request.user
        level = self.getCurrentLevel(user)
        neighborhood = self.getNeighborhood(level)
        serializer = NeighborhoodSerializer(neighborhood)
        return JsonResponse(serializer.data)