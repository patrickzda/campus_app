import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import '../data/coordinates.dart';

class UnityCommunicationService{

  static void toggle3dView(){
    sendToUnity(
      "Camera Rig",
      "Toggle3dView",
      "",
    );
  }

  static void createPolyline(List<Coordinates> coordinates){
    String coordinateData = "";
    for(int i = 0; i < coordinates.length; i++){
      coordinateData += "${coordinates[i]},";
    }
    coordinateData = coordinateData.substring(0, coordinateData.length - 1);
    coordinateData = coordinateData.replaceAll(" ", "");

    sendToUnity(
      "Navigation",
      "CreatePolyline",
      coordinateData
    );
  }

  static void setPolylineProgress(Coordinates userPosition){
    sendToUnity(
      "Navigation",
      "UpdatePolylineProgress",
      userPosition.toString()
    );
  }

  static void deletePolyline(){
    sendToUnity(
      "Navigation",
      "DeletePolyline",
      ""
    );
  }

}