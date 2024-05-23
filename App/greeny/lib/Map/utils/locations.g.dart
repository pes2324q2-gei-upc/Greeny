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
          .map((e) => StandardStation.fromJson(e as Map<String, dynamic>))
          .toList(),
      bicingStations: (json['bicingStations'] as List<dynamic>)
          .map((e) => StandardStation.fromJson(e as Map<String, dynamic>))
          .toList(),
      chargingStations: (json['chargingStations'] as List<dynamic>)
          .map((e) => StandardStation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StationsToJson(Stations instance) => <String, dynamic>{
      'publicTransportStations': instance.publicTransportStations,
      'busStations': instance.busStations,
      'bicingStations': instance.bicingStations,
      'chargingStations': instance.chargingStations,
    };

StandardStation _$StandardStationFromJson(Map<String, dynamic> json) =>
    StandardStation(
      id: json['id'] as int?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$StandardStationToJson(StandardStation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

PublicTransportStation _$PublicTransportStationFromJson(
        Map<String, dynamic> json) =>
    PublicTransportStation(
      id: json['id'] as int?,
      stops: (json['stops'] as List<dynamic>?)
          ?.map((e) => Stop.fromJson(e as Map<String, dynamic>))
          .toList(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PublicTransportStationToJson(
        PublicTransportStation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stops': instance.stops,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

Stop _$StopFromJson(Map<String, dynamic> json) => Stop(
      transportType: json['transport_type'] == null
          ? null
          : TransportType.fromJson(
              json['transport_type'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StopToJson(Stop instance) => <String, dynamic>{
      'transport_type': instance.transportType,
    };

TransportType _$TransportTypeFromJson(Map<String, dynamic> json) =>
    TransportType(
      type: json['type'] as String?,
    );

Map<String, dynamic> _$TransportTypeToJson(TransportType instance) =>
    <String, dynamic>{
      'type': instance.type,
    };
