import 'package:campus_app/constants/Sizes.dart';
import 'package:campus_app/constants/constants.dart';
import 'package:campus_app/data/navigation_job.dart';
import 'package:campus_app/pages/main_page.dart';
import 'package:campus_app/pages/search_page.dart';
import 'package:campus_app/utils/AppUtils.dart';
import 'package:campus_app/widgets/text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:remix_flutter/remix_flutter.dart';

typedef VoidCallback = void Function();

class RoutePreviewPopupWidget extends StatelessWidget {
  final NavigationJob navigationJob;
  final void Function() onClose;

  const RoutePreviewPopupWidget({super.key, required this.navigationJob, required this.onClose});

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
                    onClose();
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
                    text: navigationJob.isUserLocationBased ? "My location" : navigationJob.startEntity!.getShortName(),
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
                    text: navigationJob.destinationEntity.getShortName(),
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
          navigationJob.isUserLocationBased ? GestureDetector(
            onTap: (){
              navigationService.startNavigation();
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
