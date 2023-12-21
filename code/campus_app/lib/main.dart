import 'package:campus_app/data/coordinates.dart';
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
              if(counter == 0){
                UnityCommunicationService.createPolyline([
                  Coordinates(latitude: 52.512009981475174, longitude: 13.322146506341582),
                  Coordinates(latitude: 52.51223198449646, longitude: 13.322704405801074),
                  Coordinates(latitude: 52.512617222371794, longitude: 13.323262305260563),
                  Coordinates(latitude: 52.51306122115756, longitude: 13.330675930770342),
                ]);
              }else if(counter == 1){
                UnityCommunicationService.setPolylineProgress(Coordinates(latitude: 52.51223198449646, longitude: 13.322704405801074));
              }else if(counter == 2){
                UnityCommunicationService.deletePolyline();
              }
              counter++;
              counter = counter % 3;
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
                "Toggle 3d view",
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