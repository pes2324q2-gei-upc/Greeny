"""
This module defines the database models for the Greeny aplication. 

It includes models for Station, PublicTransportStation, TransportType, Stop, BusStation, 
BicingStation, ChargingStation, User and Statistics.

Each model corresponds to a table in the database and defines the fields and behaviors of 
the data that will be stored.
"""
from django.db import models
from django.contrib.postgres.fields import ArrayField
from django.contrib.auth.models import AbstractUser
from django.core.exceptions import ValidationError

class Station(models.Model):
    name = models.CharField(max_length=100)
    latitude = models.FloatField()
    longitude = models.FloatField()
    rating = models.FloatField(default= 0.0)

    def __str__(self):
        return str(self.name)
    def subclass_name(self):
        return self.__class__.__name__

class PublicTransportStation(Station):
    pass

class User(AbstractUser):
    friends = models.ManyToManyField("self", blank=True)

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


def validate_km_totals(instance):
    # Calculate the sum of all km fields
    total_kms = sum([
        instance.km_Walked,
        instance.km_Biked,
        instance.km_ElectricCar,
        instance.km_PublicTransport,
        instance.km_Bus,
        instance.km_Motorcycle,
        instance.km_Car
    ])

    # Check if the sum matches km_Totals with a precision of 2
    if abs(total_kms - instance.km_Totals) > 0.01:
        raise ValidationError('Sum of kms does not match km_Totals')


class Statistics(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, max_length = 100)
    kg_CO2_consumed = models.FloatField(default=0.0)
    kg_CO2_car_consumed = models.FloatField(default=0.0)
    km_Totals = models.FloatField(default=0.0)
    km_Walked = models.FloatField(default=0.0)
    km_Biked = models.FloatField(default=0.0)
    km_ElectricCar = models.FloatField(default=0.0)
    km_PublicTransport = models.FloatField(default=0.0)
    km_Bus = models.FloatField(default=0.0)
    km_Motorcycle = models.FloatField(default=0.0)
    km_Car = models.FloatField(default=0.0)

    def clean(self):
        validate_km_totals(self)

    def save(self, *args, **kwargs):
        self.full_clean()
        super().save(*args, **kwargs)

class FriendRequest(models.Model):
    from_user = models.ForeignKey(
        User, related_name='from_user', on_delete=models.CASCADE)
    to_user = models.ForeignKey(
    User, related_name='to_user', on_delete=models.CASCADE)

class Review(models.Model):
    author = models.ForeignKey(User, on_delete=models.CASCADE, max_length = 100,
                                related_name='reviews')
    station = models.ForeignKey(Station, on_delete=models.CASCADE, related_name='reviews')
    body = models.CharField(max_length = 1000, blank=True)
    puntuation = models.FloatField(default=0.0, blank=False, null=False)
    creation_date = models.DateTimeField(auto_now_add=True)
class Route(models.Model):

    TRANSPORT_MODES = [
        ('Walking', 'Walking'),
        ('Bike', 'Bike'),
        ('Bus', 'Bus'),
        ('Train, Metro, Tram, FGC', 'Train, Metro, Tram, FGC'),
        ('Motorcycle', 'Motorcycle'),
        ('Electric Car', 'Electric Car'),
        ('Car', 'Car')
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    distance = models.FloatField(default=0.0)
    transports = ArrayField(
        models.CharField(max_length=30, choices=TRANSPORT_MODES)
    )
    consumed_co2 = models.FloatField(default=0.0)
    car_consumed_co2 = models.FloatField(default=0.0)
    started_at = models.DateTimeField()
    ended_at = models.DateTimeField()
    total_time = models.CharField(max_length=8, default='00:00:00')

    def save(self, *args, **kwargs):
        # Calculate the difference between ended_at and started_at
        total_time = self.ended_at - self.started_at

        # Convert totalTime to hours, minutes, and seconds
        hours, remainder = divmod(total_time.total_seconds(), 3600)
        minutes, seconds = divmod(remainder, 60)
        self.total_time = "{:02}:{:02}:{:02}".format(int(hours), int(minutes), int(seconds))

        super().save(*args, **kwargs)

class FavoriteStation(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    station = models.ForeignKey(Station, on_delete=models.CASCADE)

    '''def save(self, *args, **kwargs):
        # Calculate the difference in seconds between ended_at and started_at
        self.totalTime = (self.ended_at - self.started_at)
        super().save(*args, **kwargs)'''

    class Meta:
        unique_together = ('user', 'station', )

class Neighborhood(models.Model):
    name = models.CharField(max_length=50) 
    path = models.CharField(max_length=100)  

class Level(models.Model):
    number = models.IntegerField()
    completed = models.BooleanField(default=False)
    current = models.BooleanField(default=False)
    points_user = models.IntegerField(default=0)
    points_total = models.IntegerField(default=0)
    user = models.ForeignKey(User, on_delete=models.CASCADE)  
    neighborhood = models.ForeignKey(Neighborhood, on_delete=models.CASCADE) 
    


