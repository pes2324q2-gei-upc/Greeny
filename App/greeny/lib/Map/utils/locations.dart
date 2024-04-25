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
  List<BusStation> busStations;
  List<BicingStation> bicingStations;
  List<ChargingStation> chargingStations;

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
class PublicTransportStation {
  PublicTransportStation({
    required this.id,
    required this.stops,
    required this.name,
    required this.rating,
    required this.latitude,
    required this.longitude,
  });

  factory PublicTransportStation.fromJson(Map<String, dynamic> json) =>
      _$PublicTransportStationFromJson(json);
  Map<String, dynamic> toJson() => _$PublicTransportStationToJson(this);

  final int id;
  final List<Stop> stops;
  final double latitude;
  final double longitude;
  final String name;
  final double rating;
}

@JsonSerializable()
class BusStation {
  BusStation({
    required this.id,
    required this.lines,
    required this.name,
    required this.rating,
    required this.latitude,
    required this.longitude,
  });

  factory BusStation.fromJson(Map<String, dynamic> json) =>
      _$BusStationFromJson(json);
  Map<String, dynamic> toJson() => _$BusStationToJson(this);

  final int id;
  final List<String> lines;
  final double latitude;
  final double longitude;
  final String name;
  final double rating;
}

@JsonSerializable()
class BicingStation {
  BicingStation({
    required this.id,
    required this.capacitat,
    required this.name,
    required this.rating,
    required this.latitude,
    required this.longitude,
  });

  factory BicingStation.fromJson(Map<String, dynamic> json) =>
      _$BicingStationFromJson(json);
  Map<String, dynamic> toJson() => _$BicingStationToJson(this);

  final int id;
  final int capacitat;
  final double latitude;
  final double longitude;
  final String name;
  final double rating;
}

@JsonSerializable()
class ChargingStation {
  ChargingStation({
    required this.id,
    required this.name,
    required this.rating,
    required this.latitude,
    required this.longitude,
    required this.acces,
    // ignore: non_constant_identifier_names
    required this.charging_velocity,
    required this.power,
    // ignore: non_constant_identifier_names
    required this.current_type,
    // ignore: non_constant_identifier_names
    required this.connexion_type,
  });

  factory ChargingStation.fromJson(Map<String, dynamic> json) =>
      _$ChargingStationFromJson(json);
  Map<String, dynamic> toJson() => _$ChargingStationToJson(this);

  final int id;
  final double latitude;
  final double longitude;
  final String name;
  final double rating;
  final String acces;
  // ignore: non_constant_identifier_names
  final String charging_velocity;
  final int power;
  // ignore: non_constant_identifier_names
  final String current_type;
  // ignore: non_constant_identifier_names
  final String connexion_type;
}

@JsonSerializable()
class Stop {
  Stop({
    required this.transportType,
    required this.lines,
    required this.station,
  });

  factory Stop.fromJson(Map<String, dynamic> json) => _$StopFromJson(json);
  Map<String, dynamic> toJson() => _$StopToJson(this);

  @JsonKey(name: 'transport_type')
  final TransportType transportType;
  final List<String> lines;
  final int station;
}

@JsonSerializable()
class TransportType {
  TransportType({
    required this.type,
  });

  factory TransportType.fromJson(Map<String, dynamic> json) =>
      _$TransportTypeFromJson(json);
  Map<String, dynamic> toJson() => _$TransportTypeToJson(this);

  final String type;
}

Future<Locations> getStations() async {
  // Retrieve the locations  offices
  try {
    final response = await httpGet('api/get-stations');
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
