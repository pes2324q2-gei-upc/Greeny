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

        if from_user.id != to_user.id:
            
            if to_user in from_user.friends.all():
                return Response(
                    {'error': 'User is already a friend'},
                    status=status.HTTP_400_BAD_REQUEST)

            created, _ = FriendRequest.objects.get_or_create(
                from_user=from_user,
                to_user=to_user)

            if created:
                return Response(
                    {'message': 'friend request sent'},
                    status=status.HTTP_200_OK)
            else:
                return Response(
                    {'message': 'friend request already sent'},
                    status=status.HTTP_409_CONFLICT)
        else:
            return Response({'error': 'can\'t add yourself as a friend'}, 
                            status=status.HTTP_400_BAD_REQUEST)

    def list(self, request):
        user = self.request.user

        friend_requests = FriendRequest.objects.filter(to_user=user)
        serializer = FriendRequestSerializer(friend_requests, many=True)
        return Response(serializer.data)

    def destroy(self, request, pk=None):
        user = self.request.user
        action = request.data['accept']

        try:
            friend_request = FriendRequest.objects.get(id=pk)
        except FriendRequest.DoesNotExist as e:
            return Response({'error': 'Friend request does not exist'}, status.HTTP_400_BAD_REQUEST)
        
        if friend_request.to_user == user:
            if action == 'true':
                try:
                    friend_request.to_user.friends.add(friend_request.from_user)
                    friend_request.from_user.friends.add(friend_request.to_user)
                except Exception as e:
                    return Response({'message': 'There has been an error adding the friend',
                                     'error': f'{e}'})
            friend_request.delete()
            message = "Friend request accepted" if action == 'true' else "Friend request not accepted"
            return Response({'message': message}, status=status.HTTP_200_OK)

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

