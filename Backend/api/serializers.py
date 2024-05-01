from rest_framework import serializers
from .models import (Station, User, PublicTransportStation,
                    Stop, TransportType, BusStation, ChargingStation,
                    BicingStation, Statistics, FriendRequest, Review, Route, Neighborhood, Level, FavoriteStation)

class StationSerializer(serializers.ModelSerializer):
    latitude = serializers.SerializerMethodField()
    longitude = serializers.SerializerMethodField()

    class Meta:
        model = Station
        fields = ['id', 'name', 'latitude', 'longitude', 'rating']

    def get_latitude(self, obj):
        return obj.location.y

    def get_longitude(self, obj):
        return obj.location.x

class SimpleStationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Station
        fields = ['id', 'name']

class FavoriteStationSerializer(serializers.ModelSerializer):
    station = SimpleStationSerializer(read_only=True)

    class Meta:
        model = FavoriteStation
        fields = ['station']

class UserSerializer(serializers.ModelSerializer):

    favorite_stations = serializers.SerializerMethodField()
    reviews_number = serializers.SerializerMethodField()
    routes_number = serializers.SerializerMethodField()
    friends_number = serializers.SerializerMethodField()
    level = serializers.SerializerMethodField()

    def get_level(self, obj):
        try:
            level = Level.objects.filter(user=obj, current=True).first()
            if level is None:
                return 1
            return level.number
        except Level.DoesNotExist:
            return 1

    def get_friends_number(self, obj):
        return obj.friends.count()
    
    def get_routes_number(self, obj):
        return obj.routes.count()

    def get_reviews_number(self, obj):
        return obj.reviews.count()

    def get_favorite_stations(self, obj):
        favorite_stations = FavoriteStation.objects.filter(user=obj)
        return FavoriteStationSerializer(favorite_stations, many=True).data

    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user

    class Meta:
        model = User
        fields = ['id', 'username', 'first_name', 'email','password', 'date_joined', 'favorite_stations', 'routes_number', 'reviews_number', 'friends_number', 'level']

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
        exclude = ['id']

class NeighborhoodSerializer(serializers.ModelSerializer):
    class Meta:
        model = Neighborhood
        exclude = ['id']

class LevelSerializer(serializers.ModelSerializer):
    neighborhood = NeighborhoodSerializer()
    user_name = serializers.SerializerMethodField()  # new field

    def get_user_name(self, obj):
        return obj.user.first_name

    class Meta:
        model = Level
        fields = ['number', 'completed', 'current', 'points_user', 'points_total', 'neighborhood', 'user_name']

class ReviewSerializer(serializers.ModelSerializer):
    author_username = serializers.SerializerMethodField()

    class Meta:
        model = Review
        exclude = ['id', 'station', 'author']

    def get_author_username(self, obj):
        return obj.author.username

class FriendRequestSerializer(serializers.ModelSerializer):
    from_user_username = serializers.ReadOnlyField(source='from_user.username')
    to_user_username = serializers.ReadOnlyField(source='to_user.username')

    class Meta:
        model = FriendRequest
        fields = ['id', 'from_user', 'to_user', 'from_user_username', 'to_user_username']

class RouteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Route
        fields = '__all__'