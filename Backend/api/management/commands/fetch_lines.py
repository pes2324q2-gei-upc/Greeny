from django.http import HttpResponseRedirect
from django.test import RequestFactory
from django.core.management.base import BaseCommand
from api.transports_views import FetchPublicTransportStations
from api.models import Stop


class Command(BaseCommand):
    help = "Fetch all lines from every stop"

    def handle(self, *args, **options):

        try:
            factory = RequestFactory()
            request = factory.get('/dummy-url')

            self.stdout.write('Fetching lines from server, please be patient...')

            fetch_view = FetchPublicTransportStations.as_view()

            fv = FetchPublicTransportStations()
            fv.get_transport_lines()

            self.stdout.write(self.style.SUCCESS('Lines fetched successfully!'))

        except Exception as e:
            self.stdout.write(self.style.ERROR('Something went wrong fetching the transport lines'))
            self.stdout.write(str(e))