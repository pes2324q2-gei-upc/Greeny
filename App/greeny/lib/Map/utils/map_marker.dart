import 'package:fluster/fluster.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// [Fluster] can only handle markers that conform to the [Clusterable] abstract class.
///
/// You can customize this class by adding more parameters that might be needed for
/// your use case. For instance, you can pass an onTap callback or add an
/// [InfoWindow] to your marker here, then you can use the [toMarker] method to convert
/// this to a proper [Marker] that the [GoogleMap] can read.
class MapMarker extends Clusterable {
  final String id;
  final LatLng position;
  BitmapDescriptor? icon;
  Function onTap;

    MapMarker({
      required this.id,
      required this.position,
      this.icon,
      this.onTap = _defaultOnTap,
      super.isCluster = false,
      super.clusterId,
      super.pointsSize,
      super.childMarkerId,
    }) : super(
            markerId: id,
            latitude: position.latitude,
            longitude: position.longitude,
            );

    static void _defaultOnTap() {
      // Default onTap implementation
    }

    Marker toMarker() => Marker(
          markerId: MarkerId(isCluster! ? 'cl_$id' : id),
          position: LatLng(
            position.latitude,
            position.longitude,
          ),
          icon: icon!,
          onTap: onTap as void Function()?,
        );
  }
