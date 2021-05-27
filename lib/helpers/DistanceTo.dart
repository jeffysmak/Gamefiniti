import 'dart:math';

import 'package:angles/angles.dart';

class distanceTo {
  // distance calculator functions
  static double distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    // haversine great circle distance approximation, returns meters
    double theta = lon1 - lon2;
    double dist =
        sin(deg2rad(lat1)) * sin(deg2rad(lat2)) + cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * cos(deg2rad(theta));
    dist = acos(dist);
    dist = Angle.fromRadians(dist).degrees;
//    dist = rad2deg(dist);
    dist = dist * 60; // 60 nautical miles per degree of seperation
    dist = dist * 1852; // 1852 meters per nautical mile
    return (dist);
  }

  static double deg2rad(double deg) {
    return (deg * pi / 180.0);
  }

  static double ad2deg(double rad) {
    return (rad * 180.0 / pi);
  }

  void sort(List<Map<String, dynamic>> mechanics, Function onComplete) {
    int listLength = mechanics.length;
  }

  void selectionSort(List<Map<String, dynamic>> mechanics, Function onComplete) {
    if (mechanics == null || mechanics.length == 0) return;
    int n = mechanics.length;
    int i, steps;
    List<Map<String, dynamic>> sorted = List();
    for (steps = 0; steps < n; steps++) {
      for (i = steps + 1; i < n; i++) {
        if (mechanics[steps]['distance'] > mechanics[i]['distance']) {
          sorted = swap(mechanics, steps, i);
        }
      }
    }
    onComplete(sorted);
  }

  static List<Map<String, dynamic>> swap(List<Map<String, dynamic>> mechanics, int steps, int i) {
    Map<String, dynamic> temp = mechanics[steps];
    mechanics[steps] = mechanics[i];
    mechanics[i] = temp;
    return mechanics;
  }
}
