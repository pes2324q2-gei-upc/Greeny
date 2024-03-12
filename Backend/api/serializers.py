from rest_framework import serializers
from .models import *

class StationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Station
        #fields = '__all__'

class PublicTransportStationSerializer(serializers.ModelSerializer):
    stops = serializers.SerializerMethodField()

    class Meta(StationSerializer.Meta):
        model = PublicTransportStation
        exclude = ['id']
    
    def get_stops(self, obj):
        stops = Stop.objects.filter(station=obj)
        return StopSerializer(stops, many=True).data

class TransportTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = TransportType
        fields = ['type']

class StopSerializer(serializers.ModelSerializer):
    pt_station = PublicTransportStation()
    transport_type = TransportTypeSerializer()

    class Meta:
        model = Stop
        exclude = ['id']

# class TramSerializer(serializers.ModelSerializer):
#     class Meta(EstacioSerializer.Meta):
#         model = Tram
#         fields = EstacioSerializer.Meta.fields + ['linies']

# class MetroSerializer(serializers.ModelSerializer):
#     class Meta(EstacioSerializer.Meta):
#         model = Metro
#         fields = EstacioSerializer.Meta.fields + ['linies']

# class FGCSerializer(serializers.ModelSerializer):
#     class Meta(EstacioSerializer.Meta):
#         model = FGC
#         fields = EstacioSerializer.Meta.fields + ['linies']


# class RENFESerializer(serializers.ModelSerializer):
#     class Meta(EstacioSerializer.Meta):
#         model = RENFE
#         fields = EstacioSerializer.Meta.fields + ['linies']

# class BicingSerializer(serializers.ModelSerializer):
#     class Meta(EstacioSerializer.Meta):
#         model = Bicing
#         fields = EstacioSerializer.Meta.fields + ['capacitat']

# class BUSSerializer(serializers.ModelSerializer):
#     class Meta(EstacioSerializer.Meta):
#         model = BUS
#         fields = EstacioSerializer.Meta.fields + ['linies']

# class PuntsRecarregaSerializer(serializers.ModelSerializer):
#     class Meta(EstacioSerializer.Meta):
#         model = PuntsRecarrega
#         fields = EstacioSerializer.Meta.fields + ['acces', 'velocitatCarrega', 'potencia', 'tipusCorrent', 'tipusConnexio']
