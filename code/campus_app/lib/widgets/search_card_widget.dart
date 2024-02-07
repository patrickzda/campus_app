import 'package:campus_app/constants/Constants.dart';
import 'package:campus_app/data/campus_entity.dart';
import 'package:campus_app/utils/AppUtils.dart';
import 'package:campus_app/widgets/text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:remix_flutter/remix_flutter.dart';
import '../constants/Sizes.dart';

typedef VoidCallback = void Function();

class SearchCardWidget extends StatelessWidget {
  final CampusEntity campusEntity;
  final bool currentLocationCard;
  final void Function(CampusEntity) onNavigationClicked;
  final void Function() onUserLocationSelected;

  const SearchCardWidget({super.key, required this.campusEntity, required this.onNavigationClicked, required this.onUserLocationSelected, this.currentLocationCard = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(currentLocationCard){
          onUserLocationSelected();
        }else{
          onNavigationClicked(campusEntity);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: Sizes.paddingSmall),
        padding: EdgeInsets.all(Sizes.paddingSmall),
        decoration: BoxDecoration(
          color: currentLocationCard ? green : lightGrey,
          borderRadius: BorderRadius.circular(Sizes.borderRadius)
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DMSansMediumText(
                    text: currentLocationCard ? "Use my location" : campusEntity.getTitle(),
                    color: black,
                    size: Sizes.textSizeSmall
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: (){
                if(currentLocationCard){
                  onUserLocationSelected();
                }else{
                  onNavigationClicked(campusEntity);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: green,
                  borderRadius: BorderRadius.circular(Sizes.borderRadius)
                ),
                margin: EdgeInsets.only(left: Sizes.paddingSmall),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: Sizes.paddingSmall, horizontal: currentLocationCard ? 0 : Sizes.paddingSmall),
                child: Icon(
                  currentLocationCard ? RemixIcon.arrow_right_line : RemixIcon.compass_discover_line,
                  color: black,
                  size: Sizes.iconSize,
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}
