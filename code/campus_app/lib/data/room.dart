import 'package:campus_app/data/campus_entity.dart';
import 'package:campus_app/data/coordinates.dart';
import 'building.dart';

class Room extends CampusEntity{
  final int id, seatCount;
  final String name, type;
  final Building? building;

  Room({required this.id, required this.name, required this.type, required this.seatCount, this.building});

  @override
  String getDescription() {
    return building != null ? building!.getDescription() : "OPEN";
  }

  @override
  List<String> getIdentifiers() {
    return [name, type];
  }

  @override
  Coordinates getPosition() {
    return building != null ? building!.getPosition() : const Coordinates(latitude: 0, longitude: 0);
  }

  @override
  String getShortName() {
    return building != null ? building!.getShortName() : "-";
  }

  @override
  String getTitle() {
    return name;
  }

  static Room fromJson(Map<String, dynamic> jsonData, int id, Building? building){
    return Room(
      id: id,
      name: jsonData["name"],
      type: jsonData["type"],
      seatCount: jsonData["seat_count"],
      building: building
    );
  }

}