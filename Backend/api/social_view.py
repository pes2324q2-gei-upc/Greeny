from rest_framework import viewsets, status
from rest_framework.response import Response
from .serializers import FriendUserSerializer
from .models import User

class RankingViewSet(viewsets.ViewSet):

    def list(self, request):
        user = request.user
        filter_type = request.query_params.get('filter', 'all')

        if filter_type == 'friends':
            friends = user.friends.all()
            friends = user.friends.all()  # Asumiendo que tienes una relación de amigos definida en el modelo User
            queryset = User.objects.filter(id__in=friends).order_by('-points')
        else:
            queryset = User.objects.all().order_by('-points')

        serializer = FriendUserSerializer(queryset, many=True, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)