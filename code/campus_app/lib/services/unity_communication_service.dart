import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import '../data/coordinates.dart';

enum MarkerAppearance{
  location,
  navigation
}

class UnityCommunicationService{

  static void moveCameraTo(Coordinates cameraPosition){
    sendToUnity(
      "Camera Rig",
      "MoveToFromString",
      cameraPosition.toString().replaceAll(" ", ""),
    );
  }

  static void zoomCameraTo(double zoomLevel){
    sendToUnity(
      "Camera Rig",
      "ZoomToFromString",
      zoomLevel.toString(),
    );
  }

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

  static void setMarkerPosition(Coordinates coordinates){
    sendToUnity(
      "User Marker",
      "SetUserLocationFromString",
      coordinates.toString()
    );
  }

  static void animateMarkerToPosition(Coordinates coordinates){
    sendToUnity(
      "User Marker",
      "AnimateToUserLocationFromString",
      coordinates.toString()
    );
  }

  static void setMarkerAppearance(MarkerAppearance markerAppearance){
    sendToUnity(
      "User Marker",
      "SetLocationModeFromString",
      markerAppearance == MarkerAppearance.location ? "true" : "false"
    );
  }

  static void setFocusOnUserPosition(bool isFocussedOnUserPosition){
    sendToUnity(
      "Navigation",
      "SetFocusOnUserPositionFromString",
      isFocussedOnUserPosition ? "true" : "false"
    );
  }

}