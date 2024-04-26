"""
This module contains unit tests for the Greeny application.

It includes tests for the Statistics functionality, and for the 
FetchPublicTransportStations methods.
"""

# pylint: disable=no-member
import json
import os
from unittest.mock import patch

from django.test import TestCase, Client
from django.urls import reverse
from rest_framework.authtoken.models import Token
from .models import PublicTransportStation, Station, Statistics, Stop, TransportType, User, Route
from .utils import calculate_co2_consumed, calculate_car_co2_consumed

class FetchPublicTransportStationsTest(TestCase):
    def setUp(self):
        self.client = Client()
        self.url = reverse("fetch_all_stations")  # replace with the actual URL name for the view

    def test_get(self):
        response = self.client.get(self.url, follow=True)
        self.assertEqual(response.status_code, 200)  # The final response should be 200

        # Check that the redirection happened
        self.assertEqual(response.redirect_chain[0][0], '/api/bus-stops')
        self.assertEqual(response.redirect_chain[0][1], 302)  # The status code for redirection

        self.assertEqual(response.redirect_chain[1][0], '/api/bicing')  # The number of redirections
        self.assertEqual(response.redirect_chain[1][1], 302)  # The status code for redirection

        self.assertEqual(response.redirect_chain[2][0], '/api/charging-points')
        self.assertEqual(response.redirect_chain[2][1], 302)

    @patch('requests.get')
    def test_parse_api_data(self, mock_get):
        # Mock the response returned by 'requests.get'

        mock_get.return_value.status_code = 200

        script_dir = os.path.dirname(__file__)

        # Use the script directory to build the path to the json file
        json_file_path = os.path.join(script_dir, 'fixtures', 'mock_api.json')

        # Read the mock data from the json file
        with open(json_file_path, 'r', encoding='utf-8') as file:
            mock_data = json.load(file)

        mock_get.return_value.json.return_value = mock_data

        response = self.client.get(self.url, follow=False)

        # Check that the status code is 200
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
        self.token = Token.objects.create(user=self.user)

    def test_post_success(self):
        data = {
            'selectedTransports': ['Walking', 'Bus', 'Bike'],
            'totalDistance': 100,
            'startedAt': '2024-04-25T16:33:14.90961'
        }
        response = self.client.post(
            reverse('final_form_transports'),
            data=json.dumps(data),
            content_type='application/json',
            **{'HTTP_AUTHORIZATION': 'Token ' + self.token.key}
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(Route.objects.count(), 1)
        self.assertEqual(Statistics.objects.count(), 1)

    def test_data_statistics(self):
        data = {
            'selectedTransports': ['Walking', 'Bus', 'Bike', 'Motorcycle'],
            'totalDistance': 100,
            'startedAt': '2024-04-25T16:33:14.90961'
        }
        self.client.post(
            reverse('final_form_transports'),
            data=json.dumps(data),
            content_type='application/json',
            **{'HTTP_AUTHORIZATION': 'Token ' + self.token.key}
        )
        self.assertEqual(Statistics.objects.count(), 1)
        self.assertEqual(Statistics.objects.get().km_Walked, 25)
        self.assertEqual(Statistics.objects.get().km_Bus, 25)
        self.assertEqual(Statistics.objects.get().km_Biked, 25)
        self.assertEqual(Statistics.objects.get().km_Motorcycle, 25)

    def test_statics_km_totals(self):
        data = {
            'selectedTransports': ['Walking', 'Bus', 'Bike'],
            'totalDistance': 100,
            'startedAt': '2024-04-25T16:33:14.90961'
        }
        self.client.post(
            reverse('final_form_transports'),
            data=json.dumps(data),
            content_type='application/json',
            **{'HTTP_AUTHORIZATION': 'Token ' + self.token.key}
        )
        self.assertEqual(Statistics.objects.count(), 1)
        self.assertEqual(Statistics.objects.get().km_Totals, 100)

    def test_two_routes(self):
        data = {
            'selectedTransports': ['Walking', 'Bus'],
            'totalDistance': 150.70,
            'startedAt': '2024-04-25T16:33:14.90961'
        }
        self.client.post(
            reverse('final_form_transports'),
            data=json.dumps(data),
            content_type='application/json',
            **{'HTTP_AUTHORIZATION': 'Token ' + self.token.key}
        )
        self.assertEqual(Route.objects.count(), 1)
        self.assertEqual(Statistics.objects.count(), 1)
        self.client.post(
            reverse('final_form_transports'),
            data=json.dumps(data),
            content_type='application/json',
            **{'HTTP_AUTHORIZATION': 'Token ' + self.token.key}
        )
        self.assertEqual(Route.objects.count(), 2)
        self.assertEqual(Statistics.objects.count(), 1)

    def test_not_answering_form(self):
        data = {
            'selectedTransports': [],
            'totalDistance': 100,
            'startedAt': '2024-04-25T16:33:14.90961'
        }
        self.client.post(
            reverse('final_form_transports'),
            data=json.dumps(data),
            content_type='application/json',
            **{'HTTP_AUTHORIZATION': 'Token ' + self.token.key}
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

    def test_co2_consumed(self):
        data = {
            'selectedTransports': ['Bus'],
            'totalDistance': 100,
            'startedAt': '2024-04-25T16:33:14.90961'
        }
        self.client.post(
            reverse('final_form_transports'),
            data=json.dumps(data),
            content_type='application/json',
            **{'HTTP_AUTHORIZATION': 'Token ' + self.token.key}
        )
        self.assertEqual(Statistics.objects.count(), 1)
        self.assertEqual(Statistics.objects.get().kg_CO2, 0.08074 * 100)
        self.assertEqual(Route.objects.get().consumed_co2, 0.08074 * 100)
        self.assertEqual(Route.objects.get().car_consumed_co2, 0.143 * 100)

    def test_calculate_co2_consumed(self):
        self.assertAlmostEqual(calculate_co2_consumed(['Walking', 'Walking'], 10), 0.0)
        self.assertAlmostEqual(calculate_co2_consumed(['Bike', 'Bike', 'Bike'], 20), 0.0)
        self.assertAlmostEqual(calculate_co2_consumed(['Bus'], 15), 0.08074 * 15)
        self.assertAlmostEqual(calculate_co2_consumed(['Car'], 25), 0.143 * 25)
        self.assertAlmostEqual(calculate_co2_consumed(['Electric Car'], 30), 0.070 * 30)
        self.assertAlmostEqual(calculate_co2_consumed(['Metro', 'Metro'], 40), 0.05013 * 20 + 0.05013 * 20)

    def test_calculate_car_co2_consumed(self):
        self.assertAlmostEqual(calculate_car_co2_consumed(20), 0.143 * 20)
        self.assertAlmostEqual(calculate_car_co2_consumed(30), 0.143 * 30)
        self.assertAlmostEqual(calculate_car_co2_consumed(40), 0.143 * 40)



