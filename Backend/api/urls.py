from api.views import *
from django.urls import path


urlpatterns = [
    path('charging-points', CarregadorsElectricsView.as_view(), name='carregadors-electrics'),
    path('fetch-stations', FetchPublicTransportStations.as_view(), name='estacions'),
    path('get-stations', GetStations.as_view(), name="get-all-stations"),
    #path('parades-metro', getParadesMetro, name='parades-metro'),
    path('parades-bus', ParadesBus.as_view(), name='parades-bus'),
    path('bicing', EstacionsBicing.as_view(), name='bicing')
]