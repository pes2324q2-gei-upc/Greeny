from django.db import models
from django.contrib.postgres.fields import ArrayField

class Estacio(models.Model):
    nom = models.CharField(max_length=100)
    latitud = models.FloatField()
    longitud = models.FloatField()
    adreca = models.CharField(max_length=100)
    rating = models.FloatField()
    def __str__(self):
        return self.nom
    class Meta:
        abstract = True
    

class Tram(Estacio):
    linies = ArrayField(models.CharField(max_length=10, blank=False))

class Metro(Estacio):
    linies = ArrayField(models.CharField(max_length=10, blank=False))

class FGC(Estacio):
    linies = ArrayField(models.CharField(max_length=10, blank=False))

class RENFE(Estacio):
    linies = ArrayField(models.CharField(max_length=10, blank=False))

class Bicing(Estacio):
    capacitat = models.IntegerField();

class BUS(Estacio):
    linies = ArrayField(models.CharField(max_length=10, blank=False))

class PuntsRecarrega(Estacio):
    acces= models.CharField(max_length=100)
    velocitatCarrega = models.CharField(max_length=100)
    potencia = models.IntegerField()
    tipusCorrent = models.CharField(max_length=100)
    tipusConnexio = models.CharField(max_length=100)
