import 'package:campus_app/data/campus_entity.dart';
import 'package:campus_app/widgets/text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:remix_flutter/remix_flutter.dart';
import '../constants/Constants.dart';
import '../constants/Sizes.dart';
import '../data/building.dart';
import '../pages/search_page.dart';
import '../utils/AppUtils.dart';

class EntityCardWidget extends StatelessWidget {
  final CampusEntity entity;
  final bool isSelected;
  const EntityCardWidget({super.key, required this.entity, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: animationDuration,
      curve: animationCurve,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(Sizes.borderRadius)
      ),
      width: Sizes.widthPercent * 30,
      height: Sizes.heightPercent * 40,
      margin: EdgeInsets.only(top: isSelected ? 0 : Sizes.paddingBig * 1.5, left: Sizes.paddingRegular, bottom: Sizes.paddingRegular),
      padding: EdgeInsets.all(Sizes.paddingRegular),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DMSansBoldText(
                    text: entity.getShortName(),
                    size: Sizes.textSizeSmall,
                    color: black,
                  ),
                  DMSansMediumText(
                    text: entity.getDescription().contains("OPEN") ? "Open" : "Closed",
                    size: Sizes.textSizeSmall,
                    color: green,
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: Sizes.paddingRegular),
                child: DMSansBoldText(
                  text: entity.getTitle(),
                  size: Sizes.textSizeRegular,
                  color: black,
                ),
              )
            ],
          ),
          ScaleTap(
            duration: animationDuration,
            scaleCurve: animationCurve,
            scaleMinValue: !(entity is Building && !(entity as Building).isOnMainCampus) ? 0.75 : 1,
            onPressed: (){
              if(!(entity is Building && !(entity as Building).isOnMainCampus)){
                AppUtils.switchPage(context, SearchPage(destinationEntity: entity));
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: !(entity is Building && !(entity as Building).isOnMainCampus) ? green : lightGrey,
                borderRadius: BorderRadius.circular(Sizes.borderRadius)
              ),
              padding: EdgeInsets.all(Sizes.paddingSmall),
              child: Row(
                mainAxisAlignment: !(entity is Building && !(entity as Building).isOnMainCampus) ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                children: [
                  DMSansMediumText(
                    text: !(entity is Building && !(entity as Building).isOnMainCampus) ? "Start navigation" : "Building not on campus",
                    color: black,
                    size: Sizes.textSizeSmall,
                  ),
                  !(entity is Building && !(entity as Building).isOnMainCampus) ? Icon(
                    RemixIcon.arrow_right_line,
                    size: Sizes.iconSize,
                    color: black,
                  ) : const SizedBox(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
