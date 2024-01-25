import 'dart:math';
import 'package:location/location.dart';

const double radPi = 0.017453292519943;
const double earthDiameter = 12742;
const kmToM = 1000;

class Coordinates{
  final double latitude, longitude;

  const Coordinates({required this.latitude, required this.longitude});

  static Coordinates fromLocationData(LocationData locationData){
    return Coordinates(latitude: locationData.latitude ?? 0, longitude: locationData.longitude ?? 0);
  }

  @override
  String toString() {
    return "$latitude, $longitude";
  }

  double distanceTo(Coordinates other){
    double bow = 0.5 - cos((other.latitude - latitude) * radPi) / 2 + cos(latitude * radPi) * cos(other.latitude * radPi) * (1 - cos((other.longitude - longitude) * radPi)) / 2;
    return earthDiameter * asin(sqrt(bow)) * kmToM;
  }

}