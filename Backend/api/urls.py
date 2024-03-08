from api import views
from django.urls import path


urlpatterns = [
    path('carregadors-electrics', views.CarregadorsElectricsView.as_view(), name='carregadors-electrics'),
]