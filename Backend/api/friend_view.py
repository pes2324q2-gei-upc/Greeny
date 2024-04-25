from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework import viewsets, status
from rest_framework.response import Response
from .models import Friend_Request, User
from .serializers import FriendRequestSerializer, FriendSerializer, FriendUserSerializer

class FriendRequestViewSet(viewsets.ViewSet):
    authentication_classes = [JWTAuthentication]

    def create(self, request):

        from_user = self.request.user
        to_user = User.objects.get(id=request.data['to_user'])
        friend_request, created = Friend_Request.objects.get_or_create(from_user=from_user, to_user=to_user)

        if created:
            return Response({'message': 'friend request sent'}, status=status.HTTP_200_OK)
        else:
            return Response({'message': 'friend request already sent'}, status=status.HTTP_409_CONFLICT)

    def list(self, request):
        user = self.request.user

        friend_requests = Friend_Request.objects.filter(to_user=user)
        serializer = FriendRequestSerializer(friend_requests, many=True)
        return Response(serializer.data)

    def destroy(self, request, pk=None):
        user = self.request.user

        friend_request = Friend_Request.objects.get(id=pk)
        if friend_request.to_user == user:
            friend_request.to_user.friends.add(friend_request.from_user)
            friend_request.from_user.friends.add(friend_request.to_user)
            friend_request.delete()
            return Response({'message': 'friend request accepted'}, status=status.HTTP_200_OK)
        else:
            return Response({'message': 'friend request not accepted'}, status=status.HTTP_409_CONFLICT)

class FriendViewSet(viewsets.ViewSet):
    authentication_classes = [JWTAuthentication]

    def list(self, request):

        user= self.request.user
        friends = user.friends.all()
        serializer = FriendUserSerializer(friends, many=True)
        return Response(serializer.data)
