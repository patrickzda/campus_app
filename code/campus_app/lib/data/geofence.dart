import 'package:campus_app/data/coordinates.dart';
import 'building.dart';

class Geofence{
  int id;
  Coordinates position;
  double distance;
  Building? associatedBuilding;

  Geofence({required this.id, required this.position, required this.distance, this.associatedBuilding});

  bool isInside(Coordinates userPosition){
    double distanceInMeters = position.distanceTo(userPosition);
    return distanceInMeters <= distance;
  }
}