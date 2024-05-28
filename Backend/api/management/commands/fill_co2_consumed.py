from django.core.management.base import BaseCommand
from api.models import CO2Consumed

class Command(BaseCommand):
    help = "Fill CO2Consumed model"

    def handle(self, *args, **options):
        try:
            if not CO2Consumed.objects.exists():
                CO2Consumed.objects.create(
                    kg_CO2_walking_biking_consumed=0.0,
                    kg_CO2_bus_consumed=0.08074,
                    kg_CO2_motorcycle_consumed=0.053,
                    kg_CO2_car_gasoline_consumed=0.143,
                    kg_CO2_electric_car_consumed=0.070,
                    kg_CO2_metro_consumed=0.05013,
                    kg_CO2_tram_consumed=0.08012,
                    kg_CO2_fgc_consumed=0.03577,
                    kg_CO2_train_consumed=0.04688
                )
                self.stdout.write(self.style.SUCCESS('CO2Consumed model filled successfully'))
            else:
                self.stdout.write(self.style.SUCCESS('CO2Consumed model already exists'))
        except Exception as e:
            self.stdout.write(self.style.ERROR('Something went wrong filling the CO2Consumed model'))
            self.stdout.write(str(e))