import 'dart:math';
import 'package:campus_app/constants/constants.dart';
import 'package:campus_app/data/building.dart';
import 'package:campus_app/data/canteen.dart';
import 'package:campus_app/data/coordinates.dart';
import 'package:campus_app/data/navigation_job.dart';
import 'package:campus_app/data/navigation_node.dart';
import 'package:campus_app/pages/main_page.dart';
import 'package:campus_app/services/navigation_service.dart';
import 'package:campus_app/utils/AppUtils.dart';
import 'package:campus_app/widgets/input_widget.dart';
import 'package:campus_app/widgets/remove_glow_behaviour.dart';
import 'package:campus_app/widgets/search_card_widget.dart';
import 'package:campus_app/widgets/tag_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:remix_flutter/remix_flutter.dart';
import '../constants/Sizes.dart';
import '../data/campus_entity.dart';
import '../widgets/text_widgets.dart';

class SearchPage extends StatefulWidget {
  final CampusEntity? destinationEntity;

  const SearchPage({super.key, this.destinationEntity});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String destinationSearchTerm = "", startSearchTerm = "";
  CampusEntity? destinationEntity, startEntity;
  FocusNode focusNode = FocusNode();
  List<CampusEntity> entities = [], searchResults = [];
  bool isDestinationInput = true;
  TextEditingController destinationController = TextEditingController(), startController = TextEditingController();
  Coordinates? userLocation;
  CampusEntityType? filter;

