import 'package:campus_app/constants/Sizes.dart';
import 'package:campus_app/constants/constants.dart';
import 'package:campus_app/data/course.dart';
import 'package:campus_app/widgets/data_chip_widget.dart';
import 'package:campus_app/widgets/remove_glow_behaviour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:remix_flutter/remix_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../utils/AppUtils.dart';
import '../../widgets/text_widgets.dart';
import '../main_page.dart';

class CoursePage extends StatelessWidget {
  final Course course;
  final List<Widget> dataChipWidgets = [];

  CoursePage({super.key, required this.course}){
    if(course.supervisor.isNotEmpty){
      dataChipWidgets.add(DataChipWidget(textValue: course.supervisor));
    }
    dataChipWidgets.add(DataChipWidget(textValue: course.language));
    dataChipWidgets.add(DataChipWidget(textValue: course.type));
    dataChipWidgets.add(DataChipWidget(textValue: "${weekdays[course.events.first.start.weekday - 1]}s, ${AppUtils.formatTime(course.events.first.start.hour, course.events.first.start.minute)} - ${AppUtils.formatTime(course.events.first.end.hour, course.events.first.end.minute)}"));
    dataChipWidgets.add(DataChipWidget(textValue: course.events.first.roomNames.first));
    if(course.department.isNotEmpty && !course.department.contains("<")){
      dataChipWidgets.add(DataChipWidget(textValue: course.department));
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
                        text: "Course",
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
                            text: course.fullName,
                            color: black,
                            size: Sizes.textSizeBig,
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
                        Padding(
                          padding: EdgeInsets.only(top: Sizes.paddingRegular, bottom: Sizes.paddingSmall),
                          child: DMSansBoldText(
                            text: "Description",
                            size: Sizes.textSizePageTitle,
                            color: black,
                          ),
                        ),
                        DMSansRegularText(
                          text: course.description,
                          size: Sizes.textSizeSmall,
                          color: black,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: Sizes.paddingRegular, bottom: Sizes.paddingSmall),
                          child: DMSansBoldText(
                            text: "Related studies",
                            size: Sizes.textSizePageTitle,
                            color: black,
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Wrap(
                            runSpacing: Sizes.paddingSmall * 0.5,
                            spacing: Sizes.paddingSmall * 0.5,
                            children: List.generate(course.relatedStudies.length, (int index){
                              return DataChipWidget(textValue: course.relatedStudies[index]);
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ScaleTap(
                      duration: animationDuration,
                      scaleCurve: animationCurve,
                      scaleMinValue: 0.75,
                      onPressed: (){
                        try{
                          launchUrlString(course.isisLink);
                        }catch(e){
                          print(e);
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: Sizes.paddingRegular, right: Sizes.paddingRegular * 0.5),
                        decoration: BoxDecoration(
                          color: course.isisLink.isNotEmpty ? green : lightGrey,
                          borderRadius: BorderRadius.circular(Sizes.borderRadius)
                        ),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(Sizes.paddingRegular),
                        child: DMSansBoldText(
                          text: "ISIS",
                          color: black,
                          size: Sizes.textSizeSmall,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ScaleTap(
                      duration: animationDuration,
                      scaleCurve: animationCurve,
                      scaleMinValue: 0.75,
                      onPressed: (){
                        try{
                          launchUrlString(course.mosesLink);
                        }catch(e){
                          print(e);
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: Sizes.paddingRegular, left: Sizes.paddingRegular * 0.5),
                        decoration: BoxDecoration(
                          color: course.mosesLink.isNotEmpty ? green : lightGrey,
                          borderRadius: BorderRadius.circular(Sizes.borderRadius)
                        ),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(Sizes.paddingRegular),
                        child: DMSansBoldText(
                          text: "MOSES",
                          color: black,
                          size: Sizes.textSizeSmall,
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
