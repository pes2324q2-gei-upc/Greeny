import requests
from django.shortcuts import render
from django.http import JsonResponse
from django.views import View
from pathlib import Path
import os

BASE_URL = "https://analisi.transparenciacatalunya.cat/resource/tb2m-m33b.json?$limit=50"
headers = {"X-App-Token" : os.environ.get('APP_ID')}

# Create your views here.
class CarregadorsElectricsView(View):
    def get(self, request):
        response = requests.get(url=BASE_URL, headers=headers);
        data = response.json()
        return JsonResponse(data, safe=False)