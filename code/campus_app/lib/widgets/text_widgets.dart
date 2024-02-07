import 'package:flutter/material.dart';

import '../constants/Constants.dart';
import '../constants/Sizes.dart';

class DMSansRegularText extends StatelessWidget {
  final double size;
  final Color color;
  final TextAlign textAlign;
  String text;
  final int charLimit;
  final bool underline;

  DMSansRegularText({super.key, this.size = 10, this.color = black, this.textAlign = TextAlign.left, this.text = "", this.charLimit = 1000, this.underline = false}) {
    if(text.length > charLimit){
      text = text.substring(0, charLimit);
      text = "$text...";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontFamily: "DM Sans Regular",
        decoration: underline ? TextDecoration.underline : TextDecoration.none,
      ),
    );
  }
}

class DMSansMediumText extends StatelessWidget {
  final double size;
  final Color color;
  final TextAlign textAlign;
  String text;
  final int charLimit;
  final bool underline;

  DMSansMediumText({super.key, this.size = 10, this.color = black, this.textAlign = TextAlign.left, this.text = "", this.charLimit = 1000, this.underline = false}) {
    if(text.length > charLimit){
      text = text.substring(0, charLimit);
      text = "$text...";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontFamily: "DM Sans Medium",
        decoration: underline ? TextDecoration.underline : TextDecoration.none
      ),
    );
  }
}

class DMSansSemiBoldText extends StatelessWidget {
  final double size;
  final Color color;
  final TextAlign textAlign;
  String text;
  final int charLimit;
  final bool underline;

  DMSansSemiBoldText({super.key, this.size = 10, this.color = black, this.textAlign = TextAlign.left, this.text = "", this.charLimit = 1000, this.underline = false}) {
    if(text.length > charLimit){
      text = text.substring(0, charLimit);
      text = "$text...";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontFamily: "DM Sans SemiBold",
        decoration: underline ? TextDecoration.underline : TextDecoration.none
      ),
    );
  }
}

class DMSansBoldText extends StatelessWidget {
  final double size;
  final Color color;
  final TextAlign textAlign;
  String text;
  final int charLimit;
  final bool underline;

  DMSansBoldText({super.key, this.size = 10, this.color = black, this.textAlign = TextAlign.left, this.text = "", this.charLimit = 1000, this.underline = false}) {
    if(text.length > charLimit){
      text = text.substring(0, charLimit);
      text = "$text...";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontFamily: "DM Sans Bold",
        decoration: underline ? TextDecoration.underline : TextDecoration.none
      ),
    );
  }
}

class DMSansBlackText extends StatelessWidget {
  final double size;
  final Color color;
  final TextAlign textAlign;
  String text;
  final int charLimit;
  final bool underline;

  DMSansBlackText({super.key, this.size = 10, this.color = black, this.textAlign = TextAlign.left, this.text = "", this.charLimit = 1000, this.underline = false}) {
    if(text.length > charLimit){
      text = text.substring(0, charLimit);
      text = "$text...";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontFamily: "DM Sans Black",
        decoration: underline ? TextDecoration.underline : TextDecoration.none
      ),
    );
  }
}