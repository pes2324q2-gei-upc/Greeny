from api.user_views import UsersView
from api.statisticsViews import StatisticsView
from api.transportsViews import EstacionsBicing, CarregadorsElectricsView, FetchPublicTransportStations
from api.transportsViews import ParadesBus, StationsView
from django.urls import path, include
from api.friend_view import FriendRequestViewSet, FriendViewSet
from api.review_views import ReviewsViews
from rest_framework.routers import DefaultRouter

router = DefaultRouter()

router.register(r'friend-requests', FriendRequestViewSet, basename='friend-requests')
router.register(r'friends', FriendViewSet, basename='friend')
router.register(r'stations/(?P<station_id>\d+)/reviews', ReviewsViews, basename='station-reviews')
router.register(r'user', UsersView, basename="reviews")

urlpatterns = [
    path('', include(router.urls)),
    path('charging-points', CarregadorsElectricsView.as_view(), name='charging_points'),
    path('fetch-all-stations', FetchPublicTransportStations.as_view(), name='fetch_all_stations'),
    path('bus-stops', ParadesBus.as_view(), name='bus_stops'),
    path('bicing', EstacionsBicing.as_view(), name='bicing'),
    path('send-form-transports', StatisticsView.as_view(), name='final_form_transports'),
    path('statistics/', StatisticsView.as_view(), name='stats'),
    path('stations/<int:pk>', StationsView.as_view(), name='stations'),
    path('stations/', StationsView.as_view(), name='stations_list')
]