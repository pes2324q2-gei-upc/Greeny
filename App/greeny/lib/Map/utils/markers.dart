import 'dart:async';

import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'dart:typed_data';

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
      path: 'assets/transports/rodalies.png', //paste the custom image path
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
