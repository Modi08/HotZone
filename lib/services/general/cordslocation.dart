import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

void requestLocationPermission() async {
  /*
  PermissionStatus permission = await location.hasPermission();
  if (permission == PermissionStatus.denied) {
    await location.requestPermission();
    location.requestService();
    permission = await location.hasPermission();
    if (permission != PermissionStatus.granted) {
      return;
    }
  }
  */

  const locationPermissionChannel = MethodChannel("hotzone/locationPermission");

  int locationPermissionStatus =
      await locationPermissionChannel.invokeMethod("getLocationPermission");
  if (locationPermissionStatus == 2) {
    return;
  } else if (locationPermissionStatus == 0) {
    return;
  } else if (locationPermissionStatus == 1) {
    const AlertDialog(
      content: Text("Please enable location permissions"),
    );
  }
}

Future<List<double?>> getLocation() async {
  print("hi");
  final locationPoint = Location();
  var location = await locationPoint.getLocation();
  return [location.latitude, location.longitude, location.accuracy];
}
