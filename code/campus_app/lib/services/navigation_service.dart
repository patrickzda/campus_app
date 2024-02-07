import 'package:campus_app/constants/building_data.dart';
import 'package:campus_app/constants/canteen_data.dart';
import 'package:campus_app/constants/constants.dart';
import 'package:campus_app/constants/navigation_node_data.dart';
import 'package:campus_app/data/canteen.dart';
import 'package:campus_app/data/coordinates.dart';
import 'package:campus_app/data/geofence.dart';
import 'package:campus_app/services/unity_communication_service.dart';
import 'package:campus_app/services/user_location_service.dart';
import 'package:location/location.dart';
import '../data/building.dart';
import '../data/navigation_node.dart';

enum NavigationState{
  initialized,
  active,
  finished,
}

class NavigationService{
  late List<Building> buildings;
  late List<Canteen> canteens;
  late List<NavigationNode> navigationNodes;
  late UserLocationService userLocationService;

  List<NavigationNode> currentRoute = [];
  NavigationState state = NavigationState.finished;
  List<Building> buildingsAlongTheRoute = [];
  List<Geofence> geofenceList = [];
  Geofence? targetGeofence;
  Building? currentBuilding;
  double routeLengthInMeters = 0, walkingTimeInMinutes = 0;

  NavigationService(){
    buildings = List.filled(buildingData.length, Building(id: 0, shortName: "", names: [], position: const Coordinates(latitude: 0, longitude: 0), entryNodes: [], openingHour: 0, openingMinute: 0, closingHour: 0, closingMinute: 0, isOnMainCampus: true));
    navigationNodes = List.filled(navigationNodeData.length, NavigationNode(id: 0, coordinates: const Coordinates(latitude: 0, longitude: 0)));
    canteens = [];

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
        entryNodes: [],
        openingHour: currentData["openingHour"],
        openingMinute: currentData["openingMinute"],
        closingHour: currentData["closingHour"],
        closingMinute: currentData["closingMinute"],
        isOnMainCampus: currentData["isOnMainCampus"]
      );
      buildings[currentBuilding.id] = currentBuilding;
    }

    for(int i = 0; i < canteenData.keys.length; i++){
      Map<String, dynamic> currentData = canteenData[canteenData.keys.toList()[i]];

      canteens.add(Canteen(
        id: int.parse(canteenData.keys.toList()[i]),
        name: currentData["name"],
        position: Coordinates(latitude: currentData["latitude"], longitude: currentData["longitude"]),
        building: buildings[currentData["buildingId"]],
        openingHour: currentData["openingHour"],
        openingMinute: currentData["openingMinute"],
        closingHour: currentData["closingHour"],
        closingMinute: currentData["closingMinute"],
      ));
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
      buildings[int.parse(currentKey)].canteens = List.generate(buildingData[currentKey]["canteenIds"].length, (int index){
        return canteens[buildingData[currentKey]["canteenIds"][index]];
      });
    }

    for(int i = 0; i < navigationNodeKeys.length; i++){
      String currentKey = navigationNodeKeys[i];
      navigationNodes[int.parse(currentKey)].connectedNodes = List.generate(navigationNodeData[currentKey]["connections"].length, (int index){
        return navigationNodes[navigationNodeData[currentKey]["connections"][index]];
      });
    }

    userLocationService = UserLocationService(
      onFenceEnter: (int fenceId){
        //Gebäude wird während der Navigation betreten, die Kamera fokussiert sich auf das Gebäude
        if(state == NavigationState.active){
          for(int i = 0; i < geofenceList.length; i++){
            if(geofenceList[i].id == fenceId){
              currentBuilding = geofenceList[i].associatedBuilding;
              UnityCommunicationService.moveCameraTo(currentBuilding!.position);
              UnityCommunicationService.zoomCameraTo(4);
            }
          }
        }
      },
      onFenceExit: (int fenceId){
        if(state == NavigationState.active){
          currentBuilding = null;
        }
      }
    );

    userLocationService.locationStream.listen((Coordinates userPosition) {
      if(state == NavigationState.active){
        _updateNavigation(userPosition);
      }
    });

  }

  void initNavigation(NavigationNode start, NavigationNode end) async{
    currentRoute = _calculateRoute(start, end);
    UnityCommunicationService.createPolyline(List.generate(currentRoute.length, (int index){
      return currentRoute[index].coordinates;
    }));

    for(int i = 1; i < currentRoute.length; i++){
      routeLengthInMeters = routeLengthInMeters +  currentRoute[i - 1].coordinates.distanceTo(currentRoute[i].coordinates);
    }

    //TODO: BESSERE BERECHNUNG DER ETA
    walkingTimeInMinutes = (routeLengthInMeters / averageWalkingSpeedInMetersPerSecond) / 60.0;

    state = NavigationState.initialized;
  }

  Future<bool> startNavigation() async{
    if(state != NavigationState.initialized){
      return false;
    }

    await userLocationService.getLocationUpdates();
    if((await userLocationService.location.hasPermission()) == PermissionStatus.granted && await userLocationService.location.serviceEnabled()){
      List<int> buildingIds = [];

      targetGeofence = Geofence(id: -1, position: currentRoute.last.coordinates, distance: geofenceRadiusInMeters);
      UnityCommunicationService.setMarkerAppearance(MarkerAppearance.navigation);

      for(int i = 0; i < currentRoute.length; i++){
        if(currentRoute[i].isEntrance() && !buildingIds.contains(currentRoute[i].building!.id)){
          buildingIds.add(currentRoute[i].building!.id);
          buildingsAlongTheRoute.add(currentRoute[i].building!);

          List<Geofence> entranceGeofenceList = currentRoute[i].building!.getGeofenceList();
          geofenceList.addAll(entranceGeofenceList);
          for(int j = 0; j < entranceGeofenceList.length; j++){
            userLocationService.addGeofence(entranceGeofenceList[j]);
          }
        }
      }

      state = NavigationState.active;
      return true;
    }else{
      return false;
    }
  }

  void _updateNavigation(Coordinates currentUserPosition){
    if(currentBuilding != null){
      //Der Nutzer befindet sich in einem Gebäude, warten, bis das Gebäude verlassen wird
      return;
    }

    if(targetGeofence!.isInside(currentUserPosition)){
      //Der Nutzer ist am Ziel angekommen, die Polylinie der Route wird gelöscht und der Marker wird in den Location-Modus gesetzt
      UnityCommunicationService.deletePolyline();
      UnityCommunicationService.resetCamera();
      UnityCommunicationService.set3dView(true);
      UnityCommunicationService.setMarkerAppearance(MarkerAppearance.location);
      state = NavigationState.finished;
      return;
    }

    UnityCommunicationService.setPolylineProgress(currentUserPosition);
  }

  void stopNavigation(){
    currentRoute = [];
    UnityCommunicationService.deletePolyline();
    UnityCommunicationService.resetCamera();
    UnityCommunicationService.set3dView(true);
    state = NavigationState.finished;
    targetGeofence = null;
    buildingsAlongTheRoute = [];
    geofenceList = [];
    currentBuilding = null;
    routeLengthInMeters = 0;
    walkingTimeInMinutes = 0;
  }

  List<NavigationNode> _calculateRoute(NavigationNode start, NavigationNode end){
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