from django.db import models
from django.contrib.postgres.fields import ArrayField

class Estacio(models.Model):
    nom = models.CharField(max_length=100)
    latitud = models.FloatField()
    longitud = models.FloatField()
    rating = models.FloatField(default= 0.0)
    def __str__(self):
        return self.nom

class EstacioTransportPublic(Estacio):
    pass

class TipusTransport(models.Model):
    class TTransport(models.TextChoices):
        METRO = "METRO", "metro"
        TRAM = "TRAM", "tram"
        FGC = "FGC", "fgc"
        RENFE = "RENFE", "renfe"
    tipus = models.CharField(max_length=5, choices=TTransport.choices)

class Parada(models.Model):
    estacio = models.ForeignKey(EstacioTransportPublic, on_delete=models.CASCADE)
    tipus_transport = models.ForeignKey(TipusTransport, on_delete=models.CASCADE)
    linies = ArrayField(models.CharField(max_length=2), blank=False)

class EstacioBus(Estacio):
    linies = ArrayField(models.CharField(max_length=5), blank=False)

class EstacioBicing(Estacio):
    capacitat = models.IntegerField(default=0)

class PuntsRecarrega(Estacio):
    acces= models.CharField(max_length=100)
    velocitatCarrega = models.CharField(max_length=100)
    potencia = models.IntegerField(default=0)
    tipusCorrent = models.CharField(max_length=100)
    tipusConnexio = models.CharField(max_length=100)
