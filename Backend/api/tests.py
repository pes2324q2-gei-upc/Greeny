"""
This module contains unit tests for the Greeny application.

It includes tests for the Statistics functionality, and for the 
FetchPublicTransportStations methods.
"""
# Standard library imports
import json
import os
from unittest.mock import patch

# Third-party imports
from django.test import TestCase, Client
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework.test import APIRequestFactory, force_authenticate
from django.contrib.gis.geos import Point

# Local application/library specific imports
from api.friend_view import FriendViewSet, FriendRequestViewSet
from api.transports_views import FetchPublicTransportStations
from .models import (User, FriendRequest, Station, PublicTransportStation,
                     Stop, TransportType, Statistics, Route, Review)
from .utils import calculate_co2_consumed, calculate_car_co2_consumed


class FetchPublicTransportStationsTest(TestCase):
    def setUp(self):
        self.client = Client()

    def test_fetch_public_stations_endpoint(self):
        response = self.client.get('/api/fetch-all-stations')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'fetched_successfully', response.content)

    def test_get_type_existing_transport_type(self):
        # Create a sample transport type
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
        self.user = User.objects.create_user(username='testuser', password='testpass')
        self.client.force_authenticate(user=self.user)

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
        self.assertEqual(stats.kg_CO2_consumed, 0.05013 * (100 * 0.3) + 0.08012 * (100 * 0.7))
        self.assertEqual(stats.kg_CO2_car_consumed, 0.143 * 100)
        self.assertEqual(Route.objects.count(), 1)
        self.assertEqual(route.consumed_co2, 0.05013 * (100 * 0.3) + 0.08012 * (100 * 0.7))
        self.assertEqual(route.car_consumed_co2, 0.143 * 100)


    def test_calculate_co2_consumed(self):
        self.assertAlmostEqual(calculate_co2_consumed({'Walking': 100}, 10), 0.0)
        self.assertAlmostEqual(calculate_co2_consumed({'Bike': 100}, 20), 0.0)
        self.assertAlmostEqual(calculate_co2_consumed({'Bus': 100}, 15), 0.08074 * 15)
        self.assertAlmostEqual(calculate_co2_consumed({'Car': 100}, 25), 0.143 * 25)
        self.assertAlmostEqual(calculate_co2_consumed({'Electric Car': 100}, 30), 0.070 * 30)
        self.assertAlmostEqual(calculate_co2_consumed({'Metro': 50, 'Tram': 50}, 40), 0.05013 * 20 + 0.08012 * 20)

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
        request = self.factory.delete(f'/friend-requests/{self.friend_request.id}/')
        force_authenticate(request, user=self.user)
        view = FriendRequestViewSet.as_view({'delete': 'destroy'})
        response = view(request, pk=self.friend_request.id)
        self.assertEqual(response.status_code, 200)

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
            "password": "testpass2"
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
        self.review = Review.objects.create(author=self.user, station=self.station, body='Great station!', puntuation=5.0)
        self.station.refresh_from_db()

    def test_create_review(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.post(f'/api/stations/{self.station.id}/reviews/', {'author': self.user.id, 'station': self.station.id, 'body': 'Good station!', 'puntuation': 4}, format='json')
        self.assertEqual(response.status_code, 201)
        self.assertEqual(Review.objects.count(), 2)
        self.assertEqual(Review.objects.get(id=2).body, 'Good station!')
        self.station.refresh_from_db()
        self.assertEqual(self.station.rating, 4.5)

    def test_get_reviews(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.get(f'/api/stations/{self.station.id}/reviews/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data), 1)
        self.station.refresh_from_db()
        self.assertEqual(self.station.rating, 5)
