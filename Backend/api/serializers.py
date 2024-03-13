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