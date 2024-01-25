import 'package:campus_app/constants/constants.dart';
import 'package:campus_app/data/coordinates.dart';
import 'package:campus_app/services/user_location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'package:location/location.dart';
import '../constants/sizes.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Coordinates coordinates = const Coordinates(latitude: 0, longitude: 0);

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
      body: EmbedUnity(
       onMessageFromUnity: (String message){
         print("EINE NACHRICHT VON UNITY: $message");
       },
      ),
    );
  }
}
