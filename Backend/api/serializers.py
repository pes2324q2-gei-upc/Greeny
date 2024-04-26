from rest_framework import serializers
from .models import (Station, User, PublicTransportStation,
                    Stop, TransportType, BusStation, ChargingStation,
                    BicingStation, Statistics, FriendRequest)

class StationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Station
        fields = ['name', 'latitude', 'longitude' , 'rating']


class UserSerializer(serializers.ModelSerializer):

    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user

    class Meta:
        model = User
        fields = ['username', 'first_name', 'email','password']

class FriendUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['username', 'first_name']

class FriendSerializer(serializers.ModelSerializer):
    friends = serializers.SerializerMethodField()

    def get_friends(self, obj):
        friends = obj.friends.all()
        return FriendUserSerializer(friends, many=True).data

    class Meta:
        model = User
        fields = ['friends']

class PublicTransportStationSerializer(StationSerializer):
    stops = serializers.SerializerMethodField()

    class Meta(StationSerializer.Meta):
        model = PublicTransportStation
        fields = StationSerializer.Meta.fields + ['stops']

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

class BusStationSerializer(StationSerializer):
    class Meta(StationSerializer.Meta):
        model = BusStation
        fields = StationSerializer.Meta.fields + ['lines']

class BicingStationSerializer(StationSerializer):
    class Meta(StationSerializer.Meta):
        model = BicingStation
        fields = StationSerializer.Meta.fields + ['capacitat']

class ChargingStationSerializer(StationSerializer):
    class Meta(StationSerializer.Meta):
        model = ChargingStation
        fields = StationSerializer.Meta.fields + ['acces',
                                                  'charging_velocity',
                                                  'power',
                                                  'current_type',
                                                  'connexion_type']

class StatisticsSerializer(serializers.ModelSerializer):
    class Meta:
        model = Statistics
        exclude = ['id', 'user']
        

class FriendRequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = FriendRequest
        fields = ['from_user', 'to_user']
