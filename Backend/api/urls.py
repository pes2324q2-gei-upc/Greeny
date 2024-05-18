# Django imports
from django.urls import path, include

# Third-party imports
from rest_framework.routers import DefaultRouter

# Local application/library specific imports
from api.user_views import UsersView, verify, delete_inactive_user
from api.statistics_views import StatisticsView
from api.review_views import ReviewsViews
from api.transports_views import (
    FetchPublicTransportStations,
    StationsView,
    ThirdPartyChargingStationInfoView
)
from api.friend_view import FriendRequestViewSet, FriendViewSet
from api.routes_views import RoutesView
from api.city_views import CityView
from api.ping_view import ping

router = DefaultRouter()

router.register(r'friend-requests', FriendRequestViewSet, basename='friend-requests')
router.register(r'friends', FriendViewSet, basename='friend')
router.register(r'stations/(?P<station_id>\d+)/reviews', ReviewsViews, basename='station-reviews')
router.register(r'user', UsersView, basename="user")
router.register(r'statistics', StatisticsView, basename="statistics")

urlpatterns = [
    path('', include(router.urls)),
    path('fetch-all-stations', FetchPublicTransportStations.as_view(), name='fetch_all_stations'),
    path('send-form-transports', RoutesView.as_view(), name='final_form_transports'),
    path('routes', RoutesView.as_view(), name='routes'),
    path('stations/<int:pk>', StationsView.as_view(), name='stations'),
    path('stations/', StationsView.as_view(), name='stations_list'),
    path('city/', CityView.as_view(), name='city'),
    path('charging-station-info', ThirdPartyChargingStationInfoView.as_view(),
         name='charging_station_info'),
    path('ping', ping, name='ping'),
    path('user/<str:username>/', UsersView.as_view({'get': 'retrieve'}), name='user-detail'),
    path('verify/', verify, name='verify'),
    path('delete_inactive_user/', delete_inactive_user, name='delete_inactive_user'),
]
