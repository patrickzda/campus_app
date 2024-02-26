import 'package:campus_app/constants/constants.dart';
import 'package:campus_app/constants/data/course_data.dart';
import 'package:campus_app/data/building.dart';
import 'package:campus_app/data/coordinates.dart';
import 'package:campus_app/data/navigation_job.dart';
import 'package:campus_app/data/navigation_node.dart';
import 'package:campus_app/pages/search_page.dart';
import 'package:campus_app/services/navigation_service.dart';
import 'package:campus_app/services/user_location_service.dart';
import 'package:campus_app/widgets/entity_card_widget.dart';
import 'package:campus_app/widgets/location_button_widget.dart';
import 'package:campus_app/widgets/map_widget.dart';
import 'package:campus_app/widgets/perspective_switch_widget.dart';
import 'package:campus_app/widgets/remove_glow_behaviour.dart';
import 'package:campus_app/widgets/route_preview_popup_widget.dart';
import 'package:campus_app/widgets/tag_bar_widget.dart';
import 'package:campus_app/widgets/text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:location/location.dart';
import 'package:remix_flutter/remix_flutter.dart';
import '../constants/sizes.dart';
import '../data/campus_entity.dart';
import '../services/unity_communication_service.dart';
import '../utils/AppUtils.dart';

class MainPage extends StatefulWidget {
  NavigationJob? navigationJob;

  MainPage({super.key, this.navigationJob});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  PageController pageController = PageController(viewportFraction: 0.8);
  int selectedCardIndex = 0;
  List<CampusEntity> entities = [];
  bool expandedCards = true;

