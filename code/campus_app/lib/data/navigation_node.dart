import 'package:campus_app/data/coordinates.dart';
import 'building.dart';

class NavigationNode{
  final int id;
  final Coordinates coordinates;
  List<NavigationNode> connectedNodes;
  Building? building;

  NavigationNode({required this.id, required this.coordinates, this.connectedNodes = const [], this.building});

  bool isEntrance(){
    return building != null;
  }
}