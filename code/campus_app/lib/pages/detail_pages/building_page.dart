import 'package:campus_app/constants/Constants.dart';
import 'package:campus_app/constants/data/course_data.dart';
import 'package:campus_app/data/building.dart';
import 'package:campus_app/data/course_event.dart';
import 'package:campus_app/pages/detail_pages/room_page.dart';
import 'package:campus_app/pages/main_page.dart';
import 'package:campus_app/utils/AppUtils.dart';
import 'package:campus_app/widgets/data_chip_widget.dart';
import 'package:campus_app/widgets/remove_glow_behaviour.dart';
import 'package:campus_app/widgets/text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:remix_flutter/remix_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../constants/Sizes.dart';
import '../../data/course.dart';
import '../../data/room.dart';
import 'course_page.dart';

class BuildingPage extends StatelessWidget {
  final Building building;
  final List<Widget> dataChipWidgets = [];
  List<Course> currentCourses = [];
  List<Room> filledRooms = [];
  PageController pageController = PageController(viewportFraction: 1 + (Sizes.paddingSmall / Sizes.width));

  BuildingPage({super.key, required this.building}){
    for(int i = 0; i < building.rooms.length; i++){
      for(int j = 0; j < building.rooms[i].courses.length; j++){
        if(building.rooms[i].courses[j].isCurrent() && !currentCourses.contains(building.rooms[i].courses[j])){
          currentCourses.add(building.rooms[i].courses[j]);
          filledRooms.add(building.rooms[i]);
        }
      }
    }

    dataChipWidgets.add(DataChipWidget(textValue: "${AppUtils.formatTime(building.openingHour, building.openingMinute)} - ${AppUtils.formatTime(building.closingHour, building.closingMinute)}"));
    dataChipWidgets.add(DataChipWidget(textValue: "${currentCourses.length} current ${currentCourses.length == 1 ? "course" : "courses"}"));
    dataChipWidgets.add(DataChipWidget(textValue: building.address));
    if(building.canteens.isNotEmpty){
      dataChipWidgets.add(const DataChipWidget(iconValue: RemixIcon.restaurant_line));
    }
  }

