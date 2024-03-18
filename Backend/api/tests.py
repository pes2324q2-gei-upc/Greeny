import json
from django.test import TestCase, Client
from django.urls import reverse
from api.models import *

class FinalFormTransports(TestCase):
    def test_post_success(self):
        data = {
            'selectedTransports': ['Walking', 'By bus', 'By bike']
        }
        response = self.client.post(reverse('final_form_transports'), data=json.dumps(data), content_type='application/json')
        self.assertEqual(response.status_code, 200)

    
    def test_data_statistics(self):
        data = {
            'selectedTransports': ['Walking', 'By bus', 'By bike']
        }
        
        self.client.post(reverse('final_form_transports'), data=json.dumps(data), content_type='application/json')

        self.assertEqual(Statistics.objects.count(), 1)
        self.assertEqual(Statistics.objects.get().km_Walked, 33.33333333333333)
        self.assertEqual(Statistics.objects.get().km_Bus, 33.33333333333333)
        self.assertEqual(Statistics.objects.get().km_Biked, 33.33333333333333)
    
    def test_not_answering_form(self):
        data = {
            'selectedTransports': []
        }
        response = self.client.post(reverse('final_form_transports'), data=json.dumps(data), content_type='application/json')
        self.assertEqual(Statistics.objects.count(), 1)
        self.assertEqual(Statistics.objects.get().km_Walked, 0)
        self.assertEqual(Statistics.objects.get().km_Bus, 0)
        self.assertEqual(Statistics.objects.get().km_Biked, 0)
        self.assertEqual(Statistics.objects.get().km_Motorcycle, 0)
        self.assertEqual(Statistics.objects.get().km_Car, 0)
        self.assertEqual(Statistics.objects.get().km_PublicTransport, 0)
        self.assertEqual(Statistics.objects.get().km_ElectricCar, 0)
        self.assertEqual(Statistics.objects.get().km_Totals, 0)
        

    

