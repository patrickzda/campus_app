import 'package:campus_app/data/coordinates.dart';
import 'package:campus_app/services/navigation_service.dart';
import 'package:campus_app/services/user_location_service.dart';
import 'package:campus_app/widgets/text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:remix_flutter/remix_flutter.dart';
import '../constants/Sizes.dart';
import '../constants/constants.dart';
import '../services/unity_communication_service.dart';

class LocationButtonWidget extends StatelessWidget {

  const LocationButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Sizes().initialize(context);
    return ScaleTap(
      duration: animationDuration,
      scaleCurve: animationCurve,
      scaleMinValue: 0.75,
      onPressed: () async{
        UnityCommunicationService.setFocusOnUserPosition(true);

        if(navigationService.state == NavigationState.active){
          if(navigationService.currentBuilding != null){
            UnityCommunicationService.moveCameraTo(navigationService.currentBuilding!.position);
            UnityCommunicationService.zoomCameraTo(4);
          }
        }else{
          Coordinates? userLocation = await navigationService.userLocationService.getLocation();
          if(userLocation != null){
            UnityCommunicationService.setMarkerAppearance(MarkerAppearance.location);
            UnityCommunicationService.setMarkerPosition(userLocation);
            UnityCommunicationService.moveCameraTo(userLocation);
            UnityCommunicationService.zoomCameraTo(2.5);
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(Sizes.borderRadius)
        ),
        padding: EdgeInsets.all(Sizes.paddingSmall),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              RemixIcon.focus_3_line,
              size: Sizes.iconSize,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
