from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework import viewsets, status
from rest_framework.response import Response
from .models import FriendRequest, User
from .serializers import FriendRequestSerializer, FriendUserSerializer

class FriendRequestViewSet(viewsets.ViewSet):
    authentication_classes = [JWTAuthentication]

    def create(self, request):

        from_user = self.request.user
        to_user = User.objects.get(id=request.data['to_user'])
        created = FriendRequest.objects.get_or_create(
                                                from_user=from_user,
                                                to_user=to_user)

        if created:
            return Response(
                {'message': 'friend request sent'},
                status=status.HTTP_200_OK)

        return Response(
            {'message': 'friend request already sent'},
            status=status.HTTP_409_CONFLICT)

    def list(self, request):
        user = self.request.user

        friend_requests = FriendRequest.objects.filter(to_user=user)
        serializer = FriendRequestSerializer(friend_requests, many=True)
        return Response(serializer.data)

    def destroy(self, request, pk=None):
        user = self.request.user

        friend_request = FriendRequest.objects.get(id=pk)
        if friend_request.to_user == user:
            friend_request.to_user.friends.add(friend_request.from_user)
            friend_request.from_user.friends.add(friend_request.to_user)
            friend_request.delete()
            return Response({'message': 'friend request accepted'}, status=status.HTTP_200_OK)
        return Response({'message': 'friend request not accepted'}, status=status.HTTP_409_CONFLICT)

class FriendViewSet(viewsets.ViewSet):
    authentication_classes = [JWTAuthentication]

    def list(self, request):

        user= self.request.user
        friends = user.friends.all()
        serializer = FriendUserSerializer(friends, many=True)
        return Response(serializer.data)
    
    def destroy(self, request, pk=None):
        user = self.request.user
        try:
            friend = User.objects.get(pk=pk)
        except User.DoesNotExist:
            return Response({'error': 'User not found.'}, status=status.HTTP_404_NOT_FOUND)

        if friend in user.friends.all():
            user.friends.remove(friend)
            friend.friends.remove(user)
            user.save()
            friend.save()
            return Response({'message': 'Friend removed.'}, status=status.HTTP_200_OK)
        else:
            return Response({'message': 'This user is not your friend.'}, status=status.HTTP_400_BAD_REQUEST)

