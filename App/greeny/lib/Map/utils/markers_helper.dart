import 'dart:async';

import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;
import 'map_marker.dart';
import 'package:flutter/material.dart';
import '../station.dart';

Future<Map> createIcons(int size) async {
  var icons = {};
  final Uint8List tramIcon = await getBytesFromAsset(
      path: 'assets/transports/tram.png', //paste the custom image path
      width: size // size of custom image as marker
      );
  final Uint8List metroIcon = await getBytesFromAsset(
      path: 'assets/transports/metro.png', //paste the custom image path
      width: size // size of custom image as marker
      );
  final Uint8List busIcon = await getBytesFromAsset(
      path: 'assets/transports/bus.png', //paste the custom image path
      width: size // size of custom image as marker
      );
  final Uint8List fgcIcon = await getBytesFromAsset(
      path: 'assets/transports/fgc.png', //paste the custom image path
      width: size // size of custom image as marker
      );
  final Uint8List bicingIcon = await getBytesFromAsset(
      path: 'assets/transports/bicing.png', //paste the custom image path
      width: size // size of custom image as marker
      );
  final Uint8List rodaliesIcon = await getBytesFromAsset(
      path: 'assets/transports/renfe.png', //paste the custom image path
      width: size // size of custom image as marker
      );
  final Uint8List carIcon = await getBytesFromAsset(
      path: 'assets/transports/car.png', //paste the custom image path
      width: size // size of custom image as marker
      );
  final Uint8List tmbIcon = await getBytesFromAsset(
      path: 'assets/transports/tmb.png', //paste the custom image path
      width: size // size of custom image as marker
      );
  icons.addAll({
    'TRAM': tramIcon,
    'METRO': metroIcon,
    'BUS': busIcon,
    'FGC': fgcIcon,
    'BICING': bicingIcon,
    'RENFE': rodaliesIcon,
    'CAR': carIcon,
    'TMB': tmbIcon
  });
  return icons;
}

Future<Uint8List> getBytesFromAsset(
    {required String path, required int width}) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
      .buffer
      .asUint8List();
}

double distanceBetweenTwoCoords(LatLng ll1, LatLng ll2) {
  const rad = 3.1416 / 180;
  var lat1 = ll1.latitude * rad;
  var lat2 = ll2.latitude * rad;
  var sinDLat = math.sin((ll2.latitude - ll1.latitude) * rad / 2);
  var sinDLon = math.sin((ll2.longitude - ll1.longitude) * rad / 2),
      a = sinDLat * sinDLat +
          math.cos(lat1) * math.cos(lat2) * sinDLon * sinDLon,
      c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return 6371000 * c;
}

BitmapDescriptor chooseIcon(station, icons) {
  if (station.stops.length > 1) {
    return BitmapDescriptor.fromBytes(icons['TMB']);
  } else {
    return BitmapDescriptor.fromBytes(
        icons[station.stops[0].transportType.type]!);
  }
}

List<MapMarker> getMarkers(Map<String, bool> transports, icons, stations,
    LatLngBounds bounds, bool fav, LatLng? position, BuildContext context) {
  final List<MapMarker> markers = [];

  print(fav);

  if (position == null) {
    return markers;
  }

  for (final pts in stations.stations.publicTransportStations) {
    if (bounds.contains(LatLng(pts.latitude, pts.longitude))) {
      for (final stop in pts.stops) {
        if (transports[stop.transportType.type.toString().toLowerCase()]!) {
          markers.add(
            MapMarker(
              id: pts.id.toString(),
              position: LatLng(pts.latitude, pts.longitude),
              icon: chooseIcon(pts, icons),
              onTap: () => _gotoStation(pts.id, context, 'TMB'),
            ),
          );
          break;
        }
      }
    }
  }

  if (transports['bus']!) {
    for (final bs in stations.stations.busStations) {
      if (bounds.contains(LatLng(bs.latitude, bs.longitude))) {
        markers.add(
          MapMarker(
            id: bs.id.toString(),
            position: LatLng(bs.latitude, bs.longitude),
            icon: BitmapDescriptor.fromBytes(icons['BUS']),
            onTap: () => _gotoStation(bs.id, context, 'BUS'),
          ),
        );
      }
    }
  }

  if (transports['bicing']!) {
    for (final bs in stations.stations.bicingStations) {
      if (bounds.contains(LatLng(bs.latitude, bs.longitude))) {
        markers.add(
          MapMarker(
            id: bs.id.toString(),
            position: LatLng(bs.latitude, bs.longitude),
            icon: BitmapDescriptor.fromBytes(icons['BICING']),
            onTap: () => _gotoStation(bs.id, context, 'BICING'),
          ),
        );
      }
    }
  }

  if (transports['car']!) {
    for (final cs in stations.stations.chargingStations) {
      if (bounds.contains(LatLng(cs.latitude, cs.longitude))) {
        markers.add(
          MapMarker(
            id: cs.id.toString(),
            position: LatLng(cs.latitude, cs.longitude),
            icon: BitmapDescriptor.fromBytes(icons['CAR']),
            onTap: () => _gotoStation(cs.id, context, 'CAR'),
          ),
        );
      }
    }
  }

  return markers;
}

void _gotoStation(stationId, BuildContext context, type) {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => StationPage(stationId: stationId, type: type)),
  );
}
