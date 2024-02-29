import 'dart:convert';

import 'package:campus_app/constants/Constants.dart';
import 'package:campus_app/data/building.dart';
import 'package:campus_app/data/coordinates.dart';
import 'package:campus_app/data/navigation_node.dart';
import 'package:campus_app/pages/main_page.dart';
import 'package:campus_app/services/navigation_service.dart';
import 'package:campus_app/services/unity_communication_service.dart';
import 'package:campus_app/widgets/text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'constants/Sizes.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]);

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainPage(),
  ));

}

class EvaluationPage extends StatefulWidget {
  const EvaluationPage({super.key});

  @override
  State<EvaluationPage> createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  int counter = 0;
  double progress = 0;
  List<int> finishedBuildingIndices = [];
  bool started = false;

  @override
  void initState() {
    //evaluateRoutes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Sizes().initialize(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: GestureDetector(
            onTap: (){
              if(!started){
                setState(() {
                  started = true;
                });
                print("EVALUATING...");
                Future.delayed(const Duration(milliseconds: 250)).then((_){
                  evaluateRoutes();
                });
              }
            },
            child: DMSansRegularText(
              text: !started ? "Tap to start" : counter.toString(),
              color: black,
              size: Sizes.textSizeSmall,
            ),
          ),
        ),
      ),
    );
  }

  void evaluateRoutes(){
    Map<String, dynamic> routeData = {};

    for(int i = 0; i < navigationService.buildings.length; i++){
      Building startBuilding = navigationService.buildings[i];
      if(startBuilding.isOnMainCampus && startBuilding.shortName == "HBS"){
        for(int j = 0; j < navigationService.buildings.length; j++){
          Building destinationBuilding = navigationService.buildings[j];
          if(destinationBuilding.isOnMainCampus && startBuilding != destinationBuilding && !finishedBuildingIndices.contains(destinationBuilding.id)){
            double minDistance = double.infinity;
            int startIndex = 0, destinationIndex = 0;

            for(int i = 0; i < startBuilding.entryNodes.length; i++){
              for(int j = 0; j < destinationBuilding.entryNodes.length; j++){
                if(startBuilding.entryNodes[i].coordinates.distanceTo(destinationBuilding.entryNodes[j].coordinates) < minDistance){
                  minDistance = startBuilding.entryNodes[i].coordinates.distanceTo(destinationBuilding.entryNodes[j].coordinates);
                  startIndex = i;
                  destinationIndex = j;
                }
              }
            }

            NavigationNode startNode = startBuilding.entryNodes[startIndex];
            NavigationNode destinationNode = destinationBuilding.entryNodes[destinationIndex];
            Map<String, dynamic> result = navigationService.calculateRouteForEvaluation(startNode, destinationNode);

            routeData[counter.toString()] = {
              "start_building_id": startBuilding.id,
              "destination_building_id": destinationBuilding.id,
              "start_building_latitude": startBuilding.position.latitude,
              "start_building_longitude": startBuilding.position.longitude,
              "destination_building_latitude": destinationBuilding.position.latitude,
              "destination_building_longitude": destinationBuilding.position.longitude,
              "walking_time": result["walking_time"],
              "walking_distance": result["walking_distance"]
            };

            setState(() {
              counter++;
              progress = counter / 1275;
            });
          }
        }
      }
    }

    for(int i = 0; i < routeData.keys.length; i++){
      print("'${routeData.keys.toList()[i]}': {");
      print("  'start_building_id': '${routeData[routeData.keys.toList()[i]]["start_building_id"]}',");
      print("  'destination_building_id': '${routeData[routeData.keys.toList()[i]]["destination_building_id"]}',");
      print("  'start_building_latitude': '${routeData[routeData.keys.toList()[i]]["start_building_latitude"]}',");
      print("  'start_building_longitude': '${routeData[routeData.keys.toList()[i]]["start_building_longitude"]}',");
      print("  'destination_building_latitude': '${routeData[routeData.keys.toList()[i]]["destination_building_latitude"]}',");
      print("  'destination_building_longitude': '${routeData[routeData.keys.toList()[i]]["destination_building_longitude"]}',");
      print("  'walking_time': '${routeData[routeData.keys.toList()[i]]["walking_time"]}',");
      print("  'walking_distance': '${routeData[routeData.keys.toList()[i]]["walking_distance"]}'");
      print("},");
    }
  }

}
