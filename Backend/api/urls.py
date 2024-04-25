"""
This module defines the URL routes for the Greeny application.

It includes routes for viewing and manipulating Stations, PublicTransportStations, 
TransportTypes, Stops, BusStations, BicingStations, ChargingStations, Users, and Statistics.

"""
from api.userViews import UserView
from api.statisticsViews import StatisticsView
from api.routesViews import RoutesView
from api.transportsViews import EstacionsBicing, CarregadorsElectricsView, FetchPublicTransportStations, GetStations, ParadesBus
from django.urls import path


urlpatterns = [
    path('charging-points', CarregadorsElectricsView.as_view(), name='charging_points'),
    path('fetch-all-stations', FetchPublicTransportStations.as_view(), name='fetch_all_stations'),
    path('get-stations', GetStations.as_view(), name="get_all_stations"),
    path('bus-stops', ParadesBus.as_view(), name='bus_stops'),
    path('bicing', EstacionsBicing.as_view(), name='bicing'),
    path('send-form-transports', RoutesView.as_view(), name='final_form_transports'),
    path('statistics/', StatisticsView.as_view(), name='stats'),
    path('user/', UserView.as_view(), name='users'),
]
