import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';

void main(){
  runApp(MaterialApp(
    home: Scaffold(
      body: EmbedUnity(
        onMessageFromUnity: (String message){
          print("EINE NACHRICHT VON UNITY: $message");
        },
      ),
    ),
  ));
}