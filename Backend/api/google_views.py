from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny
from rest_framework_simplejwt.tokens import RefreshToken
import requests
from django.core.files.base import ContentFile
import jwt
from .models import User
from .serializers import UserSerializer
from .user_views import UsersView

class GoogleAuth(APIView):
    serializer_class = UserSerializer
    permission_classes = [AllowAny]

    def post(self, request):
        # Get the Google token from the request data
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
                view = UsersView()
                view.init_neighborhoods()
                view.init_levels(user)

        # Generate a JWT token for the user
        refresh = RefreshToken.for_user(user)
        info = {
            'refresh': str(refresh),
            'access': str(refresh.access_token),
            'username': user.username,
        }

        return Response(info, status=status.HTTP_200_OK)
