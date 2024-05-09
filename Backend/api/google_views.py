from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny
from rest_framework_simplejwt.tokens import RefreshToken
import jwt
from .models import User
from .serializers import UserSerializer

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
        name = payload.get('given_name')
        username = email.split('@')[0]

        # Check if a user with this email exists
        user = User.objects.filter(username=username).first()

        if user is None:
            # If the user doesn't exist, create a new user
            user = User.objects.create(email=email, first_name=name, username=username)

        # Generate a JWT token for the user
        refresh = RefreshToken.for_user(user)
        token = {
            'refresh': str(refresh),
            'access': str(refresh.access_token),
        }

        return Response(token, status=status.HTTP_200_OK)
