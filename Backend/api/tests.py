from django.test import TestCase, Client
from django.urls import reverse
from .models import PublicTransportStation, TransportType, Stop
from .views import FetchPublicTransportStations

class FetchPublicTransportStationsTest(TestCase):
    def setUp(self):
        self.client = Client()
        self.url = reverse("fetch-stations")  # replace with the actual URL name for the view

        # Create some test data
        self.transport_type = TransportType.objects.create(type='METRO')
        self.station = PublicTransportStation.objects.create(name='Test Station', latitude='41.3851', longitude='2.1734')
        self.stop = Stop.objects.create(station=self.station, transport_type=self.transport_type, lines=['L1'])

    def test_get(self):
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 200)

        # Add more assertions here to check the data in the response