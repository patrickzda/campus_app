import 'package:campus_app/constants/Sizes.dart';
import 'package:campus_app/constants/constants.dart';
import 'package:campus_app/widgets/remove_glow_behaviour.dart';
import 'package:campus_app/widgets/text_widgets.dart';
import 'package:flutter/material.dart';

typedef VoidCallback = void Function();

class TagBarWidget extends StatefulWidget {
  final void Function(int) onChanged;
  final Color tagColor;

  const TagBarWidget({super.key, required this.onChanged, this.tagColor = white});

  @override
  State<TagBarWidget> createState() => _TagBarWidgetState();
}

class _TagBarWidgetState extends State<TagBarWidget> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Sizes().initialize(context);
    return RemoveGlowBehavior(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tagNames.length, (int index){
            return GestureDetector(
              onTap: (){
                setState(() {
                  selectedIndex = index;
                  widget.onChanged(index);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: widget.tagColor,
                  borderRadius: BorderRadius.circular(Sizes.borderRadius)
                ),
                margin: EdgeInsets.only(right: index == (tagNames.length - 1) ? Sizes.paddingRegular : Sizes.paddingSmall, left: index == 0 ? Sizes.paddingRegular : 0),
                padding: EdgeInsets.all(Sizes.paddingSmall * 0.85),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: tagColors[index],
                        borderRadius: BorderRadius.circular(Sizes.widthPercent)
                      ),
                      padding: EdgeInsets.all(Sizes.paddingSmall / 3),
                      child: Icon(
                        tagIcons[index],
                        color: black,
                        size: Sizes.widthPercent * 4.5,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: Sizes.paddingSmall),
                      child: DMSansBoldText(
                        text: tagNames[index],
                        color: index == selectedIndex ? black : darkGrey,
                        size: Sizes.textSizeSmall * 0.8
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
