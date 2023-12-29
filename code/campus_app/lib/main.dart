import 'package:campus_app/data/coordinates.dart';
import 'package:campus_app/data/navigation_node.dart';
import 'package:campus_app/services/navigation_service.dart';
import 'package:campus_app/services/unity_communication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';

void main(){
  int counter = 0;

  runApp(MaterialApp(
    home: Scaffold(
      body: Column(
        children: [
          Expanded(
            child: EmbedUnity(
              onMessageFromUnity: (String message){
                print("EINE NACHRICHT VON UNITY: $message");
              },
            ),
          ),
          GestureDetector(
            onTap: (){
              //UnityCommunicationService.toggle3dView();
              List<NavigationNode> route;
              NavigationService service = NavigationService();
              Coordinates start = const Coordinates(latitude: 52.51066732441862, longitude: 13.327159187237413);
              Coordinates end = const Coordinates(latitude: 52.51658837236144, longitude: 13.323546307383321);
              NavigationNode startNode = service.getClosestNodeToCoordinates(start);
              NavigationNode endNode = service.getClosestNodeToCoordinates(end);

              route = service.calculateRoute(startNode, endNode);
              List<Coordinates> routeCoordinates = List.generate(route.length, (int index){
                return route[index].coordinates;
              });

              UnityCommunicationService.createPolyline(routeCoordinates);
            },
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 20
              ),
              decoration: const BoxDecoration(
                color: Colors.blue
              ),
              child: const Text(
                "Display fastest route",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15
                ),
              ),
            ),
          )
        ],
      ),
    ),
  ));
}