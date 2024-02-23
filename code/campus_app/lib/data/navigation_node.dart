import 'package:campus_app/data/coordinates.dart';
import 'building.dart';

class NavigationNode{
  final int id;
  final Coordinates coordinates;
  List<NavigationNode> connectedNodes;
  Building? building;

  NavigationNode({required this.id, required this.coordinates, this.connectedNodes = const [], this.building});

  double etaTo(NavigationNode other){
    return 0;
  }

  bool isEntrance(){
    return building != null;
  }

  static NavigationNode fromJson(Map<String, dynamic> jsonData, int id, Building? building){
    return NavigationNode(
      id: id,
      coordinates: Coordinates(
        latitude: jsonData["coordinates"][0],
        longitude: jsonData["coordinates"][1]
      ),
      building: building,
      connectedNodes: []
    );
  }

  static NavigationNode? findNavigationNodeById(List<NavigationNode> navigationNodes, int id){
    for(int i = 0; i < navigationNodes.length; i++){
      if(navigationNodes[i].id == id){
        return navigationNodes[i];
      }
    }
    return null;
  }

}