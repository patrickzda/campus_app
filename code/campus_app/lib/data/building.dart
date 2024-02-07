import 'package:campus_app/constants/constants.dart';
import 'package:campus_app/data/campus_entity.dart';
import 'package:campus_app/data/coordinates.dart';
import 'package:campus_app/data/navigation_node.dart';
import 'package:campus_app/utils/AppUtils.dart';
import 'package:flutter/material.dart';
import 'canteen.dart';
import 'geofence.dart';

class Building extends CampusEntity{
  final int id, openingHour, openingMinute, closingHour, closingMinute;
  final String shortName;
  final List<String> names;
  final Coordinates position;
  final bool isOnMainCampus;
  List<NavigationNode> entryNodes;
  List<Canteen> canteens;

  Building({required this.id, required this.shortName, required this.names, required this.position, required this.entryNodes, this.canteens = const [], required this.openingHour, required this.openingMinute, required this.closingHour, required this.closingMinute, required this.isOnMainCampus});

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
}