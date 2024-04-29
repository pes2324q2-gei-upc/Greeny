# Django imports
from django.urls import path, include

# Third-party imports
from rest_framework.routers import DefaultRouter

# Local application/library specific imports
from api.user_views import UsersView
from api.statistics_views import StatisticsView
from api.review_views import ReviewsViews
from api.transports_views import (
    EstacionsBicing,
    CarregadorsElectricsView,
    FetchPublicTransportStations,
    ParadesBus,
    StationsView,
    ThirdPartyChargingStationInfoView
)
from api.friend_view import FriendRequestViewSet, FriendViewSet
from api.routes_views import RoutesView
from api.city_views import CityView


router = DefaultRouter()

router.register(r'friend-requests', FriendRequestViewSet, basename='friend-requests')
router.register(r'friends', FriendViewSet, basename='friend')
router.register(r'stations/(?P<station_id>\d+)/reviews', ReviewsViews, basename='station-reviews')
router.register(r'user', UsersView, basename="user")
router.register(r'statistics', StatisticsView, basename="statistics")

urlpatterns = [
    path('', include(router.urls)),
    path('charging-points', CarregadorsElectricsView.as_view(), name='charging_points'),
    path('fetch-all-stations', FetchPublicTransportStations.as_view(), name='fetch_all_stations'),
    path('bus-stops', ParadesBus.as_view(), name='bus_stops'),
    path('bicing', EstacionsBicing.as_view(), name='bicing'),
    path('send-form-transports', RoutesView.as_view(), name='final_form_transports'),
    path('routes', RoutesView.as_view(), name='routes'),
    path('stations/<int:pk>', StationsView.as_view(), name='stations'),
    path('stations/', StationsView.as_view(), name='stations_list'),
    path('city/', CityView.as_view(), name='city'),
    path('charging-station-info', ThirdPartyChargingStationInfoView.as_view(), name='charging_station_info')
]
