"""
This module contains unit tests for the Greeny application.

It includes tests for the Statistics functionality, and for the 
FetchPublicTransportStations methods.
"""
# Standard library imports
import json

# Third-party imports
from django.test import TestCase
from django.urls import reverse
from django.contrib.gis.geos import Point
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework.test import APIRequestFactory, force_authenticate

# Local application/library specific imports
from api.friend_view import FriendViewSet, FriendRequestViewSet
from api.transports_views import FetchPublicTransportStations
from .models import (User, FriendRequest, Station, PublicTransportStation,
                        TransportType, Statistics, Route, Review, Neighborhood, Level, CO2Consumed)
from .utils import calculate_co2_consumed, calculate_car_co2_consumed
from .user_views import init_neighborhoods, init_levels

class FetchPublicTransportStationsTest(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_get_type_existing_transport_type(self):
        existing_type = TransportType.objects.create(type='Metro')
        fetcher = FetchPublicTransportStations()
        fetched_type = fetcher.get_type('Metro')
        self.assertEqual(existing_type, fetched_type)

    def test_get_type_new_transport_type(self):
        fetcher = FetchPublicTransportStations()
        new_type = fetcher.get_type('Tram')
        self.assertIsInstance(new_type, TransportType)
        self.assertEqual(new_type.type, 'Tram')

    def test_create_public_transport_station(self):
        fetcher = FetchPublicTransportStations()
        station_data = {
            'LATITUD': 41.1234,
            'LONGITUD': 2.5678
        }
        new_station = fetcher.create_public_transport_station(station_data, 'Test Station')
        self.assertIsInstance(new_station, PublicTransportStation)
        self.assertEqual(new_station.name, 'Test Station')

class FinalFormTransports(TestCase):

    def setUp(self):
        self.client = APIClient()
        user_data = {
            "username": "alba",
            "password": "password123",
            "email": "alba@upc.es",
            "first_name": "alba"
        }
        response = self.client.post('/api/user/', user_data)
        self.assertEqual(response.status_code, 201)
        self.user = User.objects.get(username='alba')
        init_neighborhoods()
        init_levels(self.user)
        self.client.force_authenticate(user=self.user)
        self.co2_consumed = CO2Consumed.objects.create(
            kg_CO2_walking_biking_consumed=0.0,
            kg_CO2_bus_consumed=0.08074,
            kg_CO2_motorcycle_consumed=0.053,
            kg_CO2_car_gasoline_consumed=0.143,
            kg_CO2_electric_car_consumed=0.070,
            kg_CO2_metro_consumed=0.05013,
            kg_CO2_tram_consumed=0.08012,
            kg_CO2_fgc_consumed=0.03577,
            kg_CO2_train_consumed=0.04688
        )

    def test_post_success(self):
        data = {
            'transportPercentages': {'Walking': 33.33, 'Bus': 33.33, 'Bike': 33.34},
            'totalDistance': 100,
            'startedAt': '2024-04-25T16:33:14.90961'
        }
        response = self.client.post(reverse('final_form_transports'),
                                    data=json.dumps(data), content_type='application/json')

        self.assertEqual(response.status_code, 200)
        self.assertEqual(Route.objects.count(), 1)
        self.assertEqual(Statistics.objects.count(), 1)

    def test_data_statistics(self):
        data = {
            'transportPercentages': {'Walking': 40, 'Bus': 30, 'Bike': 15, 'Motorcycle': 15},
            'totalDistance': 100,
            'startedAt': '2024-04-25T16:33:14.90961'
        }

        self.client.post(reverse('final_form_transports'), data=json.dumps(data),
                         content_type='application/json')

        self.assertEqual(Statistics.objects.count(), 1)
        self.assertEqual(Statistics.objects.get().km_Walked, 40)
        self.assertEqual(Statistics.objects.get().km_Bus, 30)
        self.assertEqual(Statistics.objects.get().km_Biked, 15)
        self.assertEqual(Statistics.objects.get().km_Motorcycle, 15)

    def test_statics_km_totals(self):
        data1 = {
            'transportPercentages': {'Walking': 33.33, 'Bus': 33.33, 'Bike': 33.34},
            'totalDistance': 100,
            'startedAt': '2024-04-25T16:33:14.90961'
        }

        data2 = {
            'transportPercentages': {'Train': 20, 'Bike': 80},
            'totalDistance': 43.5,
            'startedAt': '2024-04-25T16:33:14.90961'
        }

        data3 = {
            'transportPercentages': {},
            'totalDistance': 2,
            'startedAt': '2024-04-25T16:33:14.90961'
        }

        self.client.post(reverse('final_form_transports'), data=json.dumps(data1),
                         content_type='application/json')

        self.client.post(reverse('final_form_transports'), data=json.dumps(data2),
                         content_type='application/json')

        self.client.post(reverse('final_form_transports'), data=json.dumps(data3),
                         content_type='application/json')

        self.assertEqual(Statistics.objects.count(), 1)
        self.assertEqual(Statistics.objects.get().km_Totals, 145.5)

    def test_two_routes(self):
        data = {
            'transportPercentages': {'Walking': 50, 'Bus': 50},
            'totalDistance': 150.70,
            'startedAt': '2024-04-25T16:33:14.90961'
        }

        self.client.post(reverse('final_form_transports'), data=json.dumps(data),
                         content_type='application/json')

        self.assertEqual(Route.objects.count(), 1)
        self.assertEqual(Statistics.objects.count(), 1)

        self.client.post(reverse('final_form_transports'), data=json.dumps(data),
                         content_type='application/json')

        self.assertEqual(Route.objects.count(), 2)
        self.assertEqual(Statistics.objects.count(), 1)

    def test_not_answering_form(self):
        data = {
            'transportPercentages': {},
            'totalDistance': 100,
            'startedAt': '2024-04-25T16:33:14.90961'
        }

        self.client.post(reverse('final_form_transports'), data=json.dumps(data),
                         content_type='application/json')

        self.assertEqual(Route.objects.count(), 1)
        self.assertEqual(Statistics.objects.count(), 1)
        self.assertEqual(Statistics.objects.get().km_Walked, 0)
        self.assertEqual(Statistics.objects.get().km_Bus, 0)
        self.assertEqual(Statistics.objects.get().km_Biked, 0)
        self.assertEqual(Statistics.objects.get().km_Motorcycle, 0)
        self.assertEqual(Statistics.objects.get().km_Car, 0)
        self.assertEqual(Statistics.objects.get().km_PublicTransport, 0)
        self.assertEqual(Statistics.objects.get().km_ElectricCar, 0)
        self.assertEqual(Statistics.objects.get().km_Totals, 100)

    def test_co2_consumed(self):
        data = {
            'transportPercentages': {'Metro': 30, 'Tram': 70},
            'totalDistance': 100,
            'startedAt': '2024-04-25T16:33:14.90961'
        }

        self.client.post(reverse('final_form_transports'), data=json.dumps(data),
                         content_type='application/json')

        stats = Statistics.objects.get()
        route = Route.objects.get()

        self.assertEqual(Statistics.objects.count(), 1)
        self.assertAlmostEqual(stats.kg_CO2_consumed, 0.05013 * (100 * 0.3) + 0.08012 * (100 * 0.7))
        self.assertAlmostEqual(stats.kg_CO2_car_consumed, 0.143 * 100)
        self.assertEqual(Route.objects.count(), 1)
        self.assertAlmostEqual(route.consumed_co2, 0.05013 * (100 * 0.3) + 0.08012 * (100 * 0.7))
        self.assertAlmostEqual(route.car_consumed_co2, 0.143 * 100)

    def test_calculate_co2_consumed(self):
        self.assertAlmostEqual(calculate_co2_consumed({'Walking': 100}, 10), 0.0)
        self.assertAlmostEqual(calculate_co2_consumed({'Bike': 100}, 20), 0.0)
        self.assertAlmostEqual(calculate_co2_consumed({'Bus': 100}, 15), 0.08074 * 15)
        self.assertAlmostEqual(calculate_co2_consumed({'Car': 100}, 25), 0.143 * 25)
        self.assertAlmostEqual(calculate_co2_consumed({'Electric Car': 100}, 30), 0.070 * 30)
        self.assertAlmostEqual(calculate_co2_consumed({'Metro': 50, 'Tram': 50}, 40),
                               0.05013 * 20 + 0.08012 * 20)

    def test_calculate_car_co2_consumed(self):
        self.assertAlmostEqual(calculate_car_co2_consumed(20), 0.143 * 20)
        self.assertAlmostEqual(calculate_car_co2_consumed(30), 0.143 * 30)
        self.assertAlmostEqual(calculate_car_co2_consumed(40), 0.143 * 40)

class FriendRequestViewSetTest(TestCase):
    def setUp(self):
        self.factory = APIRequestFactory()
        self.user = User.objects.create(username='testuser', email='testuser@mail.com')
        self.friend = User.objects.create(username='friend', email='uwu@mail.com')
        self.friend_request = FriendRequest.objects.create(from_user=self.friend, to_user=self.user)

    def test_create_friend_request(self):
        request = self.factory.post('/friend-requests/', {'to_user': self.friend.id})
        force_authenticate(request, user=self.user)
        view = FriendRequestViewSet.as_view({'post': 'create'})
        response = view(request)
        self.assertEqual(response.status_code, 200)

    def test_list_friend_requests(self):
        request = self.factory.get('/friend-requests/')
        force_authenticate(request, user=self.user)
        view = FriendRequestViewSet.as_view({'get': 'list'})
        response = view(request)
        self.assertEqual(response.status_code, 200)

    def test_accept_friend_request(self):
        data = {'accept': 'true'}
        request = self.factory.delete(f'/friend-requests/{self.friend_request.id}/', data=data)
        force_authenticate(request, user=self.user)
        view = FriendRequestViewSet.as_view({'delete': 'destroy'})
        response = view(request, pk=self.friend_request.id)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['message'], 'Friend request accepted')

    def test_deny_friend_request(self):
        data = {'accept': 'false'}
        request = self.factory.delete(f'/friend-requests/{self.friend_request.id}/', data=data)
        force_authenticate(request, user=self.user)
        view = FriendRequestViewSet.as_view({'delete': 'destroy'})
        response = view(request, pk=self.friend_request.id)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['message'], 'Friend request not accepted')

