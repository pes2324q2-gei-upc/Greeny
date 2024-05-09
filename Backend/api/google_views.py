from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import status
from .models import User
from .serializers import UserSerializer

def GoogleAuth(APIView):
    serializer_class = UserSerializer

    def post(self, request):
        
    