from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework.permissions import AllowAny
from rest_framework.viewsets import ModelViewSet
from .models import User
from .serializers import UserSerializer


class UsersView(ModelViewSet):
    serializer_class = UserSerializer
    queryset = User.objects.all()
    permission_classes = [AllowAny]
    authentication_classes = [JWTAuthentication]

    def get_queryset(self):
        user = self.request.user
        return User.objects.filter(id=user.id)
