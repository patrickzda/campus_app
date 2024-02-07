import 'package:campus_app/data/campus_entity.dart';
import 'package:campus_app/data/navigation_node.dart';

class NavigationJob{
  final NavigationNode startNode, destinationNode;
  final CampusEntity? startEntity;
  final CampusEntity destinationEntity;
  final bool isUserLocationBased;

  NavigationJob({this.startEntity, required this.destinationEntity, required this.startNode, required this.destinationNode, required this.isUserLocationBased});
}