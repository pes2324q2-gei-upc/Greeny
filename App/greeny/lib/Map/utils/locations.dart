import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:greeny/API/requests.dart';
import 'package:json_annotation/json_annotation.dart';

part 'locations.g.dart';

@JsonSerializable()
class Locations {
  Stations stations;

  Locations({required this.stations});

  factory Locations.fromJson(Map<String, dynamic> json) =>
      _$LocationsFromJson(json);
  Map<String, dynamic> toJson() => _$LocationsToJson(this);
}

@JsonSerializable()
class Stations {
  List<PublicTransportStation> publicTransportStations;
  List<StandardStation> busStations;
  List<StandardStation> bicingStations;
  List<StandardStation> chargingStations;

  Stations(
      {required this.publicTransportStations,
      required this.busStations,
      required this.bicingStations,
      required this.chargingStations});

  factory Stations.fromJson(Map<String, dynamic> json) =>
      _$StationsFromJson(json);
  Map<String, dynamic> toJson() => _$StationsToJson(this);
}

@JsonSerializable()
class StandardStation {
  StandardStation({
    required this.id,
    required this.latitude,
    required this.longitude,
  });

  factory StandardStation.fromJson(Map<String, dynamic> json) =>
      _$StandardStationFromJson(json);
  Map<String, dynamic> toJson() => _$StandardStationToJson(this);

  final int? id;
  final double? latitude;
  final double? longitude;
}

@JsonSerializable()
class PublicTransportStation {
  PublicTransportStation({
    required this.id,
    required this.stops,
    required this.latitude,
    required this.longitude,
  });

  factory PublicTransportStation.fromJson(Map<String, dynamic> json) =>
      _$PublicTransportStationFromJson(json);
  Map<String, dynamic> toJson() => _$PublicTransportStationToJson(this);

  final int? id;
  final List<Stop>? stops;
  final double? latitude;
  final double? longitude;
}

@JsonSerializable()
class Stop {
  Stop({
    required this.transportType,
  });

  factory Stop.fromJson(Map<String, dynamic> json) => _$StopFromJson(json);
  Map<String, dynamic> toJson() => _$StopToJson(this);

  @JsonKey(name: 'transport_type')
  final TransportType? transportType;
}

@JsonSerializable()
class TransportType {
  TransportType({
    required this.type,
  });

  factory TransportType.fromJson(Map<String, dynamic> json) =>
      _$TransportTypeFromJson(json);
  Map<String, dynamic> toJson() => _$TransportTypeToJson(this);

  final String? type;
}

Future<Locations> getStations(visible) async {
  double minLng = visible.southwest.longitude;
  double minLat = visible.southwest.latitude;
  double maxLng = visible.northeast.longitude;
  double maxLat = visible.northeast.latitude;

  // Retrieve the locations  offices
  try {
    final response = await httpGetParams('/api/stations', {
      'min_lng': '$minLng',
      'min_lat': '$minLat',
      'max_lng': '$maxLng',
      'max_lat': '$maxLat',
    });
    if (response.statusCode == 200) {
      return Locations.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }

  // Fallback for when the above HTTP request fails.
  return Locations.fromJson(
    json.decode(
      await rootBundle.loadString('assets/locations/locations.json'),
    ) as Map<String, dynamic>,
  );
}
