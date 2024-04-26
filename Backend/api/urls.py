# Django imports
from django.urls import path, include

# Third-party imports
from rest_framework.routers import DefaultRouter

# Local application/library specific imports
from api.userViews import UserView
from api.statisticsViews import StatisticsView
from api.transports_views import (
    EstacionsBicing,
    CarregadorsElectricsView,
    FetchPublicTransportStations,
    GetStations,
    ParadesBus
)
from api.friend_view import FriendRequestViewSet, FriendViewSet

router = DefaultRouter()
router.register(r'friend-requests', FriendRequestViewSet, basename='friend-requests')
router.register(r'friends', FriendViewSet, basename='friend')

urlpatterns = [
    path('', include(router.urls)),
    path('charging-points', CarregadorsElectricsView.as_view(), name='charging_points'),
    path('fetch-all-stations', FetchPublicTransportStations.as_view(), name='fetch_all_stations'),
    path('get-stations', GetStations.as_view(), name="get_all_stations"),
    path('bus-stops', ParadesBus.as_view(), name='bus_stops'),
    path('bicing', EstacionsBicing.as_view(), name='bicing'),
    path('send-form-transports', StatisticsView.as_view(), name='final_form_transports'),
    path('statistics/', StatisticsView.as_view(), name='stats'),
    path('user/', UserView.as_view(), name='users'),

]
