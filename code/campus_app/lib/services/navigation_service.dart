import 'package:campus_app/constants/building_data.dart';
import 'package:campus_app/constants/navigation_node_data.dart';
import 'package:campus_app/data/coordinates.dart';
import '../data/building.dart';
import '../data/navigation_node.dart';

class NavigationService{
  late List<Building> buildings;
  late List<NavigationNode> navigationNodes;

  NavigationService(){
    buildings = List.filled(buildingData.length, Building(id: 0, shortName: "", names: [], entryNodes: []));
    navigationNodes = List.filled(navigationNodeData.length, NavigationNode(id: 0, coordinates: const Coordinates(latitude: 0, longitude: 0)));

    //Buildings are parsed from building_data
    List<String> buildingDataKeys = buildingData.keys.toList();
    for(int i = 0; i < buildingDataKeys.length; i++){
      String currentKey = buildingDataKeys[i];
      Map<String, dynamic> currentData = buildingData[currentKey];

      Building currentBuilding = Building(
        id: int.parse(currentKey),
        shortName: currentData["shortName"],
        names: List.generate(currentData["names"].length, (int index){
          return currentData["names"][index].toString();
        }),
        entryNodes: []
      );
      buildings[currentBuilding.id] = currentBuilding;
    }

    //NavigationNodes are parsed from navigation_node_data
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

    //Entry nodes are assigned to buildings
    for(int i = 0; i < buildingDataKeys.length; i++){
      String currentKey = buildingDataKeys[i];
      buildings[int.parse(currentKey)].entryNodes = List.generate(buildingData[currentKey]["entryNodeIds"].length, (int index){
        return navigationNodes[buildingData[currentKey]["entryNodeIds"][index]];
      });
    }

    //Connected nodes are assigned to navigationNodes
    for(int i = 0; i < navigationNodeKeys.length; i++){
      String currentKey = navigationNodeKeys[i];
      navigationNodes[int.parse(currentKey)].connectedNodes = List.generate(navigationNodeData[currentKey]["connections"].length, (int index){
        return navigationNodes[navigationNodeData[currentKey]["connections"][index]];
      });
    }
  }

}