  @override
  void initState() {
    if(widget.destinationEntity != null){
      selectEntity(widget.destinationEntity!);
    }else{
      Future.delayed(animationDuration).then((_){
        focusNode.requestFocus();
      });
    }

    entities.addAll(navigationService.buildings);
    entities.addAll(navigationService.canteens);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: Sizes.paddingRegular),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Sizes.paddingRegular),
                child: GestureDetector(
                  onTap: (){
                    if(MediaQuery.of(context).viewInsets.bottom != 0){
                      FocusManager.instance.primaryFocus?.unfocus();
                      Future.delayed(animationDuration).then((_){
                        AppUtils.switchPage(context, MainPage());
                      });
                    }else{
                      AppUtils.switchPage(context, MainPage());
                    }
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: Sizes.paddingSmall),
                        child: const Icon(
                          RemixIcon.arrow_left_line,
                          color: black,
                        ),
                      ),
                      DMSansMediumText(
                        text: "Search on campus",
                        color: black,
                        size: Sizes.textSizePageTitle,
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: Sizes.paddingRegular, bottom: Sizes.paddingSmall, right: Sizes.paddingRegular, left: Sizes.paddingRegular),
                child: Column(
                  children: [
                    Hero(
                      tag: "SEARCH_BAR",
                      child: Container(
                        decoration: BoxDecoration(
                          color: lightGrey,
                          borderRadius: BorderRadius.circular(Sizes.borderRadius)
                        ),
                        padding: EdgeInsets.symmetric(horizontal: Sizes.paddingSmall),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: Sizes.paddingSmall),
                              child: isDestinationInput ? Icon(
                                RemixIcon.search_line,
                                size: Sizes.iconSize,
                                color: black,
                              ) : DMSansRegularText(
                                text: "FROM",
                                color: black,
                                size: Sizes.textSizeSmall * 0.6,
                              ),
                            ),
                            Expanded(
                              child: Material(
                                color: lightGrey,
                                child: TextField(
                                  controller: startController,
                                  onChanged: (String value){
                                    if(isDestinationInput){
                                      destinationSearchTerm = value;
                                      searchForEntities(destinationSearchTerm);
                                    }else{
                                      startSearchTerm = value;
                                      searchForEntities(startSearchTerm);
                                    }
                                  },
                                  onSubmitted: (String value){
                                    if(isDestinationInput){
                                      destinationSearchTerm = value;
                                      searchForEntities(destinationSearchTerm);
                                    }else{
                                      startSearchTerm = value;
                                      searchForEntities(startSearchTerm);
                                    }
                                  },
                                  onTap: (){
                                    if(!isDestinationInput){
                                      setState(() {});
                                    }
                                  },
                                  focusNode: focusNode,
                                  cursorColor: green,
                                  style: TextStyle(
                                    fontSize: Sizes.textSizeSmall,
                                    color: black,
                                    fontFamily: "DM Sans Medium"
                                  ),
                                  decoration: InputDecoration(
                                    fillColor: lightGrey,
                                    hintStyle: TextStyle(
                                      fontSize: Sizes.textSizeSmall,
                                      color: darkGrey,
                                      fontFamily: "DM Sans Medium"
                                    ),
                                    hintText: "Search for buildings, courses, ...",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    !isDestinationInput ? Container(
                      decoration: BoxDecoration(
                        color: lightGrey,
                        borderRadius: BorderRadius.circular(Sizes.borderRadius)
                      ),
                      margin: EdgeInsets.only(top: Sizes.paddingSmall),
                      padding: EdgeInsets.symmetric(horizontal: Sizes.paddingSmall),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: Sizes.paddingSmall),
                            child: isDestinationInput ? Icon(
                              RemixIcon.search_line,
                              size: Sizes.iconSize,
                              color: black,
                            ) : DMSansRegularText(
                              text: "TO",
                              color: black,
                              size: Sizes.textSizeSmall * 0.6,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: destinationController,
                              onChanged: (String value){

                              },
                              onSubmitted: (String value){

                              },
                              onTap: (){
                                setState(() {
                                  isDestinationInput = true;
                                  startController.text = destinationController.text;
                                });

                                Future.delayed(animationDuration).then((_){
                                  focusNode.requestFocus();
                                });

                                destinationSearchTerm = startController.text;
                                searchForEntities(destinationSearchTerm);
                              },
                              cursorColor: green,
                              style: TextStyle(
                                fontSize: Sizes.textSizeSmall,
                                color: black,
                                fontFamily: "DM Sans Medium"
                              ),
                              decoration: InputDecoration(
                                fillColor: lightGrey,
                                hintStyle: TextStyle(
                                  fontSize: Sizes.textSizeSmall,
                                  color: darkGrey,
                                  fontFamily: "DM Sans Medium"
                                ),
                                hintText: "Search for buildings, courses, ...",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ) : const SizedBox(),
                  ],
                ),
              ),
              Hero(
                tag: "TAG_BAR",
                child: TagBarWidget(
                  tagColor: lightGrey,
                  onChanged: (int index){
                    if(index == 0){
                      filter = null;
                    }else{
                      filter = CampusEntityType.values[index - 1];
                    }

                    searchForEntities(isDestinationInput ? destinationSearchTerm : startSearchTerm);
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: Sizes.paddingRegular, right: Sizes.paddingRegular, left: Sizes.paddingRegular),
                  child: RemoveGlowBehavior(
                    child: SingleChildScrollView(
                      child: Column(
                        children: AnimateList(
                          interval: const Duration(milliseconds: 50),
                          effects: [
                            const FadeEffect(duration: animationDuration, curve: animationCurve),
                            const ScaleEffect(duration: animationDuration, curve: animationCurve)
                          ],
                          children: List.generate((focusNode.hasFocus && !isDestinationInput || searchResults.isNotEmpty && !isDestinationInput) ? searchResults.length + 1 : searchResults.length, (int index){
                            return SearchCardWidget(
                              campusEntity: searchResults.isEmpty ? navigationService.buildings.first : searchResults[isDestinationInput ? index : max(0, index - 1)],
                              currentLocationCard: index == 0 && !isDestinationInput,
                              onNavigationClicked: (CampusEntity selectedEntity){
                                selectEntity(selectedEntity);
                              },
                              onUserLocationSelected: () async{
                                FocusManager.instance.primaryFocus?.unfocus();
                                userLocation = await navigationService.userLocationService.getLocation();
                                if(userLocation != null){
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  startEntity = null;
                                  startController.text = "My location";
                                  startSearchTerm = "";
                                  searchForEntities("");
                                  if(MediaQuery.of(context).viewInsets.bottom != 0){
                                    FocusManager.instance.primaryFocus?.unfocus();
                                    Future.delayed(animationDuration).then((_){
                                      AppUtils.switchPage(context, MainPage(navigationJob: createNavigationJob()));
                                    });
                                  }else{
                                    AppUtils.switchPage(context, MainPage(navigationJob: createNavigationJob()));
                                  }
                                }
                              },
                            );
                          }),
                        )
                      ),
                    )
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void searchForEntities(String searchTerm){
    searchResults.clear();
    if(searchTerm.isEmpty){
      setState(() {});
      return;
    }

    for(int i = 0; i < entities.length; i++){
      if(!isFilteredEntity(entities[i])){
        continue;
      }

      for(int j = 0; j < entities[i].getIdentifiers().length; j++){
        if(entities[i].getIdentifiers()[j].toLowerCase().contains(searchTerm.toLowerCase())){
          searchResults.add(entities[i]);
          break;
        }
      }
    }
    setState(() {});
  }

  bool isFilteredEntity(CampusEntity entity){
    if(filter == null){
      return true;
    }else if(filter == CampusEntityType.building && entity is Building){
      return true;
    }else if(filter == CampusEntityType.canteen && entity is Canteen){
      return true;
    }

    return false;
  }

  void selectEntity(CampusEntity selectedEntity){
    if(isDestinationInput){
      FocusManager.instance.primaryFocus?.unfocus();
      destinationEntity = selectedEntity;
      isDestinationInput = false;
      destinationController.text = selectedEntity.getTitle();
      startController.clear();
      startEntity = null;
      startSearchTerm = "";
      searchForEntities("");
    }else{
      FocusManager.instance.primaryFocus?.unfocus();
      startEntity = selectedEntity;
      startController.text = selectedEntity.getTitle();
      startSearchTerm = selectedEntity.getTitle();
      searchForEntities("");

      AppUtils.switchPage(context, MainPage(navigationJob: createNavigationJob()));
    }
    setState(() {});
  }

  NavigationJob createNavigationJob(){
    if(startEntity != null){
      NavigationNode startNode = navigationService.getClosestNodeToCoordinates(startEntity!.getPosition());
      NavigationNode destinationNode = navigationService.getClosestNodeToCoordinates(destinationEntity!.getPosition());
      return NavigationJob(startEntity: startEntity!, destinationEntity: destinationEntity!, startNode: startNode, destinationNode: destinationNode, isUserLocationBased: false);
    }else{
      NavigationNode startNode = navigationService.getClosestNodeToCoordinates(userLocation!);
      NavigationNode destinationNode = navigationService.getClosestNodeToCoordinates(destinationEntity!.getPosition());
      return NavigationJob(destinationEntity: destinationEntity!, startNode: startNode, destinationNode: destinationNode, isUserLocationBased: true);
    }
  }

}

/*
ListView.builder(
  itemCount: (focusNode.hasFocus && !isDestinationInput || searchResults.isNotEmpty && !isDestinationInput) ? searchResults.length + 1 : searchResults.length,
  itemBuilder: (BuildContext context, int index){
    return SearchCardWidget(
      campusEntity: searchResults.isEmpty ? navigationService.buildings.first : searchResults[isDestinationInput ? index : max(0, index - 1)],
      currentLocationCard: index == 0 && !isDestinationInput,
      onNavigationClicked: (CampusEntity selectedEntity){
        selectEntity(selectedEntity);
      },
      onUserLocationSelected: () async{
        FocusManager.instance.primaryFocus?.unfocus();
        userLocation = await navigationService.userLocationService.getLocation();
        if(userLocation != null){
          FocusManager.instance.primaryFocus?.unfocus();
          startEntity = null;
          startController.text = "My location";
          startSearchTerm = "";
          searchForEntities("");
          if(MediaQuery.of(context).viewInsets.bottom != 0){
            FocusManager.instance.primaryFocus?.unfocus();
            Future.delayed(animationDuration).then((_){
              AppUtils.switchPage(context, MainPage(navigationJob: createNavigationJob()));
            });
          }else{
            AppUtils.switchPage(context, MainPage(navigationJob: createNavigationJob()));
          }
        }
      },
    );
  },
),
 */
