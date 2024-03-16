from api.views import *
from django.urls import path


urlpatterns = [
    path('charging-points', CarregadorsElectricsView.as_view(), name='charging_points'),
    path('fetch-all-stations', FetchPublicTransportStations.as_view(), name='fetch_all_stations'),
    path('get-stations', GetStations.as_view(), name="get_all_stations"),
    path('test', TestView.as_view(), name='test_view'),
    path('bus-stops', ParadesBus.as_view(), name='bus_stops'),
    path('bicing', EstacionsBicing.as_view(), name='bicing')
]