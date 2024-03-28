// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Locations _$LocationsFromJson(Map<String, dynamic> json) => Locations(
      stations: Stations.fromJson(json['stations'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LocationsToJson(Locations instance) => <String, dynamic>{
      'stations': instance.stations,
    };

Stations _$StationsFromJson(Map<String, dynamic> json) => Stations(
      publicTransportStations: (json['publicTransportStations']
              as List<dynamic>)
          .map(
              (e) => PublicTransportStation.fromJson(e as Map<String, dynamic>))
          .toList(),
      busStations: (json['busStations'] as List<dynamic>)
          .map((e) => BusStation.fromJson(e as Map<String, dynamic>))
          .toList(),
      bicingStations: (json['bicingStations'] as List<dynamic>)
          .map((e) => BicingStation.fromJson(e as Map<String, dynamic>))
          .toList(),
      chargingStations: (json['chargingStations'] as List<dynamic>)
          .map((e) => ChargingStation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StationsToJson(Stations instance) => <String, dynamic>{
      'publicTransportStations': instance.publicTransportStations,
      'busStations': instance.busStations,
      'bicingStations': instance.bicingStations,
      'chargingStations': instance.chargingStations,
    };

PublicTransportStation _$PublicTransportStationFromJson(
        Map<String, dynamic> json) =>
    PublicTransportStation(
      stops: (json['stops'] as List<dynamic>)
          .map((e) => Stop.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String,
      rating: (json['rating'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$PublicTransportStationToJson(
        PublicTransportStation instance) =>
    <String, dynamic>{
      'stops': instance.stops,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'name': instance.name,
      'rating': instance.rating,
    };

BusStation _$BusStationFromJson(Map<String, dynamic> json) => BusStation(
      lines: (json['lines'] as List<dynamic>).map((e) => e as String).toList(),
      name: json['name'] as String,
      rating: (json['rating'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$BusStationToJson(BusStation instance) =>
    <String, dynamic>{
      'lines': instance.lines,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'name': instance.name,
      'rating': instance.rating,
    };

BicingStation _$BicingStationFromJson(Map<String, dynamic> json) =>
    BicingStation(
      capacitat: json['capacitat'] as int,
      name: json['name'] as String,
      rating: (json['rating'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$BicingStationToJson(BicingStation instance) =>
    <String, dynamic>{
      'capacitat': instance.capacitat,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'name': instance.name,
      'rating': instance.rating,
    };

ChargingStation _$ChargingStationFromJson(Map<String, dynamic> json) =>
    ChargingStation(
      name: json['name'] as String,
      rating: (json['rating'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      acces: json['acces'] as String,
      charging_velocity: json['charging_velocity'] as String,
      power: json['power'] as int,
      current_type: json['current_type'] as String,
      connexion_type: json['connexion_type'] as String,
    );

Map<String, dynamic> _$ChargingStationToJson(ChargingStation instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'name': instance.name,
      'rating': instance.rating,
      'acces': instance.acces,
      'charging_velocity': instance.charging_velocity,
      'power': instance.power,
      'current_type': instance.current_type,
      'connexion_type': instance.connexion_type,
    };

Stop _$StopFromJson(Map<String, dynamic> json) => Stop(
      transportType: TransportType.fromJson(
          json['transport_type'] as Map<String, dynamic>),
      lines: (json['lines'] as List<dynamic>).map((e) => e as String).toList(),
      station: json['station'] as int,
    );

Map<String, dynamic> _$StopToJson(Stop instance) => <String, dynamic>{
      'transport_type': instance.transportType,
      'lines': instance.lines,
      'station': instance.station,
    };

TransportType _$TransportTypeFromJson(Map<String, dynamic> json) =>
    TransportType(
      type: json['type'] as String,
    );

Map<String, dynamic> _$TransportTypeToJson(TransportType instance) =>
    <String, dynamic>{
      'type': instance.type,
    };
