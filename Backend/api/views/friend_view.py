from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.authentication import TokenAuthentication
from rest_framework.exceptions import AuthenticationFailed
from ..models import Friend_Request, User
from ..serializers import FriendRequestSerializer, FriendSerializer, FriendUserSerializer

class FriendRequestViewSet(viewsets.ViewSet):
    authentication_classes = [TokenAuthentication]

    def create(self, request):

        user, token = self.request.user, self.request.auth

        from_user = user
        to_user = User.objects.get(id=request.data['to_user'])
        friend_request, created = Friend_Request.objects.get_or_create(from_user=from_user, to_user=to_user)

        if created:
            return Response({'message': 'friend request sent'}, status=status.HTTP_200_OK)
        else:
            return Response({'message': 'friend request already sent'}, status=status.HTTP_409_CONFLICT)

    def list(self, request):
        try:
            user, token = self.request.user, self.request.auth
        except AuthenticationFailed:
            return Response({'error': 'Invalid token'}, status=status.HTTP_401_UNAUTHORIZED)

        friend_requests = Friend_Request.objects.filter(to_user=user)
        serializer = FriendRequestSerializer(friend_requests, many=True)
        return Response(serializer.data)

    def destroy(self, request, pk=None):
        try:
            user, token = self.request.user, self.request.auth
        except AuthenticationFailed:
            return Response({'error': 'Invalid token'}, status=status.HTTP_401_UNAUTHORIZED)

        friend_request = Friend_Request.objects.get(id=pk)
        if friend_request.to_user == user:
            friend_request.to_user.friends.add(friend_request.from_user)
            friend_request.from_user.friends.add(friend_request.to_user)
            friend_request.delete()
            return Response({'message': 'friend request accepted'}, status=status.HTTP_200_OK)
        else:
            return Response({'message': 'friend request not accepted'}, status=status.HTTP_409_CONFLICT)

class FriendViewSet(viewsets.ViewSet):
    authentication_classes = [TokenAuthentication]

    def list(self, request):

        user, token = self.request.user, self.request.auth
        friends = user.friends.all()
        serializer = FriendUserSerializer(friends, many=True)
        return Response(serializer.data)
