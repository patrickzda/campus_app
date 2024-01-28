import 'package:campus_app/constants/constants.dart';
import 'package:campus_app/data/coordinates.dart';
import 'package:campus_app/data/navigation_node.dart';
import 'package:campus_app/services/navigation_service.dart';
import 'package:campus_app/services/user_location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'package:location/location.dart';
import '../constants/sizes.dart';
import '../services/unity_communication_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Coordinates coordinates = const Coordinates(latitude: 0, longitude: 0);
  int counter = 0;

  @override
  void initState() {
    UserLocationService userLocationService = UserLocationService();
    userLocationService.getLocationUpdates();
    userLocationService.locationStream.listen((Coordinates currentLocation) {
      setState(() {
        coordinates = currentLocation;
        print(coordinates);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Sizes().initialize(context);
    return Scaffold(
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
              NavigationService navigationService = NavigationService();
              List<NavigationNode> route = navigationService.calculateRoute(
                navigationService.getClosestNodeToCoordinates(const Coordinates(latitude: 52.50994412619634, longitude: 13.326624217395661)),
                navigationService.getClosestNodeToCoordinates(const Coordinates(latitude: 52.514300902150794, longitude: 13.326480219323894))
              );

              List<Coordinates> coordinates = List.generate(route.length, (int index){
                return route[index].coordinates;
              });

              if(counter == 0){
                UnityCommunicationService.createPolyline(coordinates);
                UnityCommunicationService.setMarkerAppearance(MarkerAppearance.navigation);
              }else if(counter <= coordinates.length){
                UnityCommunicationService.setPolylineProgress(coordinates[counter - 1]);
              }

              counter++;
            },
            child: Container(
              height: Sizes.heightPercent * 8,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.blue
              ),
            ),
          )
        ],
      ),
    );
  }
}