class FriendViewSetTest(TestCase):
    def setUp(self):
        self.factory = APIRequestFactory()
        self.user = User.objects.create(username='testuser', email='testuser@mail.com')
        self.friend = User.objects.create(username='friend', email='uwu@mail.com')
        self.user.friends.add(self.friend)

    def test_list_friends(self):
        request = self.factory.get('/friends/')
        force_authenticate(request, user=self.user)
        view = FriendViewSet.as_view({'get': 'list'})
        response = view(request)
        self.assertEqual(response.status_code, 200)

    def test_remove_friend(self):
        request = self.factory.delete(f'/friends/{self.friend.pk}/')
        force_authenticate(request, user=self.user)
        view = FriendViewSet.as_view({'delete': 'destroy'})
        response = view(request, pk=self.friend.pk)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertNotIn(self.friend, self.user.friends.all())

    def test_remove_nonexistent_friend(self):
        request = self.factory.delete('/friends/9999/')
        force_authenticate(request, user=self.user)
        view = FriendViewSet.as_view({'delete': 'destroy'})
        response = view(request, pk=9999)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_remove_non_friend(self):
        non_friend = User.objects.create(username='nonfriend', email='nonfriend@mail.com')
        request = self.factory.delete(f'/friends/{non_friend.pk}/')
        force_authenticate(request, user=self.user)
        view = FriendViewSet.as_view({'delete': 'destroy'})
        response = view(request, pk=non_friend.pk)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_remove_friend_when_no_friends(self):
        user_without_friends = User.objects.create_user(username='user3', password='pass')
        request = self.factory.delete(f'/friends/{self.friend.pk}/')
        force_authenticate(request, user=user_without_friends)
        view = FriendViewSet.as_view({'delete': 'destroy'})
        response = view(request, pk=self.friend.pk)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

