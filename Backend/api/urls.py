from api import views
from django.urls import path


urlpatterns = [
    path('carregadors-electrics', views.CarregadorsElectricsView.as_view(), name='carregadors-electrics'),
    path('estacions', views.FetchEstacionsTransportPublic.as_view(), name='estacions'),
    path('parades-metro', views.getParadesMetro, name='parades-metro'),
    path('parades-bus', views.ParadesBus.as_view(), name='parades-bus'),
    path('bicing', views.EstacionsBicing.as_view(), name='bicing')
]