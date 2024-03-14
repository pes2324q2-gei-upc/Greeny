import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part 'locations.g.dart';

@JsonSerializable()
class Locations {
  Locations({
    required this.stations,
  });

  factory Locations.fromJson(Map<String, dynamic> json) =>
      _$LocationsFromJson(json);
  Map<String, dynamic> toJson() => _$LocationsToJson(this);

  final List<Station> stations;
}

@JsonSerializable()
class Station {
  Station({
    required this.stops,
    required this.name,
    required this.rating,
    required this.latitude,
    required this.longitude,
  });

  factory Station.fromJson(Map<String, dynamic> json) =>
      _$StationFromJson(json);
  Map<String, dynamic> toJson() => _$StationToJson(this);

  final List<Stop> stops;
  final double latitude;
  final double longitude;
  final String name;
  final double rating;
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
  const backendURL = 'http://localhost:8000/api/get-stations';

  // Retrieve the locations of Google offices
  try {
    final response = await http.get(Uri.parse(backendURL));
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
