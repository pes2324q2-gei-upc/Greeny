from typing import Any
from django.http import HttpResponseRedirect
from django.test import RequestFactory
from django.conf import settings
from django.core.management.base import BaseCommand
from api.transports_views import FetchPublicTransportStations, headers_AJT, headers_OD
from api.models import ChargingStation, BicingStation
import requests

class Command(BaseCommand):

    help = "Check for updates from external API to mantain coherance in db"

    def handle(self, *args, **options):
        # Check new rows in charging stations
        response = requests.get(url=(settings.BASE_URL_OD
                                    + "tb2m-m33b.json?"
                                    + "$limit=1000"),
                                headers=headers_OD,
                                timeout=5)

        data = response.json()
        charging_s = ChargingStation.objects.count()
        
        created_s = False
        created = False

        if len(data) > charging_s:
            stations_left = len(data) - charging_s
            stations = data[charging_s:]
            for point in stations:

                try:
                    station, created_s = ChargingStation.objects.get_or_create(
                        name=point.get("designaci_descriptiva"),
                        defaults={
                            'latitude': point.get("latitud"),
                            'longitude': point.get("longitud"),
                            'acces': point.get("acces"),
                            'charging_velocity': point.get("tipus_velocitat"),
                            'power': point.get("kw"),
                            'current_type': point.get("ac_dc"),
                            'connexion_type': point.get("tipus_connexi")
                        }
                    )
                except Exception as e:
                    self.stdout.write(self.style.ERROR('An error occurred while creating the Charging Station'))
                    self.stdout.write(str(e))
            #self.stdout.write(self.style.SUCCESS('New Charging Stations added!'))

        #Check new rows in Bicing
        response = requests.get(url=settings.URL_BICING, headers=headers_AJT, timeout=5)
        response.raise_for_status()
        data = response.json().get("data").get("stations")
        
        bicing_s = BicingStation.objects.count()

        if len(data) > bicing_s:

            stations = data[bicing_s:]

            for stop in stations:                
                try:
                    station, created = BicingStation.objects.get_or_create(
                        name=stop.get("name"),
                        defaults={
                            'latitude': stop.get("lat"),
                            'longitude': stop.get("lon"),
                            'capacitat': stop.get("capacity")
                        }
                    )
                except Exception as e:
                    self.stdout.write(self.style.ERROR('An error occurred while creating the Bicing Station'))
                    self.stdout.write(str(e))
            
            if created:
                self.stdout.write(self.style.SUCCESS('New Bicing Stations added!'))
            elif created_s:
                self.stdout.write(self.style.SUCCESS('New Charging Stations added!'))
            else:
                self.stdout.write(self.style.SUCCESS('Already up to date!'))

            
