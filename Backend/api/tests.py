
from django.test import TestCase, Client, RequestFactory
from django.urls import reverse
from rest_framework.test import APIRequestFactory
from rest_framework import status
from django.contrib.auth import get_user_model
from .models import *
from .views import FetchPublicTransportStations
from .views import send_friend_request, accept_friend_request, retrieve_friend_requests
from unittest.mock import patch
import json
import os
import requests

class FetchPublicTransportStationsTest(TestCase):
    def setUp(self):
        self.client = Client()
        self.url = reverse("fetch_all_stations")  


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


        with open(json_file_path, 'r') as file:
            mock_data = json.load(file)

        mock_get.return_value.json.return_value = mock_data

        response = self.client.get(self.url, follow=False)
      
        self.assertEqual(response.status_code, 302)

        self.assertEqual(Station.objects.count(), 1);
        self.assertEqual(PublicTransportStation.objects.count(), 1);

        station = Station.objects.get(name__iexact='Catalunya')
        T_type = TransportType.objects.get(type=TransportType.TTransport.METRO)
        
        self.assertEqual(Stop.objects.filter(station=station).count(), 3)
        self.assertEqual(len(Stop.objects.get(station=station, transport_type=T_type).lines), 2)

# class FinalFormTransports(TestCase):
#     def test_post_success(self):
#         data = {
#             'selectedTransports': ['Walking', 'Bus', 'Bike'],
#             'totalDistance': 100
#         }
#         response = self.client.post(reverse('final_form_transports'), data=json.dumps(data), content_type='application/json')
#         self.assertEqual(response.status_code, 200)

    
#     def test_data_statistics(self):
#         data = {
#             'selectedTransports': ['Walking', 'Bus', 'Bike', 'Motorcycle'],
#             'totalDistance': 100
#         }
        
#         self.client.post(reverse('final_form_transports'), data=json.dumps(data), content_type='application/json')

#         self.assertEqual(Statistics.objects.count(), 1)

#         self.assertEqual(Statistics.objects.get().km_Walked, 25)
#         self.assertEqual(Statistics.objects.get().km_Bus, 25)
#         self.assertEqual(Statistics.objects.get().km_Biked, 25)
#         self.assertEqual(Statistics.objects.get().km_Motorcycle, 25)
    
#     def test_not_answering_form(self):
#         data = {
#             'selectedTransports': [],
#             'totalDistance': 100
#         }
#         self.client.post(reverse('final_form_transports'), data=json.dumps(data), content_type='application/json')
#         self.assertEqual(Statistics.objects.count(), 1)
#         self.assertEqual(Statistics.objects.get().km_Walked, 0)
#         self.assertEqual(Statistics.objects.get().km_Bus, 0)
#         self.assertEqual(Statistics.objects.get().km_Biked, 0)
#         self.assertEqual(Statistics.objects.get().km_Motorcycle, 0)
#         self.assertEqual(Statistics.objects.get().km_Car, 0)
#         self.assertEqual(Statistics.objects.get().km_PublicTransport, 0)
#         self.assertEqual(Statistics.objects.get().km_ElectricCar, 0)
#         self.assertEqual(Statistics.objects.get().km_Totals, 0)

#     def test_km_totals(self):
#         data = {
#             'selectedTransports': ['Walking', 'Bus', 'Bike'],
#             'totalDistance': 100
#         }
#         self.client.post(reverse('final_form_transports'), data=json.dumps(data), content_type='application/json')

#         self.assertEqual(Statistics.objects.count(), 1)
#         self.assertEqual(Statistics.objects.get().km_Totals, 100)

#     def test_no_answer(self):
#         data = {
#             'selectedTransports': [],
#             'totalDistance': 0
#         }
#         self.client.post(reverse('final_form_transports'), data=json.dumps(data), content_type='application/json')

#         self.assertEqual(Statistics.objects.count(), 1)
#         self.assertEqual(Statistics.objects.get().km_Walked, 0)
#         self.assertEqual(Statistics.objects.get().km_Bus, 0)
#         self.assertEqual(Statistics.objects.get().km_Biked, 0)
#         self.assertEqual(Statistics.objects.get().km_Motorcycle, 0)
#         self.assertEqual(Statistics.objects.get().km_Car, 0)
#         self.assertEqual(Statistics.objects.get().km_PublicTransport, 0)
#         self.assertEqual(Statistics.objects.get().km_ElectricCar, 0)
#         self.assertEqual(Statistics.objects.get().km_Totals, 0)


User = get_user_model()

class FriendRequestTestCase(TestCase):
    def setUp(self):
        self.factory = APIRequestFactory()
        self.user1 = User.objects.create_user(username='user1', name='User One', email='user1@example.com', password='testpassword')
        self.user2 = User.objects.create_user(username='user2', name='User Two', email='user2@example.com', password='testpassword')
        self.user3 = User.objects.create_user(username='user3', name='User Three', email='user3@example.com', password='testpassword')

    def test_send_friend_request(self):
        request = self.factory.post('/fake-url/', {'userID': self.user2.id}, format='json')
        request.user = self.user1
        response = send_friend_request(request, self.user2.id)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        response = send_friend_request(request, self.user2.id)
        self.assertEqual(response.status_code, status.HTTP_409_CONFLICT)

    def test_accept_friend_request(self):
        
        Friend_Request.objects.create(from_user=self.user1, to_user=self.user2)
  
        friend_request = Friend_Request.objects.get(from_user=self.user1, to_user=self.user2)
        request = self.factory.post('/fake-url/', {'requestID': friend_request.id}, format='json')
        request.user = self.user2
        response = accept_friend_request(request, friend_request.id)
        self.assertEqual(response.status_code, status.HTTP_200_OK)


    def tearDown(self):
        self.user1.delete()
        self.user2.delete()
        self.user3.delete()


class FriendRequestTests(TestCase):
    def setUp(self):
        self.user1 = User.objects.create_user(username='user1', email='user1@example.com', password='password1')
        self.user2 = User.objects.create_user(username='user2', email='user2@example.com', password='password2')

    def test_retrieve_friend_requests(self):
        Friend_Request.objects.create(from_user=self.user1, to_user=self.user2)
        Friend_Request.objects.create(from_user=self.user1, to_user=self.user2)

        request = RequestFactory().get('/')
        request.user = self.user2

        response = retrieve_friend_requests(request)

        self.assertEqual(response.status_code, 200)
        data = json.loads(response.content.decode('utf-8'))
        self.assertEqual(len(data), 2)  # Check if two friend requests are returned

    def test_retrieve_friend_requests_no_requests(self):
        request = RequestFactory().get('/')
        request.user = self.user2

        response = retrieve_friend_requests(request)

        self.assertEqual(response.status_code, 200)
        data = json.loads(response.content.decode('utf-8'))
        self.assertEqual(len(data), 0)  # Check if no friend requests are returned