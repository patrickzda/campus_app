import 'package:campus_app/data/campus_entity.dart';
import 'package:campus_app/data/canteen.dart';
import 'package:campus_app/pages/detail_pages/building_page.dart';
import 'package:campus_app/pages/detail_pages/canteen_page.dart';
import 'package:campus_app/pages/detail_pages/course_page.dart';
import 'package:campus_app/pages/detail_pages/event_page.dart';
import 'package:campus_app/widgets/text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:remix_flutter/remix_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../constants/Constants.dart';
import '../constants/Sizes.dart';
import '../data/building.dart';
import '../data/course.dart';
import '../data/event.dart';
import '../pages/search_page.dart';
import '../utils/AppUtils.dart';

class EntityCardWidget extends StatelessWidget {
  final CampusEntity entity;
  final bool isSelected;
  const EntityCardWidget({super.key, required this.entity, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      duration: animationDuration,
      scaleCurve: animationCurve,
      scaleMinValue: 0.75,
      onPressed: (){
        if(entity is Building){
          AppUtils.switchPage(context, BuildingPage(building: entity as Building));
        }else if(entity is Course){
          AppUtils.switchPage(context, CoursePage(course: entity as Course));
        }else if(entity is Canteen){
          AppUtils.switchPage(context, CanteenPage(canteen: entity as Canteen));
        }else if(entity is Event){
          AppUtils.switchPage(context, EventPage(event: entity as Event));
        }
      },
      child: AnimatedContainer(
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
                      charLimit: 8,
                    ),
                    DMSansMediumText(
                      text: entity is Course ? "" : entity is Event ? "${(entity as Event).day}. ${(entity as Event).month}" : entity.getDescription().contains("OPEN") ? "Open" : "Closed",
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
                    charLimit: entity is Event ? 45 : 55,
                  ),
                )
              ],
            ),
            ScaleTap(
              duration: animationDuration,
              scaleCurve: animationCurve,
              scaleMinValue: !(entity is Building && !(entity as Building).isOnMainCampus) ? 0.75 : 1,
              onPressed: (){
                if(entity is Event){
                  try{
                    launchUrlString((entity as Event).url);
                  }catch(e){
                    print(e);
                  }
                }else if(!(entity is Building && !(entity as Building).isOnMainCampus) && entity.getPosition().latitude != 0 && entity.getPosition().longitude != 0){
                  AppUtils.switchPage(context, SearchPage(destinationEntity: entity));
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: !(entity is Building && !(entity as Building).isOnMainCampus) && entity.getPosition().latitude != 0 && entity.getPosition().longitude != 0 ? green : (entity is Building || entity is Canteen || entity is Course) ? lightGrey : green,
                  borderRadius: BorderRadius.circular(Sizes.borderRadius)
                ),
                padding: EdgeInsets.all(Sizes.paddingSmall),
                child: Row(
                  mainAxisAlignment: !(entity is Building && !(entity as Building).isOnMainCampus) && entity.getPosition().latitude != 0 && entity.getPosition().longitude != 0 || entity is Event ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                  children: [
                    DMSansMediumText(
                      text: !(entity is Building && !(entity as Building).isOnMainCampus) && entity.getPosition().latitude != 0 && entity.getPosition().longitude != 0 ? "Start navigation" : (entity is Building || entity is Canteen || entity is Course) ? "Building not on campus" : "Open website",
                      color: black,
                      size: Sizes.textSizeSmall,
                    ),
                    !(entity is Building && !(entity as Building).isOnMainCampus) && entity.getPosition().latitude != 0 && entity.getPosition().longitude != 0 || entity is Event ? Icon(
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
      ),
    );
  }
}
