import 'package:appwrite/models.dart';
import 'package:campus_app/constants/constants.dart';
import 'package:campus_app/constants/network_constants.dart';
import 'package:campus_app/data/campus_entity.dart';
import 'package:campus_app/data/coordinates.dart';

const String eventCollectionId = "65df5f08c0e3d533f7ba";

class Event extends CampusEntity{
  String title, url, month, day, location, time, language;

  Event({required this.title, required this.url, required this.month, required this.day, required this.location, required this.time, required this.language});

  static Event fromJson(Map<String, dynamic> jsonData){
    return Event(
      title: jsonData["title"],
      url: jsonData["url"],
      month: jsonData["month"],
      day: jsonData["day"],
      location: jsonData["location"],
      time: jsonData["time"],
      language: jsonData["language"]
    );
  }

  static Future<List<Event>> loadEvents() async{
    DocumentList result = await NetworkConstants.database.listDocuments(databaseId: databaseId, collectionId: eventCollectionId);

    return List.generate(result.documents.length, (int index){
      return Event.fromJson(result.documents[index].data);
    });
  }

  @override
  String getDescription() {
    return "$day. $month, $location";
  }

  @override
  List<String> getIdentifiers() {
    return [title, location];
  }

  @override
  Coordinates getPosition() {
    return const Coordinates(latitude: 0, longitude: 0);
  }

  @override
  String getShortName() {
    return "Event";
  }

  @override
  String getTitle() {
    return title;
  }

}