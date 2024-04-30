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

    def getCurrentLevel(self, user):
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
    
    def updateLevel(self, user):
        current_level = self.getCurrentLevel(user)
        if current_level.points_user > current_level.points_total:
            # Completa el nivel actual
            current_level.completed = True
            current_level.current = False
            current_level.points_user -= 10
            current_level.save()

            # Obtiene el siguiente nivel
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
        level = self.getCurrentLevel(user)

        # Obtén los nuevos puntos del usuario de los datos de la solicitud
        new_points = request.data.get('points_user')

        if new_points is not None:
            # Actualiza los puntos del usuario
            level.points_user = new_points
            level.save()

            # Verifica si el usuario ha pasado de nivel
            level = self.updateLevel(user)

            # Devuelve una respuesta con los datos actualizados del nivel
            level_data = LevelSerializer(level).data
            return JsonResponse(level_data)

        else:
            # Si 'points_user' no está en los datos de la solicitud, devuelve un error
            return Response({'error': 'No se proporcionaron nuevos puntos.'}, status=status.HTTP_400_BAD_REQUEST)