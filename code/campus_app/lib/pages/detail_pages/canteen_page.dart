import 'package:campus_app/constants/Constants.dart';
import 'package:campus_app/data/canteen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:remix_flutter/remix_flutter.dart';
import '../../constants/Sizes.dart';
import '../../data/meal.dart' as meal;
import '../../utils/AppUtils.dart';
import '../../widgets/data_chip_widget.dart';
import '../../widgets/remove_glow_behaviour.dart';
import '../../widgets/text_widgets.dart';
import '../main_page.dart';

class CanteenPage extends StatefulWidget {
  final Canteen canteen;
  const CanteenPage({super.key, required this.canteen});

  @override
  State<CanteenPage> createState() => _CanteenPageState();
}

class _CanteenPageState extends State<CanteenPage> {
  List<meal.Meal> mealPlan = [];

  @override
  void initState() {
    meal.Meal.getCanteenMealPlan(widget.canteen.id).then((List<meal.Meal> results){
      setState(() {
        mealPlan = results;
      });
    });
    super.initState();
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
                  margin: EdgeInsets.only(bottom: Sizes.paddingRegular),
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
                        text: "Canteen",
                        size: Sizes.textSizePageTitle,
                        color: black,
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: mealPlan.isNotEmpty ? RemoveGlowBehavior(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: Sizes.paddingRegular),
                          child: DMSansBoldText(
                            text: widget.canteen.name,
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
                              DataChipWidget(textValue: widget.canteen.building.shortName),
                              DataChipWidget(textValue: widget.canteen.getDescription()),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: Sizes.paddingSmall),
                          padding: EdgeInsets.only(top: Sizes.paddingRegular),
                          child: DMSansBoldText(
                            text: "Current meals",
                            size: Sizes.textSizePageTitle,
                            color: black,
                          ),
                        ),
                        Column(
                          children: List.generate(mealPlan.length, (int index){
                            return Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(bottom: Sizes.paddingSmall),
                              padding: EdgeInsets.all(Sizes.paddingRegular),
                              decoration: BoxDecoration(
                                color: lightGrey,
                                borderRadius: BorderRadius.circular(Sizes.borderRadius)
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      DMSansRegularText(
                                        text: mealPlan[index].type == "none" ? "meat" : mealPlan[index].type,
                                        size: Sizes.textSizeSmall,
                                        color: green
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Icon(
                                            RemixIcon.bowl_line,
                                            color: badgeToColor(mealPlan[index].health),
                                            size: Sizes.paddingRegular,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: Sizes.paddingSmall * 0.5),
                                            child: Icon(
                                              RemixIcon.earth_line,
                                              color: badgeToColor(mealPlan[index].emission),
                                              size: Sizes.paddingRegular,
                                            ),
                                          ),
                                          Icon(
                                            RemixIcon.drop_line,
                                            color: badgeToColor(mealPlan[index].water),
                                            size: Sizes.paddingRegular,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: Sizes.paddingSmall),
                                    child: DMSansBoldText(
                                      text: mealPlan[index].name,
                                      size: Sizes.textSizeRegular,
                                      color: black
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: Sizes.paddingSmall),
                                    child: DMSansRegularText(
                                      text: "${mealPlan[index].studentPrice}€ - ${mealPlan[index].memberPrice}€ - ${mealPlan[index].externalPrice}€",
                                      size: Sizes.textSizeSmall,
                                      color: black
                                    ),
                                  )
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ) : Container(
                  alignment: Alignment.center,
                  child: DMSansRegularText(
                    text: "No meals available",
                    textAlign: TextAlign.center,
                    color: black,
                    size: Sizes.textSizeSmall,
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

  Color badgeToColor(meal.Badge badge){
    if(badge == meal.Badge.green){
      return green;
    }else if(badge == meal.Badge.yellow){
      return Colors.amber;
    }else if(badge == meal.Badge.red){
      return Colors.red;
    }else{
      return Colors.transparent;
    }
  }

}
