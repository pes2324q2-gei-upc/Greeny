import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    required this.stops,
    required this.name,
    required this.rating,
    required this.latitude,
    required this.longitude,
  });

  factory PublicTransportStation.fromJson(Map<String, dynamic> json) =>
      _$PublicTransportStationFromJson(json);
  Map<String, dynamic> toJson() => _$PublicTransportStationToJson(this);

  final List<Stop> stops;
  final double latitude;
  final double longitude;
  final String name;
  final double rating;
}

@JsonSerializable()
class BusStation {
  BusStation({
    required this.lines,
    required this.name,
    required this.rating,
    required this.latitude,
    required this.longitude,
  });

  factory BusStation.fromJson(Map<String, dynamic> json) =>
      _$BusStationFromJson(json);
  Map<String, dynamic> toJson() => _$BusStationToJson(this);

  final List<String> lines;
  final double latitude;
  final double longitude;
  final String name;
  final double rating;
}

@JsonSerializable()
class BicingStation {
  BicingStation({
    required this.capacitat,
    required this.name,
    required this.rating,
    required this.latitude,
    required this.longitude,
  });

  factory BicingStation.fromJson(Map<String, dynamic> json) =>
      _$BicingStationFromJson(json);
  Map<String, dynamic> toJson() => _$BicingStationToJson(this);

  final int capacitat;
  final double latitude;
  final double longitude;
  final String name;
  final double rating;
}

@JsonSerializable()
class ChargingStation {
  ChargingStation({
    required this.name,
    required this.rating,
    required this.latitude,
    required this.longitude,
    required this.acces,
    required this.charging_velocity,
    required this.power,
    required this.current_type,
    required this.connexion_type,
  });

  factory ChargingStation.fromJson(Map<String, dynamic> json) =>
      _$ChargingStationFromJson(json);
  Map<String, dynamic> toJson() => _$ChargingStationToJson(this);

  final double latitude;
  final double longitude;
  final String name;
  final double rating;
  final String acces;
  final String charging_velocity;
  final int power;
  final String current_type;
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
  var backendURL = Uri.http(dotenv.env['BACKEND_URL']!, 'api/get-stations');

  // Retrieve the locations  offices
  try {
    final response = await http.get(backendURL);
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
