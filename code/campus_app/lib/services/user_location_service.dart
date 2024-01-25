import 'dart:async';
import 'package:location/location.dart';

import '../data/coordinates.dart';

class UserLocationService{
  late Location location;
  final StreamController<Coordinates> _locationStreamController = StreamController<Coordinates>();
  late Stream<Coordinates> locationStream;

  UserLocationService(){
    location = Location();
    locationStream = _locationStreamController.stream;
  }

  Future<bool> hasPermission() async{
    PermissionStatus status = await location.hasPermission();
    if(status == PermissionStatus.granted){
      return true;
    }

    status = await location.requestPermission();
    return status == PermissionStatus.granted;
  }

  Future<bool> isActive() async{
    bool isServiceEnabled = await location.serviceEnabled();
    if(isServiceEnabled){
      return true;
    }

    isServiceEnabled = await location.requestService();
    return isServiceEnabled;
  }

  Future<void> getLocationUpdates() async{
    if(await hasPermission() && await isActive()){
      location.changeSettings(interval: 500);
      location.onLocationChanged.listen((LocationData currentLocation) {
        _locationStreamController.add(Coordinates.fromLocationData(currentLocation));
      });
    }
  }

}