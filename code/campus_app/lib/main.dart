import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';

void main(){
  runApp(MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          Expanded(
            child: EmbedUnity(
              onMessageFromUnity: (String message){
                print("EINE NACHRICHT VON UNITY: $message");
              },
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Container(),
              ),
              GestureDetector(
                onTap: (){
                  //sendToUnity("Cube", "SetCubeColor", "1.0");
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Zu Unity senden!",
                    style: TextStyle(
                      color: Colors.white
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    ),
  ));
}