import 'package:campus_app/data/coordinates.dart';
import 'package:campus_app/data/navigation_node.dart';
import 'package:campus_app/pages/main_page.dart';
import 'package:campus_app/services/navigation_service.dart';
import 'package:campus_app/services/unity_communication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';

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