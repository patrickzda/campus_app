import 'dart:async';
import 'package:location/location.dart';

import '../data/coordinates.dart';
import '../data/geofence.dart';

typedef VoidCallback = void Function();

class UserLocationService{
  late Location location;
  final StreamController<Coordinates> _locationStreamController = StreamController<Coordinates>();
  void Function(int) onFenceEnter, onFenceExit;
  late Stream<Coordinates> locationStream;
  final List<Geofence> _fences = [];
  final Map<int, bool> enteredFences = {};
  bool _streamStarted = false;

  UserLocationService({required this.onFenceEnter, required this.onFenceExit}){
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
    if(_streamStarted){
      return;
    }else{
      _streamStarted = true;
    }
    if(await hasPermission() && await isActive()){
      location.changeSettings(interval: 100);
      location.onLocationChanged.listen((LocationData currentLocation) {
        Coordinates currentPosition = Coordinates.fromLocationData(currentLocation);
        for(int i = 0; i < _fences.length; i++){
          bool isInside = _fences[i].isInside(currentPosition);
          if(isInside && !(enteredFences[_fences[i].id]!)){
            enteredFences[_fences[i].id] = true;
            onFenceEnter(_fences[i].id);
          }else if(!isInside && enteredFences[_fences[i].id]!){
            enteredFences[_fences[i].id] = false;
            onFenceExit(_fences[i].id);
          }
        }

        _locationStreamController.add(currentPosition);
      });
    }
  }

  Future<Coordinates?> getLocation() async{
    if(await hasPermission() && await isActive()){
      LocationData locationData = await location.getLocation();
      return Coordinates.fromLocationData(locationData);
    }else{
      return null;
    }
  }

  void addGeofence(Geofence geofence){
    _fences.add(geofence);
    enteredFences[geofence.id] = false;
  }

  void removeGeoFence(int id){
    for(int i = 0; i < _fences.length; i++){
      if(_fences[i].id == id){
        enteredFences.remove(_fences[i].id);
        _fences.removeAt(i);
        return;
      }
    }
  }

}