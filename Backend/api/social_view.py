from rest_framework import viewsets, status
from rest_framework.response import Response
from .serializers import FriendUserSerializer
from .models import User

class RankingViewSet(viewsets.ViewSet):
    """
    API endpoint que permet mostrar el ranking d'usuaris
    """
    DEFAULT_LIMIT = 20 #Numero d'usuaris a mostrar per defecte

    def list(self, request):
        """
        Retorna el ranking d'usuaris
        """
        user = request.user
        filter_type = request.query_params.get('filter', 'all')

        limit = self.DEFAULT_LIMIT

        if filter_type == 'friends':
            friends = user.friends.all()
            friends = user.friends.all()
            queryset = User.objects.filter(id__in=friends).order_by('-points')[:limit]
        else:
            queryset = User.objects.all().order_by('-points')[:limit]

        serializer = FriendUserSerializer(queryset, many=True, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)
