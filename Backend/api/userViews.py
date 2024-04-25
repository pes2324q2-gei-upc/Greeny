# pylint: disable=no-member
import requests
from django.shortcuts import redirect
from django.http import JsonResponse
from django.views import View
from rest_framework import generics
import os
from .models import *
from .serializers import *
import json
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework import status
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated
from rest_framework.exceptions import AuthenticationFailed
from rest_framework.permissions import AllowAny
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.authentication import JWTAuthentication

class UserView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

    def get_permissions(self):
        if self.request.method == 'POST':
            self.permission_classes = [AllowAny]
        else:
            self.permission_classes = [IsAuthenticated]
        return super(UserView, self).get_permissions()

    def get(self, request):
        user = self.request.user
        
        serializer = UserSerializer(user)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid(raise_exception=ValueError):
            serializer.create(validated_data=request.data)
            return Response(
                serializer.data,
                status=status.HTTP_201_CREATED
            )
        return Response(
            {
                "error": True,
                "error_msg": serializer.error_messages,
            },
            status=status.HTTP_400_BAD_REQUEST
        )
    
    def patch(self, request):
        token_auth = TokenAuthentication()
        try:
            user, token = token_auth.authenticate(request)
        except AuthenticationFailed:
            return JsonResponse({'error': 'Invalid token'}, status=401)
        
        serializer = UserSerializer(user, data=request.data, partial=True)
        if serializer.is_valid(raise_exception=ValueError):
            serializer.update(instance=user, validated_data=request.data)
            return Response(
                serializer.data,
                status=status.HTTP_200_OK
            )
        return Response(
            {
                "error": True,
                "error_msg": serializer.error_messages,
            },
            status=status.HTTP_400_BAD_REQUEST
        )
    
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
        
