# Django imports
from django.urls import path, include

# Third-party imports
from rest_framework.routers import DefaultRouter

# Local application/library specific imports
from api.user_views import (UsersView, verify_registration, cancel_registration, google_auth,
                            forgot_password, verify_forgotten_password, reset_password, obtain_token, refresh_token)
from api.statistics_views import StatisticsView
from api.review_views import ReviewsViews, profanity_filter
from api.transports_views import (
    FetchPublicTransportStations,
    StationsView,
    ThirdPartyChargingStationInfoView
)
from api.friend_view import FriendRequestViewSet, FriendViewSet
from api.routes_views import RoutesView
from api.city_views import CityView, NeighborhoodsView
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
    path('neighborhoods/', NeighborhoodsView.as_view(), name='neighborhoods'),
    path('charging-station-info', ThirdPartyChargingStationInfoView.as_view(),
         name='charging_station_info'),
    path('ping', ping, name='ping'),
    path('user/<str:username>/', UsersView.as_view({'get': 'retrieve'}), name='user-detail'),
    path('stations/<int:station_id>/reviews/<int:review_id>/profanity-filter', 
         profanity_filter, name='profanity-filter'),
    path('token/', obtain_token, name='token_obtain_pair'),
    path('token/refresh/', refresh_token, name='token_refresh'),
    path('verify_registration/', verify_registration, name='verify_registration'),
    path('cancel_registration/', cancel_registration, name='cancel_registration'),
    path('oauth2/', google_auth, name='google_oauth'),
    path('forgot_password/', forgot_password, name='forgot_password'),
    path('verify_forgotten_password/', verify_forgotten_password, name='verify_forgotten_password'),
    path('reset_password/', reset_password, name='reset_password')
]
