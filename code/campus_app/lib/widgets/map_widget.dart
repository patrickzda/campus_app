import 'package:campus_app/services/unity_communication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import '../constants/constants.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  bool mapLoaded = false;

  @override
  void initState() {
    UnityCommunicationService.sendMapLoadedCheck();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        EmbedUnity(
          onMessageFromUnity: (String message){
            if(message == mapLoadedIdentifier){
              setState(() {
                mapLoaded = true;
              });
            }
          },
        ),
        !mapLoaded ? Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: white
          ),
        ) : const SizedBox()
      ],
    );
  }
}
