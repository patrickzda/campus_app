import 'coordinates.dart';

enum CampusEntityType{
  building,
  canteen,
  course,
  event
}

abstract class CampusEntity{
  String getTitle();
  String getDescription();
  String getShortName();
  List<String> getIdentifiers();
  Coordinates getPosition();
}