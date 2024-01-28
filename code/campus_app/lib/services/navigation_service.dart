import 'package:campus_app/constants/building_data.dart';
import 'package:campus_app/constants/navigation_node_data.dart';
import 'package:campus_app/data/coordinates.dart';
import '../data/building.dart';
import '../data/navigation_node.dart';

class NavigationService{
  late List<Building> buildings;
  late List<NavigationNode> navigationNodes;

  NavigationService(){
    buildings = List.filled(buildingData.length, Building(id: 0, shortName: "", names: [], position: const Coordinates(latitude: 0, longitude: 0), entryNodes: []));
    navigationNodes = List.filled(navigationNodeData.length, NavigationNode(id: 0, coordinates: const Coordinates(latitude: 0, longitude: 0)));

    List<String> buildingDataKeys = buildingData.keys.toList();
    for(int i = 0; i < buildingDataKeys.length; i++){
      String currentKey = buildingDataKeys[i];
      Map<String, dynamic> currentData = buildingData[currentKey];

      Building currentBuilding = Building(
        id: int.parse(currentKey),
        position: Coordinates(latitude: currentData["latitude"], longitude: currentData["longitude"]),
        shortName: currentData["shortName"],
        names: List.generate(currentData["names"].length, (int index){
          return currentData["names"][index].toString();
        }),
        entryNodes: []
      );
      buildings[currentBuilding.id] = currentBuilding;
    }

    List<String> navigationNodeKeys = navigationNodeData.keys.toList();
    for(int i = 0; i < navigationNodeKeys.length; i++){
      String currentKey = navigationNodeKeys[i];
      Map<String, dynamic> currentData = navigationNodeData[currentKey];

      NavigationNode currentNavigationNode = NavigationNode(
        id: int.parse(currentKey),
        coordinates: Coordinates(
          latitude: currentData["coordinates"][0],
          longitude: currentData["coordinates"][1]
        ),
        building: currentData["associatedBuildingId"] != null ? buildings[currentData["associatedBuildingId"]] : null
      );
      navigationNodes[currentNavigationNode.id] = currentNavigationNode;
    }

    for(int i = 0; i < buildingDataKeys.length; i++){
      String currentKey = buildingDataKeys[i];
      buildings[int.parse(currentKey)].entryNodes = List.generate(buildingData[currentKey]["entryNodeIds"].length, (int index){
        return navigationNodes[buildingData[currentKey]["entryNodeIds"][index]];
      });
    }

    for(int i = 0; i < navigationNodeKeys.length; i++){
      String currentKey = navigationNodeKeys[i];
      navigationNodes[int.parse(currentKey)].connectedNodes = List.generate(navigationNodeData[currentKey]["connections"].length, (int index){
        return navigationNodes[navigationNodeData[currentKey]["connections"][index]];
      });
    }
  }

  List<NavigationNode> calculateRoute(NavigationNode start, NavigationNode end){
    List<double> minDistancesFromStart = List.filled(navigationNodes.length, double.infinity);
    List<bool> isVisited = List.filled(navigationNodes.length, false);
    List<List<int>> shortestRoutesFromStart = List.filled(navigationNodes.length, []);

    minDistancesFromStart[start.id] = 0;
    shortestRoutesFromStart[start.id] = [start.id];

    for(int i = 0; i < navigationNodes.length; i++){
      NavigationNode currentNode = navigationNodes[_getNextMinDistanceVertex(minDistancesFromStart, isVisited)];

      for(int j = 0; j < currentNode.connectedNodes.length; j++){
        //TODO: HIER DIE DISTANCETO FUNKTION MIT ETA BERECHNUNG ERSETZEN!
        double totalDistance = minDistancesFromStart[currentNode.id] + currentNode.coordinates.distanceTo(currentNode.connectedNodes[j].coordinates);

        if(!isVisited[currentNode.connectedNodes[j].id] && minDistancesFromStart[currentNode.connectedNodes[j].id] > totalDistance){
          minDistancesFromStart[currentNode.connectedNodes[j].id] = totalDistance;
          shortestRoutesFromStart[currentNode.connectedNodes[j].id] = List.from(shortestRoutesFromStart[currentNode.id])..add(currentNode.connectedNodes[j].id);
        }
      }

      isVisited[currentNode.id] = true;
    }

    return List.generate(shortestRoutesFromStart[end.id].length, (int index){
      return navigationNodes[shortestRoutesFromStart[end.id][index]];
    });
  }

  NavigationNode getClosestNodeToCoordinates(Coordinates coordinates){
    int closestNodeIndex = 0;
    double minDistance = double.infinity;

    for(int i = 0; i < navigationNodes.length; i++){
      double currentDistance = coordinates.distanceTo(navigationNodes[i].coordinates);
      if(navigationNodes[i].connectedNodes.isNotEmpty && currentDistance < minDistance){
        minDistance = currentDistance;
        closestNodeIndex = i;
      }
    }

    return navigationNodes[closestNodeIndex];
  }

  int _getNextMinDistanceVertex(List<double> minDistances, List<bool> isVisited){
    int minIndex = 0;
    double minDistance = double.infinity;

    for(int i = 0; i < navigationNodes.length; i++){
      if(!isVisited[i] && minDistances[i] <= minDistance){
        minDistance = minDistances[i];
        minIndex = i;
      }
    }

    return minIndex;
  }

}