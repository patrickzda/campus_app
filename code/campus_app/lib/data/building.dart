import 'package:campus_app/data/navigation_node.dart';

class Building{
  final int id;
  final String shortName;
  final List<String> names;
  List<NavigationNode> entryNodes;

  Building({required this.id, required this.shortName, required this.names, required this.entryNodes});
}