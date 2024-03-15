import 'package:campus_app/widgets/data_chip_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:remix_flutter/remix_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../constants/Constants.dart';
import '../../constants/Sizes.dart';
import '../../data/event.dart';
import '../../utils/AppUtils.dart';
import '../../widgets/text_widgets.dart';
import '../main_page.dart';

class EventPage extends StatelessWidget {
  final Event event;
  const EventPage({super.key, required this.event});

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
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: Sizes.paddingRegular),
                      child: DMSansBoldText(
                        text: event.title,
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
                          DataChipWidget(textValue: event.language),
                          DataChipWidget(textValue: event.time),
                          DataChipWidget(textValue: event.location),
                          DataChipWidget(textValue: "${event.day}. ${event.month}"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ScaleTap(
                duration: animationDuration,
                scaleCurve: animationCurve,
                scaleMinValue: 0.75,
                onPressed: (){
                  try{
                    launchUrlString(event.url);
                  }catch(e){
                    print(e);
                  }
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
                        text: "Open website",
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
