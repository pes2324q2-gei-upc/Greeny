from api.views import *
from django.urls import path


urlpatterns = [
    path('charging-points', CarregadorsElectricsView.as_view(), name='charging_points'),
    path('fetch-all-stations', FetchPublicTransportStations.as_view(), name='fetch_all_stations'),
    path('get-stations', GetStations.as_view(), name="get_all_stations"),
    path('test', TestView.as_view(), name='test_view'),
    path('bus-stops', ParadesBus.as_view(), name='bus_stops'),
    path('bicing', EstacionsBicing.as_view(), name='bicing'),
    path('send-form-transports', FinalFormTransports.as_view(), name='final_form_transports'),
    path('statistics/', StatsView.as_view(), name='stats'),
    path('user/', UserView.as_view(), name='users'),
    path('send-friend-request/<int:userID>/', send_friend_request, name="send friend request"),
    path('accept-friend-request/<int:requestID>/', accept_friend_request, name="accept friend request"),
    path('retrive_friend_requests', retrieve_friend_requests, name='retrive_friend_requests'),
    path('get-friends', get_friends, name='get friends')

]