  @override
  void initState() {
    resumeUnity();    //???
    if(widget.navigationJob != null){
      navigationService.initNavigation(widget.navigationJob!.startNode, widget.navigationJob!.destinationNode);
    }else{
      navigationService.stopNavigation();
    }

    entities.addAll(navigationService.buildings);
    entities.addAll(navigationService.canteens);
    for(int i = 0; i < navigationService.courses.length; i++){
      if(navigationService.courses[i].isCurrent()){
        entities.add(navigationService.courses[i]);
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Sizes().initialize(context);
    return Scaffold(
      body: Stack(
        children: [
          const MapWidget(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: Sizes.paddingRegular, bottom: Sizes.paddingRegular),
              child: widget.navigationJob == null ? Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: Sizes.paddingSmall, right: Sizes.paddingRegular, left: Sizes.paddingRegular),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: (){
                              AppUtils.switchPage(context, const SearchPage());
                            },
                            child: Hero(
                              tag: "SEARCH_BAR",
                              child: Container(
                                decoration: BoxDecoration(
                                  color: white,
                                  borderRadius: BorderRadius.circular(Sizes.borderRadius)
                                ),
                                margin: EdgeInsets.only(right: Sizes.paddingSmall),
                                padding: EdgeInsets.all(Sizes.paddingSmall),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: Sizes.paddingSmall),
                                      child: Icon(
                                        RemixIcon.search_line,
                                        size: Sizes.iconSize,
                                        color: black,
                                      ),
                                    ),
                                    DMSansMediumText(
                                      text: "Search buildings, courses, ...",
                                      color: darkGrey,
                                      size: Sizes.textSizeSmall,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        ScaleTap(
                          duration: animationDuration,
                          scaleCurve: animationCurve,
                          scaleMinValue: 0.75,
                          onPressed: (){
                            setState(() {
                              expandedCards = !expandedCards;
                              selectedCardIndex = 0;
                            });

                            if(entities.isNotEmpty && expandedCards){
                              if(!(entities[0] is Building && !(entities[0] as Building).isOnMainCampus)){
                                UnityCommunicationService.moveCameraTo(entities[0].getPosition());
                                UnityCommunicationService.zoomCameraTo(4);
                              }else{
                                UnityCommunicationService.resetCamera();
                              }
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(Sizes.borderRadius)
                            ),
                            padding: EdgeInsets.all(Sizes.paddingSmall),
                            child: Icon(
                              expandedCards ? RemixIcon.carousel_view : RemixIcon.layout_bottom_2_line,
                              size: Sizes.iconSize,
                              color: black,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Hero(
                    tag: "TAG_BAR",
                    child: TagBarWidget(
                      onChanged: (int index){
                        entities.clear();
                        if(index == 0){
                          entities.addAll(navigationService.buildings);
                          entities.addAll(navigationService.canteens);
                        }else if(index == 1){
                          entities.addAll(navigationService.buildings);
                        }else if(index == 2){
                          entities.addAll(navigationService.canteens);
                        }else if(index == 3){
                          for(int i = 0; i < navigationService.courses.length; i++){
                            if(navigationService.courses[i].isCurrent()){
                              entities.add(navigationService.courses[i]);
                            }
                          }
                        }

                        selectedCardIndex = 0;

                        if(expandedCards){
                          pageController.jumpToPage(0);
                        }

                        if(entities.isNotEmpty && expandedCards){
                          if(!(entities[0] is Building && !(entities[0] as Building).isOnMainCampus)){
                            UnityCommunicationService.moveCameraTo(entities[0].getPosition());
                            UnityCommunicationService.zoomCameraTo(4);
                          }else{
                            UnityCommunicationService.resetCamera();
                          }
                        }

                        setState(() {});
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: Sizes.paddingSmall, right: Sizes.paddingRegular, left: Sizes.paddingRegular),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        LocationButtonWidget()
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: Sizes.paddingSmall, right: Sizes.paddingRegular, left: Sizes.paddingRegular),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        PerspectiveSwitchWidget()
                      ],
                    ),
                  )
                ],
              ) : Padding(
                padding: EdgeInsets.only(right: Sizes.paddingSmall),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    LocationButtonWidget()
                  ],
                ),
              ),
            ),
          ),
          widget.navigationJob != null ? Align(
            alignment: Alignment.bottomCenter,
            child: RoutePreviewPopupWidget(
              navigationJob: widget.navigationJob!,
              onClose: (){
                navigationService.stopNavigation();
                Future.delayed(animationDuration).then((value){
                  setState(() {
                    widget.navigationJob = null;
                  });
                });
              },
            )
          ) : Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSwitcher(
              duration: animationDuration,
              reverseDuration: animationDuration,
              switchInCurve: animationCurve,
              switchOutCurve: animationCurve,
              child: expandedCards ? SizedBox(
                width: double.infinity,
                height: Sizes.heightPercent * 40,
                child: RemoveGlowBehavior(
                  child: PageView(
                    scrollDirection: Axis.horizontal,
                    controller: pageController,
                    padEnds: false,
                    children: List.generate(entities.length + 1, (int index) {
                      if(index == entities.length){
                        return Container(
                          width: Sizes.widthPercent * 30,
                          height: Sizes.heightPercent * 40,
                          margin: EdgeInsets.only(left: Sizes.paddingRegular, bottom: Sizes.paddingRegular),
                        );
                      }else{
                        return EntityCardWidget(entity: entities[index], isSelected: selectedCardIndex == index);
                      }
                    }),
                    onPageChanged: (int pageIndex){
                      if(pageIndex == entities.length){
                        pageController.animateToPage(entities.length - 1, duration: animationDuration, curve: animationCurve);
                        return;
                      }

                      setState(() {
                        selectedCardIndex = pageIndex;
                      });

                      if(!(entities[selectedCardIndex] is Building && !(entities[selectedCardIndex] as Building).isOnMainCampus) && entities[selectedCardIndex].getPosition().latitude != 0 && entities[selectedCardIndex].getPosition().longitude != 0){
                        UnityCommunicationService.moveCameraTo(entities[selectedCardIndex].getPosition());
                        UnityCommunicationService.zoomCameraTo(3);
                      }else{
                        UnityCommunicationService.resetCamera();
                      }
                    },
                  ),
                ),
              ) : ScaleTap(
                duration: animationDuration,
                scaleCurve: animationCurve,
                scaleMinValue: 0.95,
                onPressed: (){
                  setState(() {
                    expandedCards = !expandedCards;
                    selectedCardIndex = 0;
                  });

                  if(entities.isNotEmpty && expandedCards){
                    if(!(entities[0] is Building && !(entities[0] as Building).isOnMainCampus)){
                      UnityCommunicationService.moveCameraTo(entities[0].getPosition());
                      UnityCommunicationService.zoomCameraTo(4);
                    }else{
                      UnityCommunicationService.resetCamera();
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: green,
                    borderRadius: BorderRadius.circular(Sizes.borderRadius)
                  ),
                  margin: EdgeInsets.only(right: Sizes.paddingRegular, left: Sizes.paddingRegular, bottom: Sizes.paddingRegular),
                  padding: EdgeInsets.all(Sizes.paddingRegular),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DMSansBoldText(
                        text: "Show campus entities",
                        size: Sizes.textSizeSmall,
                        color: black
                      ),
                      Icon(
                        RemixIcon.arrow_up_line,
                        size: Sizes.iconSize,
                        color: black,
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

}
