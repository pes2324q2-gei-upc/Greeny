from django.db import models
from django.contrib.postgres.fields import ArrayField
from django.db.models import Case, When, Value, CharField
from django.db.models import CheckConstraint  
from django.db.models import Q, F
from django.conf import settings
from django.contrib.auth.models import AbstractUser

class Station(models.Model):
    name = models.CharField(max_length=100)
    latitude = models.FloatField()
    longitude = models.FloatField()
    rating = models.FloatField(default= 0.0)
    def __str__(self):
        return self.name
    def subclass_name(self):
        return self.__class__.__name__

class PublicTransportStation(Station):
    pass

class TransportType(models.Model):
    class TTransport(models.TextChoices):
        METRO = "METRO", "metro"
        TRAM = "TRAM", "tram"
        FGC = "FGC", "fgc"
        RENFE = "RENFE", "renfe"
    type = models.CharField(max_length=5, choices=TTransport.choices)

class Stop(models.Model):
    station = models.ForeignKey(PublicTransportStation, on_delete=models.CASCADE)
    transport_type = models.ForeignKey(TransportType, on_delete=models.CASCADE)
    lines = ArrayField(models.CharField(max_length=2), blank=False)

class BusStation(Station):
    lines = ArrayField(models.CharField(max_length=5), blank=False)

class BicingStation(Station):
    capacitat = models.IntegerField(default=0)

class ChargingStation(Station):
    acces= models.CharField(max_length=100)
    charging_velocity = models.CharField(max_length=100)
    power = models.IntegerField(default=0)
    current_type = models.CharField(max_length=100)
    connexion_type = models.CharField(max_length=100)

class User(AbstractUser):
    username = models.CharField(max_length = 100, primary_key = True)
    name = models.CharField(max_length = 100)
    email = models.EmailField(max_length = 100, unique = True)
    password = models.CharField(max_length = 100)


class Statistics(models.Model):
    username = models.OneToOneField(User, on_delete=models.CASCADE, max_length = 100)
    kg_CO2 = models.FloatField(default=0.0)
    km_Totals = models.FloatField(default=0.0)
    km_Walked = models.FloatField(default=0.0)
    km_Biked = models.FloatField(default=0.0)
    km_ElectricCar = models.FloatField(default=0.0)
    km_PublicTransport = models.FloatField(default=0.0)
    km_Bus = models.FloatField(default=0.0)
    km_Motorcycle = models.FloatField(default=0.0)
    km_Car = models.FloatField(default=0.0)

    class Meta:
        constraints = [
            # Km totals = summation of all km
            CheckConstraint(
                check=Q(
                    km_Totals=F('km_Walked') + F('km_Biked') + F('km_ElectricCar') + F('km_PublicTransport') + F('km_Bus') + F('km_Motorcycle') + F('km_Car')),
                name='km_totals_constraint'
            ),
        ]

class Neighborhood(models.Model):
    points_total = models.FloatField(null=False)
    path = models.CharField(null=False)

class Level(models.Model):
    number = models.IntegerField(null=False)
    completed = models.BooleanField(default=False)
    current = models.BooleanField(default=False)
    points_user = models.FloatField(default=0.0)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    Neighborhood = models.ForeignKey(Neighborhood, on_delete=models.CASCADE)

    

    