  @override
  Widget build(BuildContext context) {
    Sizes().initialize(context);
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Sizes.paddingRegular),
          child: Column(
            children: [
              GestureDetector(
                onTap: (){
                  AppUtils.switchPage(context, MainPage());
                },
                child: Container(
                  padding: EdgeInsets.only(bottom: Sizes.paddingRegular),
                  decoration: const BoxDecoration(
                    color: white
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: Sizes.paddingSmall),
                        child: Icon(
                          RemixIcon.arrow_left_line,
                          color: black,
                          size: Sizes.iconSize,
                        ),
                      ),
                      DMSansMediumText(
                        text: "Building",
                        size: Sizes.textSizePageTitle,
                        color: black,
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: RemoveGlowBehavior(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: Sizes.paddingRegular),
                          child: DMSansBoldText(
                            text: building.names[0],
                            color: black,
                            size: Sizes.textSizeBig,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: Sizes.paddingRegular),
                          width: double.infinity,
                          height: Sizes.heightPercent * 25,
                          decoration: BoxDecoration(
                            color: lightGrey,
                            borderRadius: BorderRadius.circular(Sizes.borderRadius)
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Wrap(
                            runSpacing: Sizes.paddingSmall * 0.5,
                            spacing: Sizes.paddingSmall * 0.5,
                            children: dataChipWidgets,
                          ),
                        ),
                        currentCourses.isNotEmpty ? Padding(
                          padding: EdgeInsets.only(top: Sizes.paddingRegular, bottom: Sizes.paddingSmall),
                          child: DMSansBoldText(
                            text: "Current courses",
                            size: Sizes.textSizePageTitle,
                            color: black,
                          ),
                        ) : const SizedBox(),
                        currentCourses.isNotEmpty ? SizedBox(
                          height: Sizes.heightPercent * 15,
                          child: RemoveGlowBehavior(
                            child: PageView(
                              controller: pageController,
                              scrollDirection: Axis.horizontal,
                              children: List.generate(currentCourses.length, (int index){
                                CourseEvent currentEvent = currentCourses[index].getCurrentEvent()!;
                                String time = "${AppUtils.formatTime(currentEvent.start.hour, currentEvent.start.minute)} - ${AppUtils.formatTime(currentEvent.end.hour, currentEvent.end.minute)}";

                                return ScaleTap(
                                  duration: animationDuration,
                                  scaleCurve: animationCurve,
                                  scaleMinValue: 0.75,
                                  onPressed: (){
                                    AppUtils.switchPage(context, CoursePage(course: currentCourses[index]));
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: Sizes.paddingSmall / 2),
                                    padding: EdgeInsets.all(Sizes.paddingRegular),
                                    height: Sizes.heightPercent * 15,
                                    decoration: BoxDecoration(
                                      color: lightGrey,
                                      borderRadius: BorderRadius.circular(Sizes.borderRadius)
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        DMSansBoldText(
                                          text: currentCourses[index].name,
                                          color: black,
                                          size: Sizes.textSizeSmall,
                                        ),
                                        DMSansMediumText(
                                          text: time,
                                          color: black,
                                          size: Sizes.textSizeSmall,
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ) : const SizedBox(),
                        currentCourses.isNotEmpty ? Padding(
                          padding: EdgeInsets.only(top: Sizes.paddingSmall),
                          child: Align(
                            alignment: Alignment.center,
                            child: SmoothPageIndicator(
                              controller: pageController,
                              count: currentCourses.length,
                              effect: SlideEffect(
                                activeDotColor: green,
                                dotColor: lightGrey,
                                dotWidth: Sizes.widthPercent * 3,
                                dotHeight: Sizes.widthPercent * 3,
                                spacing: Sizes.paddingSmall * 0.5
                              ),
                            ),
                          ),
                        ) : const SizedBox(),
                        building.rooms.isNotEmpty ? Padding(
                          padding: EdgeInsets.only(top: Sizes.paddingRegular, bottom: Sizes.paddingSmall),
                          child: DMSansBoldText(
                            text: "Rooms",
                            size: Sizes.textSizePageTitle,
                            color: black,
                          ),
                        ) : const SizedBox(),
                        building.rooms.isNotEmpty ? Wrap(
                          spacing: Sizes.paddingRegular,
                          runSpacing: Sizes.paddingRegular,
                          children: List.generate(building.rooms.length, (int index){
                            return ScaleTap(
                              duration: animationDuration,
                              scaleCurve: animationCurve,
                              scaleMinValue: 0.75,
                              onPressed: (){
                                AppUtils.switchPage(context, RoomPage(room: building.rooms[index]));
                              },
                              child: Container(
                                width: (Sizes.width - Sizes.paddingRegular * 5) / 4,
                                height: (Sizes.width - Sizes.paddingRegular * 5) / 4,
                                padding: EdgeInsets.all(Sizes.paddingSmall * 0.5),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: filledRooms.contains(building.rooms[index]) ? lightGrey : green,
                                  borderRadius: BorderRadius.circular(Sizes.borderRadius)
                                ),
                                child: DMSansBoldText(
                                  text: building.rooms[index].name,
                                  color: black,
                                  size: Sizes.textSizeSmall * 0.8,
                                  charLimit: 9,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }),
                        ) : Container(
                          width: double.infinity,
                          height: Sizes.heightPercent * 30,
                          alignment: Alignment.center,
                          child: DMSansRegularText(
                            text: "No rooms available",
                            textAlign: TextAlign.center,
                            color: black,
                            size: Sizes.textSizeSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ScaleTap(
                duration: animationDuration,
                scaleCurve: animationCurve,
                scaleMinValue: 0.75,
                onPressed: (){

                },
                child: Container(
                  margin: EdgeInsets.only(top: Sizes.paddingRegular),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: green,
                    borderRadius: BorderRadius.circular(Sizes.borderRadius)
                  ),
                  padding: EdgeInsets.all(Sizes.paddingRegular),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DMSansBoldText(
                        text: "Start navigation",
                        color: black,
                        size: Sizes.textSizeSmall,
                      ),
                      Icon(
                        RemixIcon.arrow_right_line,
                        color: black,
                        size: Sizes.iconSize
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
