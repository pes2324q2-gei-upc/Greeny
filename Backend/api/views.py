from django.shortcuts import render
from django.http import JsonResponse
from django.views import View
import json
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from api.models import *

@method_decorator(csrf_exempt, name='dispatch')
class FinalFormTransports(View):
    def post(self, request):
        if request.method == 'POST':
            
            #This lines will be replaced by the user logged in
            try: 
                dummy_user = User.objects.get(username='dummy')
            except User.DoesNotExist:
                dummy_user = User.objects.create(username='dummy', email='dummy@example.com')
                dummy_user.set_password('dummy_password')
                dummy_user.save()           

            data = json.loads(request.body)
            transports = data['selectedTransports']
            
            if (len(transports) != 0):
                total_transports = len(transports)
                transport_modes = ['Walking', 'By bus', 'By publicTransport', 'By bike', 'By car', 'By motorcycle', 'By electricCar']
                transport_percentages = {mode: transports.count(mode) / total_transports * 100 for mode in transport_modes}
        
                field_mapping = {
                    'Walking': 'km_Walked',
                    'By bus': 'km_Bus',
                    'By publicTransport': 'km_PublicTransport',
                    'By bike': 'km_Biked',
                    'By car': 'km_Car',
                    'By motorcycle': 'km_Motorcycle',
                    'By electricCar': 'km_ElectricCar'
                }

                update_fields = {field_mapping[key]: value for key, value in transport_percentages.items()}
                #MIRAR QUE FER AMB ELS KM_TOTALS
            else:
                update_fields = { 
                    'km_Walked': 0.0,
                    'km_Bus': 0.0,
                    'km_PublicTransport': 0.0,
                    'km_Biked': 0.0,
                    'km_Car': 0.0,
                    'km_Motorcycle': 0.0,
                    'km_ElectricCar': 0.0
                }
                #MIRAR QUE FER AMB ELS KM_TOTALS
            
            try: 
                user_statics = Statistics.objects.get(username=dummy_user)
                for key, value in update_fields.items():
                    current_value = getattr(user_statics, key, 0)
                    setattr(user_statics, key, current_value + value)
                user_statics.save()
            except Statistics.DoesNotExist:
                user_statics = Statistics.objects.create(username=dummy_user, **update_fields)
                user_statics.save()
                
            return JsonResponse({'status': 'success'})
    