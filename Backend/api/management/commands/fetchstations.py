from django.http import HttpResponseRedirect
from django.test import RequestFactory
from django.core.management.base import BaseCommand
from api.transports_views import FetchPublicTransportStations
from api.models import Station

class Command(BaseCommand):
    help = "Fetch all stations data if db empty"

    def handle(self, *args, **options):
        if not Station.objects.exists():
            try:
                factory = RequestFactory()
                request = factory.get('/dummy-url')

                self.stdout.write('Fetching stations, this might take a while...')

                fetch_view = FetchPublicTransportStations.as_view()

                response = fetch_view(request)

                self.stdout.write(self.style.SUCCESS('Stations inititilized successfully'))        
            except Exception as e:
                self.stdout.write(self.style.ERROR('Something went wrong fetching the stations'))
                self.stdout.write(str(e))
        else:
            self.stdout.write(self.style.SUCCESS('Already fetched stations'))
        