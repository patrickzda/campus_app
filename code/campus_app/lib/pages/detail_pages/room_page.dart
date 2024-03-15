import 'package:campus_app/constants/Constants.dart';
import 'package:campus_app/data/room.dart';
import 'package:campus_app/pages/detail_pages/course_page.dart';
import 'package:campus_app/widgets/data_chip_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:remix_flutter/remix_flutter.dart';
import '../../constants/Sizes.dart';
import '../../data/course.dart';
import '../../data/course_event.dart';
import '../../utils/AppUtils.dart';
import '../../widgets/remove_glow_behaviour.dart';
import '../../widgets/text_widgets.dart';
import '../main_page.dart';

class RoomPage extends StatelessWidget {
  final Room room;
  List<Course> currentCourses = [];

  RoomPage({super.key, required this.room}){
    for(int i = 0; i < room.courses.length; i++){
      if(room.courses[i].isCurrent()){
        currentCourses.add(room.courses[i]);
      }
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        text: "Room",
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
                            text: room.name,
                            color: black,
                            size: Sizes.textSizeBig,
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Wrap(
                            runSpacing: Sizes.paddingSmall * 0.5,
                            spacing: Sizes.paddingSmall * 0.5,
                            children: [
                              DataChipWidget(textValue: room.type),
                              DataChipWidget(textValue: "${room.seatCount} seats"),
                            ],
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
                        currentCourses.isNotEmpty ? Column(
                          mainAxisSize: MainAxisSize.min,
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
                                margin: EdgeInsets.only(bottom: Sizes.paddingSmall),
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
                        ) : Container(
                          width: double.infinity,
                          height: Sizes.heightPercent * 30,
                          alignment: Alignment.center,
                          child: DMSansRegularText(
                            text: "No courses available",
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
            ],
          ),
        ),
      ),
    );
  }
}
