import os
import random
import string
from django.conf import settings
from django.contrib.auth.hashers import check_password
from django.contrib.auth.hashers import make_password
from django.core.files.images import ImageFile
from django.core.mail import send_mail
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.decorators import permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet
from rest_framework_simplejwt.authentication import JWTAuthentication
from .models import User, Neighborhood, Level, VerificationCode
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

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated_data = serializer.validated_data

        validated_data['is_active'] = False
        user = User.objects.create_user(**validated_data)

        # Generate the verification code and send the email
        code = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
        VerificationCode.objects.create(user=user, code=code)

        send_mail(
            'Código de verificación',
            f'Tu código de verificación es {code}',
            settings.EMAIL_HOST_USER,
            [user.email],
            fail_silently=False,
        )

        serializer = self.get_serializer(user)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    def patch(self, request):
        user = self.request.user

        # Remove the 'email' field from the request data
        data = request.data.copy()
        data.pop('email', None)

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

        # Check if a default image is provided
        default_image = request.data.get('default_image')
        if default_image:
            default_image_path = os.path.join('uploads/imatges/', default_image)
            user.image.save(default_image_path, ImageFile(open(default_image_path, 'rb')))

        serializer = self.get_serializer(user, data=data, partial=True)
        serializer.is_valid(raise_exception=True)
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

def init_neighborhoods():
    if Neighborhood.objects.exists():
        return
    names = ['Nou Barris', 'Horta-Guinardó', 'Sants-Montjuïc', 'Sarrià-StGervasi',
             'Les Corts', 'Sant Andreu', 'Sant Martí', 'Gràcia', 'Ciutat Vella', 'Eixample']
    neighborhoods_data = [
        {'name': names[i], 'path': f'nhood_{i+1}.glb'} for i in range(len(names))
    ]
    for neighborhood_data in neighborhoods_data:
        Neighborhood.objects.get_or_create(**neighborhood_data)

def init_levels(user):
    points_total = [100, 150, 250, 400, 550, 700, 900, 1100, 1350, 1500]
    for i in range(1, 9):
        neighborhood = Neighborhood.objects.get(path=f'nhood_{i}.glb')
        Level.objects.create (
            number=i,
            completed=False,
            current=(i == 1),
            points_user=0,
            points_total = points_total[i-1],
            user=user,
            neighborhood=neighborhood
        )


@api_view(['POST'])
@permission_classes([AllowAny])
def verify(request):
    code = request.data.get('verificationCode')
    username = request.data.get('username')
    user = User.objects.get(username=username)

    try:
        verification_code = VerificationCode.objects.get(user=user, code=code)
    except VerificationCode.DoesNotExist:
        return Response({"error": "Invalid verification code."}, status=status.HTTP_400_BAD_REQUEST)

    user.is_active = True
    user.save()

    verification_code.delete()

    init_neighborhoods()
    init_levels(user)

    return Response({"message": "Account successfully verified."}, status=status.HTTP_200_OK)

@api_view(['DELETE'])
@permission_classes([AllowAny])
def delete_inactive_user(request):
    username = request.data.get('username')
    try:
        user = User.objects.get(username=username)
        user.delete()
        return Response({"message": f"User {username} deleted successfully."}, status=status.HTTP_200_OK)
    except User.DoesNotExist:
        return Response({"error": "User not found."}, status=status.HTTP_404_NOT_FOUND)
