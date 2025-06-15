import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

Future<bool> requestLocationPermission() async {
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
    return true;
  } else if (locationPermissionStatus == 0) {
    return false;
  } else {
    const AlertDialog(
      content: Text("Please enable location permissions"),
    );
    return false;
  }
}

Future<List<double?>> getLocation() async {
  final locationPoint = Location();
  var location = await locationPoint.getLocation();
  return [location.latitude, location.longitude, location.accuracy];
}
