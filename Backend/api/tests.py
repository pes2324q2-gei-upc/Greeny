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
from rest_framework.test import APIRequestFactory, force_authenticate

# Local application/library specific imports
from api.friend_view import FriendViewSet, FriendRequestViewSet
from .models import (User, FriendRequest, Station, PublicTransportStation,
                     Stop, TransportType, Statistics)

class FetchPublicTransportStationsTest(TestCase):
    def setUp(self):
        self.client = Client()
        self.url = reverse("fetch_all_stations")  # replace with the actual URL name for the view

    def test_get(self):
        response = self.client.get(self.url, follow=True)
        self.assertEqual(response.status_code, 200)

        self.assertEqual(response.redirect_chain[0][0], '/api/bus-stops')
        self.assertEqual(response.redirect_chain[0][1], 302)

        self.assertEqual(response.redirect_chain[1][0], '/api/bicing')
        self.assertEqual(response.redirect_chain[1][1], 302)

        self.assertEqual(response.redirect_chain[2][0], '/api/charging-points')
        self.assertEqual(response.redirect_chain[2][1], 302)

    @patch('requests.get')
    def test_parse_api_data(self, mock_get):

        mock_get.return_value.status_code = 200

        script_dir = os.path.dirname(__file__)

        json_file_path = os.path.join(script_dir, 'fixtures', 'mock_api.json')

        # Read the mock data from the json file
        with open(json_file_path, 'r', encoding='utf-8') as file:
            mock_data = json.load(file)

        mock_get.return_value.json.return_value = mock_data

        response = self.client.get(self.url, follow=False)

        self.assertEqual(response.status_code, 302)

        # Check that the data has been parsed correctly
        # Replace 'key1' and 'key2' with the actual keys in the response data
        self.assertEqual(Station.objects.count(), 1)
        self.assertEqual(PublicTransportStation.objects.count(), 1)

        station = Station.objects.get(name__iexact='Catalunya')
        t_type = TransportType.objects.get(type=TransportType.TTransport.METRO)
        self.assertEqual(Stop.objects.filter(station=station).count(), 3)
        self.assertEqual(len(Stop.objects.get(station=station, transport_type=t_type).lines), 2)

class FinalFormTransports(TestCase):

    def setUp(self):
        self.user = User.objects.create_user(username='testuser', password='12345')
        self.client = Client()
        self.client.force_login(self.user)

    def test_post_success(self):
        data = {
            'selectedTransports': ['Walking', 'Bus', 'Bike'],
            'totalDistance': 100
        }
        response = self.client.post(
            reverse('final_form_transports'),
            data=json.dumps(data),
            content_type='application/json',
        )
        self.assertEqual(response.status_code, 200)

    def test_data_statistics(self):
        data = {
            'selectedTransports': ['Walking', 'Bus', 'Bike', 'Motorcycle'],
            'totalDistance': 100
        }
        self.client.post(
            reverse('final_form_transports'),
            data=json.dumps(data),
            content_type='application/json',
        )
        self.assertEqual(Statistics.objects.count(), 1)
        self.assertEqual(Statistics.objects.get().km_Walked, 25)
        self.assertEqual(Statistics.objects.get().km_Bus, 25)
        self.assertEqual(Statistics.objects.get().km_Biked, 25)
        self.assertEqual(Statistics.objects.get().km_Motorcycle, 25)

    def test_not_answering_form(self):
        data = {
            'selectedTransports': [],
            'totalDistance': 100
        }
        self.client.post(
            reverse('final_form_transports'),
            data=json.dumps(data),
            content_type='application/json',
        )
        self.assertEqual(Statistics.objects.count(), 1)
        self.assertEqual(Statistics.objects.get().km_Walked, 0)
        self.assertEqual(Statistics.objects.get().km_Bus, 0)
        self.assertEqual(Statistics.objects.get().km_Biked, 0)
        self.assertEqual(Statistics.objects.get().km_Motorcycle, 0)
        self.assertEqual(Statistics.objects.get().km_Car, 0)
        self.assertEqual(Statistics.objects.get().km_PublicTransport, 0)
        self.assertEqual(Statistics.objects.get().km_ElectricCar, 0)
        self.assertEqual(Statistics.objects.get().km_Totals, 0)

    def test_km_totals(self):
        data = {
            'selectedTransports': ['Walking', 'Bus', 'Bike'],
            'totalDistance': 100
        }
        self.client.post(
            reverse('final_form_transports'),
            data=json.dumps(data),
            content_type='application/json',
        )
        self.assertEqual(Statistics.objects.count(), 1)
        self.assertEqual(Statistics.objects.get().km_Totals, 100)



class FriendRequestViewSetTest(TestCase):
    def setUp(self):
        self.factory = APIRequestFactory()
        self.user = User.objects.create(username='testuser', email='testuser@mail.com')
        self.friend = User.objects.create(username='friend', email='uwu@mail.com')
        self.FriendRequest = FriendRequest.objects.create(from_user=self.friend, to_user=self.user)

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
        request = self.factory.delete(f'/friend-requests/{self.FriendRequest.id}/')
        force_authenticate(request, user=self.user)
        view = FriendRequestViewSet.as_view({'delete': 'destroy'})
        response = view(request, pk=self.FriendRequest.id)
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
