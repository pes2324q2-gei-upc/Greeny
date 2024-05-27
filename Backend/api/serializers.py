from rest_framework import serializers
from .models import (Station, User, PublicTransportStation,
                    Stop, TransportType, BusStation, ChargingStation,
                    BicingStation, Statistics, FriendRequest, Review,
                     Route, Neighborhood, Level, FavoriteStation,
                     CO2Consumed)

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
    is_google = serializers.SerializerMethodField()

    def get_is_google(self, obj):
        return not obj.has_usable_password()

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

    def to_representation(self, instance):
        ret = super().to_representation(instance)
        ret.pop('password', None)
        return ret

    class Meta:
        model = User
        fields = ['id', 'username', 'first_name', 'email', 'password',
                  'date_joined', 'favorite_stations', 'routes_number', 'reviews_number',
                  'friends_number', 'level', 'image', 'is_google', 'points', 'mastery']
        extra_kwargs = {'password': {'write_only': True}}

class FriendUserSerializer(serializers.ModelSerializer):
    image = serializers.SerializerMethodField()
    level = serializers.SerializerMethodField()

    def get_image(self, obj):
        request = self.context.get('request')
        return request.build_absolute_uri(obj.image.url)
    def get_level(self, obj):
        try:
            level = Level.objects.filter(user=obj, current=True).first()
            if level is None:
                return 1
            return level.number
        except Level.DoesNotExist:
            return 1

    class Meta:
        model = User
        fields = ['username', 'first_name', 'image', 'points', 'mastery', 'level']

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
        exclude = ['id', 'coords']

class LevelSerializer(serializers.ModelSerializer):
    neighborhood = NeighborhoodSerializer()
    user_name = serializers.SerializerMethodField()  # new field
    is_staff = serializers.SerializerMethodField()  # new field

    def get_user_name(self, obj):
        return obj.user.first_name

    def get_is_staff(self, obj):
        return obj.user.is_staff

    class Meta:
        model = Level
        fields = ['number', 'completed', 'current', 'points_user',
                  'points_total', 'neighborhood', 'user_name', 'is_staff']

class HistorySerializer(serializers.ModelSerializer):
    neighborhood = NeighborhoodSerializer()
    mastery = serializers.SerializerMethodField()  # Nuevo campo

    class Meta:
        model = Level
        fields = ['number', 'completed', 'current',
                  'neighborhood', 'mastery']  # Agrega 'mastery' a los fields

    def get_mastery(self, obj):
        return obj.user.mastery

class ReviewSerializer(serializers.ModelSerializer):
    author_username = serializers.SerializerMethodField()

    class Meta:
        model = Review
        exclude = ['station', 'author']

    def get_author_username(self, obj):
        return obj.author.username

class FriendRequestSerializer(serializers.ModelSerializer):
    from_user_username = serializers.ReadOnlyField(source='from_user.username')
    to_user_username = serializers.ReadOnlyField(source='to_user.username')
    from_user_image = serializers.SerializerMethodField()

    def get_from_user_image(self, obj):
        request = self.context.get('request')
        return request.build_absolute_uri(obj.from_user.image.url)

    class Meta:
        model = FriendRequest
        fields = ['id', 'from_user', 'to_user', 'from_user_username',
                  'to_user_username', 'from_user_image']

class RouteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Route
        fields = '__all__'

class StationSimpleSerializer(serializers.ModelSerializer):
    latitude = serializers.SerializerMethodField()
    longitude = serializers.SerializerMethodField()

    class Meta:
        model = Station
        fields = ['id', 'latitude', 'longitude']

    def get_latitude(self, obj):
        return obj.location.y

    def get_longitude(self, obj):
        return obj.location.x

class StopSimpleSerializer(serializers.ModelSerializer):
    transport_type = TransportTypeSerializer(read_only=True)

    class Meta:
        model = Stop
        fields = ['transport_type']

class PublicTransportStationSimpleSerializer(StationSimpleSerializer):
    stops = serializers.SerializerMethodField()

    class Meta(StationSimpleSerializer.Meta):
        model = PublicTransportStation
        fields = StationSimpleSerializer.Meta.fields + ['stops']

    def get_stops(self, obj):
        stops = Stop.objects.filter(station=obj)
        serializer = StopSimpleSerializer(stops, many=True)
        return serializer.data

class CO2ConsumedSerializer(serializers.ModelSerializer):
    class Meta:
        model = CO2Consumed
        fields = '__all__'
