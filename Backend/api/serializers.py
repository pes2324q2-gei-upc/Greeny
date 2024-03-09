from rest_framework import serializers
from .models import Tram, Metro, FGC, RENFE, Bicing, BUS, PuntsRecarrega

class EstacioSerializer(serializers.ModelSerializer):
    class Meta:
        fields = ['nom', 'latitud', 'longitud', 'adreca', 'rating']

class TramSerializer(serializers.ModelSerializer):
    class Meta(EstacioSerializer.Meta):
        model = Tram
        fields = EstacioSerializer.Meta.fields + ['linies']

class MetroSerializer(serializers.ModelSerializer):
    class Meta(EstacioSerializer.Meta):
        model = Metro
        fields = EstacioSerializer.Meta.fields + ['linies']

class FGCSerializer(serializers.ModelSerializer):
    class Meta(EstacioSerializer.Meta):
        model = FGC
        fields = EstacioSerializer.Meta.fields + ['linies']


class RENFESerializer(serializers.ModelSerializer):
    class Meta(EstacioSerializer.Meta):
        model = RENFE
        fields = EstacioSerializer.Meta.fields + ['linies']

class BicingSerializer(serializers.ModelSerializer):
    class Meta(EstacioSerializer.Meta):
        model = Bicing
        fields = EstacioSerializer.Meta.fields + ['capacitat']

class BUSSerializer(serializers.ModelSerializer):
    class Meta(EstacioSerializer.Meta):
        model = BUS
        fields = EstacioSerializer.Meta.fields + ['linies']

class PuntsRecarregaSerializer(serializers.ModelSerializer):
    class Meta(EstacioSerializer.Meta):
        model = PuntsRecarrega
        fields = EstacioSerializer.Meta.fields + ['acces', 'velocitatCarrega', 'potencia', 'tipusCorrent', 'tipusConnexio']
