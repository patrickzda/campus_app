import 'package:campus_app/constants/Sizes.dart';
import 'package:campus_app/constants/constants.dart';
import 'package:campus_app/data/navigation_job.dart';
import 'package:campus_app/pages/main_page.dart';
import 'package:campus_app/pages/search_page.dart';
import 'package:campus_app/utils/AppUtils.dart';
import 'package:campus_app/widgets/text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:remix_flutter/remix_flutter.dart';

import '../data/coordinates.dart';
import '../services/unity_communication_service.dart';

typedef VoidCallback = void Function();

class RoutePreviewPopupWidget extends StatefulWidget {
  final NavigationJob navigationJob;
  final void Function() onClose;

  const RoutePreviewPopupWidget({super.key, required this.navigationJob, required this.onClose});

  @override
  State<RoutePreviewPopupWidget> createState() => _RoutePreviewPopupWidgetState();
}

class _RoutePreviewPopupWidgetState extends State<RoutePreviewPopupWidget> {
  bool showStartButton = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: animationDuration,
      curve: animationCurve,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(Sizes.borderRadius)
      ),
      margin: EdgeInsets.all(Sizes.paddingRegular),
      padding: EdgeInsets.all(Sizes.paddingRegular),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: Sizes.paddingRegular),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DMSansBoldText(
                    text: "Current route",
                    size: Sizes.textSizePageTitle,
                    color: black,
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    widget.onClose();
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: white
                    ),
                    child: const Icon(
                      RemixIcon.close_line,
                      color: black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: lightGrey,
                    borderRadius: BorderRadius.circular(Sizes.borderRadius)
                  ),
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(Sizes.paddingSmall),
                  child: DMSansRegularText(
                    text: widget.navigationJob.isUserLocationBased ? "My location" : widget.navigationJob.startEntity!.getShortName(),
                    color: black,
                    size: Sizes.textSizeSmall,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Sizes.paddingSmall),
                child: Icon(
                  RemixIcon.arrow_right_line,
                  size: Sizes.iconSize,
                  color: black,
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: lightGrey,
                    borderRadius: BorderRadius.circular(Sizes.borderRadius)
                  ),
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(Sizes.paddingSmall),
                  child: DMSansRegularText(
                    text: widget.navigationJob.destinationEntity.getShortName(),
                    color: black,
                    size: Sizes.textSizeSmall,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: Sizes.paddingRegular),
            child: Row(
              children: [
                Expanded(
                  child: DMSansRegularText(
                    text: "${(navigationService.routeLengthInMeters / 1000.0).toStringAsFixed(1)} km".replaceAll(".", ","),
                    color: black,
                    size: Sizes.textSizeSmall,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: DMSansRegularText(
                      text: "~ ${navigationService.walkingTimeInMinutes.toInt()} min".replaceAll(".", ","),
                      color: black,
                      size: Sizes.textSizeSmall,
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: DMSansRegularText(
                      text: AppUtils.formatTime(TimeOfDay.fromDateTime(DateTime.now().add(Duration(minutes: navigationService.walkingTimeInMinutes.toInt()))).hour, TimeOfDay.fromDateTime(DateTime.now().add(Duration(minutes: navigationService.walkingTimeInMinutes.toInt()))).minute),
                      color: black,
                      size: Sizes.textSizeSmall,
                    ),
                  ),
                )
              ],
            ),
          ),
          widget.navigationJob.isUserLocationBased && showStartButton ? ScaleTap(
            duration: animationDuration,
            scaleCurve: animationCurve,
            scaleMinValue: 0.75,
            onPressed: () async{
              Coordinates? userLocation = await navigationService.userLocationService.getLocation();
              if(userLocation != null){
                UnityCommunicationService.setMarkerPosition(userLocation);
                UnityCommunicationService.moveCameraTo(userLocation);
                UnityCommunicationService.zoomCameraTo(2.5);
                navigationService.startNavigation();
              }
              setState(() {
                showStartButton = false;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: green,
                borderRadius: BorderRadius.circular(Sizes.borderRadius)
              ),
              margin: EdgeInsets.only(top: Sizes.paddingRegular),
              padding: EdgeInsets.all(Sizes.paddingSmall),
              alignment: Alignment.center,
              child: DMSansBoldText(
                text: "Start navigation",
                size: Sizes.textSizeSmall,
                color: black,
              ),
            ),
          ) : const SizedBox()
        ],
      ),
    );
  }
}
