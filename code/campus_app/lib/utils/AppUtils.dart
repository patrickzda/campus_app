import 'package:campus_app/constants/Constants.dart';
import 'package:campus_app/data/building.dart';
import 'package:campus_app/data/campus_entity.dart';
import 'package:campus_app/data/canteen.dart';
import 'package:campus_app/data/navigation_job.dart';
import 'package:campus_app/widgets/text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../constants/Sizes.dart';

class AppUtils{

  static void switchPage(BuildContext context, Widget newPage){
    Navigator.pushAndRemoveUntil(context, PageTransition(
      type: PageTransitionType.fade,
      child: newPage,
      curve: Curves.linear,
      duration: animationDuration,
      reverseDuration: animationDuration,
    ), (Route<dynamic> route) => false);
  }

  static String formatTime(int hour, int minute){
    return "${hour.toString().padLeft(2, "0")}:${minute.toString().padLeft(2, "0")}";
  }

  static Color getColorForEntity(CampusEntity campusEntity){
    if(campusEntity is Building){
      return blue;
    }else if(campusEntity is Canteen){
      return yellow;
    }else{
      return white;
    }
  }

  static IconData getIconForEntity(CampusEntity campusEntity){
    if(campusEntity is Building){
      return tagIcons[1];
    }else if(campusEntity is Canteen){
      return tagIcons[2];
    }else{
      return tagIcons[3];
    }
  }

  static void showSnackBarWidget(BuildContext context, String title){
    final SnackBar snackBar = SnackBar(
      elevation: 0,
      content: DMSansMediumText(
        text: title,
        color: black,
        size: Sizes.textSizeSmall,
      ),
      backgroundColor: green,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 750),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.borderRadius)
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

}