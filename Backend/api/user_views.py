import os
import random
import string
import jwt
import requests

from django.contrib.auth.hashers import check_password
from django.contrib.auth.hashers import make_password
from django.core.files.images import ImageFile
from django.core.files.base import ContentFile
from django.core.mail import send_mail

from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.decorators import permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet
from rest_framework_simplejwt.tokens import RefreshToken

from .models import User, Neighborhood, Level, VerificationCode, Blacklist

from .serializers import UserSerializer

class UsersView(ModelViewSet):
    serializer_class = UserSerializer

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
        for i in range(1, 11):
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
    def reset_levels(self, user):
        Level.objects.filter(user=user).delete()
        self.init_levels(user)

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated_data = serializer.validated_data

        validated_data['is_active'] = False
        banned = Blacklist.objects.filter(email=validated_data['email']).exists()
        if not banned:
            user = User.objects.create_user(**validated_data)
        else:
            return Response({'message':'You are banned from this application for violating our guidelines'},
                            status=status.HTTP_403_FORBIDDEN)

        send_verification_email(user)

        serializer = self.get_serializer(user)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    def patch(self, request):
        user = self.request.user

        # Check if an image is provided
        image = request.data.get('image')

        # Remove the 'email' field from the request data
        data = request.data.dict()
        data.pop('email', None)
        data.pop('image', None)

        if image:
            # Delete the old image file
            if user.image:
                if os.path.isfile(user.image.path):
                    os.remove(user.image.path)
            # Create a new instance of the image file
            image_copy = ContentFile(image.read())
            # Reset the file pointer of the original image
            image.seek(0)
            # Save the copy of the image to the user's image field
            user.image.save(image.name, image_copy)

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
            # Delete the old image file
            if user.image:
                if os.path.isfile(user.image.path):
                    os.remove(user.image.path)
            default_image_path = os.path.join('uploads/imatges/', default_image)
            with open(default_image_path, 'rb') as f:
                user.image.save(default_image_path, ImageFile(f))

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

#Method to generate and send the verification code for signing up or for password reset
def send_verification_email(user):
    # Generate the verification code
    code = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
    VerificationCode.objects.create(user=user, code=code)

    send_mail(
        'Código de verificación',
        f'Tu código de verificación es {code}',
        'Greeny <greenyPES@gmail.com>',
        [user.email],
        fail_silently=False,
    )
    return code

#Method to get and delete the verification code
def get_and_delete_verification_code(user, code):
    try:
        verification_code = VerificationCode.objects.get(user=user, code=code)
    except VerificationCode.DoesNotExist:
        return None

    verification_code.delete()
    return verification_code

#Methods to verify the code while signing up and canceling the registration [SIGN UP SITUATION]
@api_view(['POST'])
@permission_classes([AllowAny])
def verify_registration(request):
    code = request.data.get('verificationCode')
    username = request.data.get('username')
    user = User.objects.get(username=username)

    verification_code = get_and_delete_verification_code(user, code)
    if verification_code is None:
        return Response({"error": "Invalid verification code."}, status=status.HTTP_400_BAD_REQUEST)

    user.is_active = True
    user.save()

    init_neighborhoods()
    init_levels(user)

    return Response({"message": "Account successfully verified."}, status=status.HTTP_200_OK)

@api_view(['DELETE'])
@permission_classes([AllowAny])
def cancel_registration(request):
    username = request.data.get('username')
    try:
        user = User.objects.get(username=username)
        user.delete()
        return Response(
            {"message": f"User {username} deleted successfully."},
            status=status.HTTP_200_OK
        )
    except User.DoesNotExist:
        return Response({"error": "User not found."}, status=status.HTTP_404_NOT_FOUND)

# Methods for sending the email to an existent user who has forgotten his password,
# for verifying the code and updating the password [FORGOT PASSWORD SITUATION]
@api_view(['POST'])
@permission_classes([AllowAny])
def forgot_password(request):
    email = request.data.get('email')

    try:
        user = User.objects.get(email=email)
    except User.DoesNotExist:
        return Response({"error": "User not found."}, status=status.HTTP_404_NOT_FOUND)

    send_verification_email(user)

    return Response({"message": "Password reset email sent."}, status=status.HTTP_200_OK)

@api_view(['POST'])
@permission_classes([AllowAny])
def verify_forgotten_password(request):
    code = request.data.get('verificationCode')
    email = request.data.get('email')
    user = User.objects.get(email=email)

    verification_code = get_and_delete_verification_code(user, code)
    if verification_code is None:
        return Response({"error": "Invalid verification code."}, status=status.HTTP_400_BAD_REQUEST)

    return Response({"message": "Account successfully verified."}, status=status.HTTP_200_OK)

@api_view(['POST'])
@permission_classes([AllowAny])
def reset_password(request):
    email = request.data.get('email')
    new_password = request.data.get('new_password')

    try:
        user = User.objects.get(email=email)
    except User.DoesNotExist:
        return Response({"error": "User not found."}, status=status.HTTP_404_NOT_FOUND)

    user.set_password(new_password)
    user.save()

    return Response({"message": "Password reset successfully."}, status=status.HTTP_200_OK)

# Method to authenticate the user with Google
@api_view(['POST'])
@permission_classes([AllowAny])
def google_auth(request):
    google_token = request.data.get('token')

    # Decode the Google token
    try:
        payload = jwt.decode(google_token, options={"verify_signature": False})
    except jwt.InvalidTokenError:
        return Response({'error': 'Invalid token'}, status=status.HTTP_400_BAD_REQUEST)

    # Get the user's data from the token payload
    email = payload.get('email')
    name = payload.get('name')
    username = email.split('@')[0]
    picture = payload.get('picture')

    # Check if a user with this email exists
    user = User.objects.filter(email=email).first()

    if user is None:
        # If the user doesn't exist, create a new user
        response = requests.get(picture, timeout=5)
        if response.status_code == 200:
            image_content = ContentFile(response.content)
            image_filename = f'{username}.jpg'
            user = User.objects.create(email=email, first_name=name, username=username)
            user.image.save(image_filename, image_content, save=True)
            init_neighborhoods()
            init_levels(user)

    # Generate a JWT token for the user
    refresh = RefreshToken.for_user(user)
    info = {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
        'username': user.username,
    }

    return Response(info, status=status.HTTP_200_OK)

@api_view(['POST'])
@permission_classes([AllowAny])
def obtain_token(request):
    username = request.data.get('username')
    password = request.data.get('password')

    user = User.objects.filter(username=username).first()

    if user is None or not check_password(password, user.password):
        return Response({'error': 'Invalid username or password'}, status=status.HTTP_400_BAD_REQUEST)

    if user.is_active == False:
        return Response({'error': 'User is banned'}, status=status.HTTP_401_UNAUTHORIZED)

    refresh = RefreshToken.for_user(user)
    info = {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }

    return Response(info, status=status.HTTP_200_OK)