import 'package:campus_app/constants/data/building_data.dart';
import 'package:campus_app/constants/constants.dart';
import 'package:campus_app/constants/data/course_data.dart';
import 'package:campus_app/constants/data/room_data.dart';
import 'package:campus_app/data/canteen.dart';
import 'package:campus_app/data/coordinates.dart';
import 'package:campus_app/data/course.dart';
import 'package:campus_app/data/geofence.dart';
import 'package:campus_app/services/unity_communication_service.dart';
import 'package:campus_app/services/user_location_service.dart';
import 'package:location/location.dart';
import '../constants/data/canteen_data.dart';
import '../constants/data/navigation_node_data.dart';
import '../data/building.dart';
import '../data/navigation_node.dart';
import '../data/room.dart';

enum NavigationState{
  initialized,
  active,
  finished,
}

class NavigationService{
  late List<Building> buildings;
  late List<Canteen> canteens;
  late List<NavigationNode> navigationNodes;
  late List<Room> rooms;
  late List<Course> courses;
  late UserLocationService userLocationService;

  List<NavigationNode> currentRoute = [];
  NavigationState state = NavigationState.finished;
  List<Building> buildingsAlongTheRoute = [];
  List<Geofence> geofenceList = [];
  Geofence? targetGeofence;
  Building? currentBuilding;
  double routeLengthInMeters = 0, walkingTimeInMinutes = 0;

  NavigationService(){
    buildings = List.generate(buildingData.keys.length, (int index){
      String currentKey = buildingData.keys.toList()[index];
      return Building.fromJson(buildingData[currentKey], int.parse(currentKey));
    });

    canteens = List.generate(canteenData.keys.length, (int index){
      String currentKey = canteenData.keys.toList()[index];
      return Canteen.fromJson(canteenData[currentKey], int.parse(currentKey), Building.findBuildingById(buildings, canteenData[currentKey]["buildingId"])!);
    });

    navigationNodes = List.generate(navigationNodeData.keys.length, (int index){
      String currentKey = navigationNodeData.keys.toList()[index];
      return NavigationNode.fromJson(navigationNodeData[currentKey], int.parse(currentKey), navigationNodeData[currentKey]["associatedBuildingId"] != null ? Building.findBuildingById(buildings, navigationNodeData[currentKey]["associatedBuildingId"]) : null);
    });

    for(int i = 0; i < buildingData.keys.length; i++){
      String currentKey = buildingData.keys.toList()[i];
      buildings[i].entryNodes = List.generate(buildingData[currentKey]["entryNodeIds"].length, (int index){
        return NavigationNode.findNavigationNodeById(navigationNodes, buildingData[currentKey]["entryNodeIds"][index])!;
      });

      buildings[i].canteens = List.generate(buildingData[currentKey]["canteenIds"].length, (int index){
        return Canteen.findCanteenById(canteens, buildingData[currentKey]["canteenIds"][index])!;
      });
    }

    for(int i = 0; i < navigationNodeData.keys.length; i++){
      String currentKey = navigationNodeData.keys.toList()[i];
      navigationNodes[i].connectedNodes = List.generate(navigationNodeData[currentKey]["connections"].length, (int index){
        return NavigationNode.findNavigationNodeById(navigationNodes, navigationNodeData[currentKey]["connections"][index])!;
      });
    }

    Map<int, Room> roomMap = {};
    for(int i = 0; i < roomData.keys.length; i++){
      String currentKey = roomData.keys.toList()[i];
      Building? building = Building.findBuildingByShortName(buildings, roomData[currentKey]["name"].split(" ")[0]);

      roomMap[int.parse(currentKey)] = Room.fromJson(roomData[currentKey], int.parse(currentKey), building);

      if(building != null){
        building.rooms.add(roomMap[int.parse(currentKey)]!);
      }
    }

    List<String> courseDataKeys = courseData.keys.toList();
    courses = List.generate(courseDataKeys.length, (int index){
      Course currentCourse = Course.fromJson(courseData[courseDataKeys[index]], int.parse(courseDataKeys[index]));

      List<int> roomIds = [];
      for(int i = 0; i < currentCourse.events.length; i++){
        for(int j = 0; j < currentCourse.events[i].roomIds.length; j++){
          roomIds.add(currentCourse.events[i].roomIds[j]);
        }
      }
      roomIds = roomIds.toSet().toList();

      for(int i = 0; i < roomIds.length; i++){
        roomMap[roomIds[i]]!.courses.add(currentCourse);
      }

      return currentCourse;
    });

    rooms = List.generate(roomMap.keys.length, (int index){
      return roomMap[roomMap.keys.toList()[index]]!;
    });

    //TODO: Bugfix: Warum wird ein Gebäude während der Navigation nicht fokussiert wenn es betreten wird?

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
    print("HIER DIE NODE IDS:");
    print(start.id);
    print(end.id);

    currentRoute = _calculateRoute(start, end);

    UnityCommunicationService.createPolyline(List.generate(currentRoute.length, (int index){
      return currentRoute[index].coordinates;
    }));

    for(int i = 1; i < currentRoute.length; i++){
      routeLengthInMeters = routeLengthInMeters + currentRoute[i - 1].coordinates.distanceTo(currentRoute[i].coordinates);
      walkingTimeInMinutes = walkingTimeInMinutes + estimateWalkingTime(currentRoute[i - 1], currentRoute[i]);
    }

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
        double totalDistance = minDistancesFromStart[currentNode.id] + estimateWalkingTime(currentNode, currentNode.connectedNodes[j]);

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

  Map<String, dynamic> calculateRouteForEvaluation(NavigationNode start, NavigationNode end){
    List<NavigationNode> route = _calculateRoute(start, end);
    double t = 0, d = 0;

    for(int i = 1; i < route.length; i++){
      d = d + route[i - 1].coordinates.distanceTo(route[i].coordinates);
      t = t + estimateWalkingTime(route[i - 1], route[i]);
    }

    return {
      "walking_time": "$t min",
      "walking_distance": "$d m"
    };
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

  double estimateWalkingTime(NavigationNode first, NavigationNode second){
    double distance = first.coordinates.distanceTo(second.coordinates);

    if(first.isEntrance() && second.isEntrance()){
      distance = distance * indoorDistanceFactor;
    }

    double eta = distance / averageWalkingSpeedInMetersPerSecond;
    if(trafficLightNodeIds.contains(first.id) || trafficLightNodeIds.contains(second.id)){
      eta = eta + trafficLightWaitingTimeInSeconds;
    }

    return eta / 60.0;
  }

}