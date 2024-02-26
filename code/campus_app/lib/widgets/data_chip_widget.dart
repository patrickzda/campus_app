import 'package:campus_app/constants/Constants.dart';
import 'package:campus_app/widgets/text_widgets.dart';
import 'package:flutter/material.dart';
import '../constants/Sizes.dart';

class DataChipWidget extends StatelessWidget {
  final String? textValue;
  final IconData? iconValue;

  const DataChipWidget({super.key, this.textValue, this.iconValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(Sizes.borderRadius)
      ),
      padding: EdgeInsets.symmetric(vertical: Sizes.paddingSmall, horizontal: textValue != null ? Sizes.paddingRegular : Sizes.paddingSmall),
      child: textValue != null ? DMSansRegularText(
        text: textValue!,
        textAlign: TextAlign.center,
        size: Sizes.textSizeSmall * 0.9,
        color: black,
        charLimit: 40,
      ) : Icon(
        iconValue!,
        color: black,
        size: Sizes.iconSize * 0.8,
      ),
    );
  }
}
