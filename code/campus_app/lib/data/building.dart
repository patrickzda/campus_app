import 'package:campus_app/constants/constants.dart';
import 'package:campus_app/data/campus_entity.dart';
import 'package:campus_app/data/coordinates.dart';
import 'package:campus_app/data/navigation_node.dart';
import 'package:campus_app/data/room.dart';
import 'package:campus_app/utils/AppUtils.dart';
import 'package:flutter/material.dart';
import 'canteen.dart';
import 'geofence.dart';

class Building extends CampusEntity{
  final int id, openingHour, openingMinute, closingHour, closingMinute;
  final String shortName, address;
  final List<String> names;
  final Coordinates position;
  final bool isOnMainCampus;
  List<NavigationNode> entryNodes;
  List<Canteen> canteens;
  List<Room> rooms;

  Building({required this.id, required this.shortName, required this.address, required this.names, required this.position, required this.entryNodes, this.canteens = const [], this.rooms = const [], required this.openingHour, required this.openingMinute, required this.closingHour, required this.closingMinute, required this.isOnMainCampus});

  List<Geofence> getGeofenceList(){
    return List.generate(entryNodes.length, (int index){
      return Geofence(id: id * 100 + index, position: position, distance: geofenceRadiusInMeters, associatedBuilding: this);
    });
  }

  @override
  String getDescription() {
    double openingTimeInHours = openingHour + openingMinute / 60.0, closingTimeInHours = closingHour + closingMinute / 60.0;
    double currentTimeInHours = TimeOfDay.now().hour + TimeOfDay.now().minute / 60.0;
    bool isOpen = openingTimeInHours <= currentTimeInHours && currentTimeInHours < closingTimeInHours;
    if(DateTime.now().weekday == DateTime.saturday || DateTime.now().weekday == DateTime.sunday){
      isOpen = false;
    }

    return "${AppUtils.formatTime(openingHour, openingMinute)} - ${AppUtils.formatTime(closingHour, closingMinute)}${isOpen ? ", OPEN" : ", CLOSED"}";
  }

  @override
  Coordinates getPosition() {
    return position;
  }

  @override
  String getTitle() {
    return names.isNotEmpty ? "${names[0]} ($shortName Building)" : "$shortName (Building)";
  }

  @override
  List<String> getIdentifiers() {
    return List.from(names)..add(shortName)..add(getTitle());
  }

  @override
  String getShortName() {
    return shortName;
  }

  static Building fromJson(Map<String, dynamic> jsonData, int id){
    return Building(
      id: id,
      shortName: jsonData["shortName"],
      address: jsonData["address"],
      names: List.generate(jsonData["names"].length, (int index){
        return jsonData["names"][index].toString();
      }),
      position: Coordinates(latitude: jsonData["latitude"], longitude: jsonData["longitude"]),
      openingHour: jsonData["openingHour"],
      openingMinute: jsonData["openingMinute"],
      closingHour: jsonData["closingHour"],
      closingMinute: jsonData["closingMinute"],
      isOnMainCampus: jsonData["isOnMainCampus"],
      entryNodes: [],
      canteens: [],
      rooms: []
    );
  }

  static Building? findBuildingById(List<Building> buildings, int id){
    for(int i = 0; i < buildings.length; i++){
      if(buildings[i].id == id){
        return buildings[i];
      }
    }
    return null;
  }

  static Building? findBuildingByShortName(List<Building> buildings, String shortName){
    for(int i = 0; i < buildings.length; i++){
      if(buildings[i].shortName == shortName){
        return buildings[i];
      }
    }
    return null;
  }

}