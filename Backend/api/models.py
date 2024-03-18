from django.db import models
from django.db.models import CheckConstraint  
from django.db.models import Q, F
from django.conf import settings
from django.contrib.auth.models import AbstractUser

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

    