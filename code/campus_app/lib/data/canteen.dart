import 'package:campus_app/data/campus_entity.dart';
import 'package:flutter/material.dart';
import '../utils/AppUtils.dart';
import 'building.dart';
import 'coordinates.dart';

class Canteen extends CampusEntity{
  final int id, openingHour, openingMinute, closingHour, closingMinute;
  final String name;
  final Coordinates position;
  final Building building;

  Canteen({required this.id, required this.name, required this.position, required this.building, required this.openingHour, required this.openingMinute, required this.closingHour, required this.closingMinute});

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
    return name;
  }

  @override
  List<String> getIdentifiers() {
    return [name];
  }

  @override
  String getShortName() {
    return building.shortName;
  }

  static Canteen fromJson(Map<String, dynamic> jsonData, int id, Building building){
    return Canteen(
      id: id,
      name: jsonData["name"],
      position: Coordinates(latitude: jsonData["latitude"], longitude: jsonData["longitude"]),
      building: building,
      openingHour: jsonData["openingHour"],
      openingMinute: jsonData["openingMinute"],
      closingHour: jsonData["closingHour"],
      closingMinute: jsonData["closingMinute"]
    );
  }

  static Canteen? findCanteenById(List<Canteen> canteens, int id){
    for(int i = 0; i < canteens.length; i++){
      if(canteens[i].id == id){
        return canteens[i];
      }
    }
    return null;
  }

}