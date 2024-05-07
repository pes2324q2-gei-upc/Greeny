from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework.permissions import AllowAny
from rest_framework.viewsets import ModelViewSet
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth.hashers import check_password
from django.contrib.auth.hashers import make_password
from .models import User, Neighborhood, Level
from .serializers import UserSerializer


class UsersView(ModelViewSet):
    serializer_class = UserSerializer
    authentication_classes = [JWTAuthentication]

    def get_permissions(self):
        if self.request.method == 'POST':
            self.permission_classes = [AllowAny]
        else:
            self.permission_classes = [IsAuthenticated]
        return super().get_permissions()

    def init_neighborhoods(self):
        if Neighborhood.objects.exists():
            return
        names = ['Nou Barris', 'Horta-Guinardó', 'Sants-Montjuïc', 'Sarrià-StGervasi',
                 'Les Corts', 'Sant Andreu', 'Sant Martí', 'Gràcia', 'Ciutat Vella', 'Eixample']
        neighborhoods_data = [
            {'name': names[i], 'path': f'nhood_{i+1}.glb'} for i in range(len(names))
        ]
        for neighborhood_data in neighborhoods_data:
            Neighborhood.objects.get_or_create(**neighborhood_data)

    def init_levels(self, user):
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

    def create(self, request, *args, **kwargs):
        response = super().create(request, *args, **kwargs)
        self.init_neighborhoods()
        if response.status_code == 201:  # HTTP 201 Created
            user = User.objects.latest('id')
            self.init_levels(user)
        return response

    def patch(self, request):
        user = self.request.user

        # Remove the 'email' field from the request data
        data = request.data.copy()
        data.pop('email', None)

        serializer = self.get_serializer(user, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)

        # Check if the current password and new password are provided
        current_password = request.data.get('current_password')
        new_password = request.data.get('new_password')
        if current_password and new_password:
            # Check if the current password is correct
            if not check_password(current_password, user.password):
                return Response({"error": "Current password is not correct"},
                                status=status.HTTP_400_BAD_REQUEST)
            # Hash the new password and update it
            user.password = make_password(new_password)
            user.save()

        self.perform_update(serializer)

        if getattr(user, '_prefetched_objects_cache', None):
            # If 'prefetch_related' has been applied to a queryset, we need to
            # forcibly invalidate the prefetch cache on the instance.
            user._prefetched_objects_cache = {} # pylint: disable=protected-access

        return Response(serializer.data)


    def get_queryset(self):
        user = self.request.user
        return User.objects.filter(id=user.id)

    def retrieve(self, request, *args, **kwargs):
        try:
            user = User.objects.get(username=kwargs.get('pk'))
            serializer = self.get_serializer(user)
            return Response(serializer.data)
        except User.DoesNotExist:
            return Response({"error": "User not found."}, status=status.HTTP_404_NOT_FOUND)


    def delete(self, request):
        user = self.request.user
        user.delete()
        return Response(
            {
                "success": True,
                "message": "User deleted successfully"
            },
            status=status.HTTP_200_OK
        )
