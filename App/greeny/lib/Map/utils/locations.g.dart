// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Locations _$LocationsFromJson(Map<String, dynamic> json) => Locations(
      stations: (json['stations'] as List<dynamic>)
          .map((e) => Station.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LocationsToJson(Locations instance) => <String, dynamic>{
      'stations': instance.stations,
    };

Station _$StationFromJson(Map<String, dynamic> json) => Station(
      stops: (json['stops'] as List<dynamic>)
          .map((e) => Stop.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String,
      rating: (json['rating'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$StationToJson(Station instance) => <String, dynamic>{
      'stops': instance.stops,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'name': instance.name,
      'rating': instance.rating,
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