class UsersViewTestCase(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(username='testuser', password='testpass')
        self.client.force_authenticate(user=self.user)

    def test_get_queryset(self):
        response = self.client.get('/api/user/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data[0]['username'], 'testuser')

    def test_create_user(self):
        data = {
            "username": "testuser2",
            "password": "testpass2",
            "email": "test@test.test"
        }
        response = self.client.post('/api/user/', data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(User.objects.count(), 2)
        self.assertEqual(User.objects.get(username='testuser2').username, 'testuser2')

class TestReviewsViews(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(username='testuser', password='12345')
        point = Point(74.0060, 40.7128)
        self.station = Station.objects.create(name='Test Station', location = point, rating=5.0)
        self.review = Review.objects.create(
            author=self.user,
            station=self.station,
            body='Great station!',
            puntuation=5.0
        )
        self.station.refresh_from_db()

    def test_create_review(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.post(
            f'/api/stations/{self.station.id}/reviews/',
            {
                'author': self.user.id,
                'station': self.station.id,
                'body': 'Good station!',
                'puntuation': 4
            },
            format='json'
        )
        self.assertEqual(response.status_code, 201)
        self.assertEqual(Review.objects.count(), 2)
        self.assertEqual(Review.objects.get(body='Good station!').body, 'Good station!')
        self.station.refresh_from_db()
        self.assertEqual(self.station.rating, 4.5)

    def test_get_reviews(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.get(f'/api/stations/{self.station.id}/reviews/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data), 1)
        self.station.refresh_from_db()
        self.assertEqual(self.station.rating, 5)

class CityViewTest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(username='testuser', password='12345')
        self.neighborhood = Neighborhood.objects.create(
            name='Test Neighborhood',
            path='nhood_1.glb'
        )
        self.level = Level.objects.create(
            number=1,
            completed=False,
            current=True,
            points_user=0,
            points_total=100,
            user=self.user,
            neighborhood=self.neighborhood
        )
        self.client.force_authenticate(user=self.user)

    def test_get(self):
        response = self.client.get(reverse('city'))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['number'], self.level.number)
        self.assertEqual(response.data['completed'], self.level.completed)
        self.assertEqual(response.data['current'], self.level.current)
        self.assertEqual(response.data['points_user'], self.level.points_user)
        self.assertEqual(response.data['points_total'], self.level.points_total)
        self.assertEqual(response.data['user_name'], self.user.first_name)
        self.assertEqual(response.data['is_staff'], self.user.is_staff)
        self.assertEqual(response.data['neighborhood']['name'], self.neighborhood.name)
        self.assertEqual(response.data['neighborhood']['path'], self.neighborhood.path)

    def test_put(self):
        data = {'points_user': 50}
        response = self.client.put(reverse('city'), data, format='json')
        self.level.refresh_from_db()
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(self.level.points_user, 50)
        self.assertEqual(response.data['points_user'], data['points_user'])

    def test_unauthorized_access(self):
        unauthenticated_client = APIClient()
        response = unauthenticated_client.get(reverse('city'))
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)



class ProfanityFilterTest(TestCase):
    def setUp(self):
        self.client = APIClient()
        location = Point(0, 0)  # replace with actual longitude and latitude
        self.station = Station.objects.create(name='Station1', location=location, rating=0)

        self.user = User.objects.create(username='user1', password='pass',
                                        email='aaa@gmail.com')
        self.review = Review.objects.create(author=self.user, station=self.station,
                                            body='Test review completely harmless', puntuation=5)
        self.review2 = Review.objects.create(author=self.user, station=self.station,
                                            body='Test review 2', puntuation=5)
        self.url = reverse('profanity-filter',
                           kwargs={'station_id': self.station.id, 'review_id': self.review.id})
        self.client.force_authenticate(user=self.user)
    def test_no_profanity(self):
        self.review.body = "This station is perfect, no problem at all!"
        self.review.save()
        response = self.client.post(self.url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data, {'message': 'No profanity detected'})

    def test_profanity_no_previous_reports(self):
        self.review.body = 'This station is very shit!'
        self.review.save()
        response = self.client.post(self.url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data, {'message': 'Review has been deleted due to profanity'})

    def test_profanity_with_previous_reports(self):
        self.review.author.reports = 2
        self.review.author.save()
        self.review.body = 'This station is shit!'
        self.review.save()
        response = self.client.post(self.url)
        self.assertEqual(response.status_code, status.HTTP_200_LOCKED)
        self.assertEqual(response.data, {'message': 'User has been banned'})

    def test_non_english_review(self):
        self.review.body = 'Mierda de estacion!'
        self.review.save()
        response = self.client.post(self.url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data, {'message': 'Review has been deleted due to profanity'})
