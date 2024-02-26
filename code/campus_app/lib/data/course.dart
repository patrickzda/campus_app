import 'package:campus_app/constants/Constants.dart';
import 'package:campus_app/data/campus_entity.dart';
import 'package:campus_app/data/coordinates.dart';
import 'package:campus_app/data/room.dart';
import 'building.dart';
import 'course_event.dart';

class Course extends CampusEntity{
  final String name, fullName, type, supervisor, faculty, institute, department, email, learningOutcomes, description, examType, language, grading, mosesLink, isisLink;
  final List<String> relatedStudies;
  final int id, ects;
  final List<CourseEvent> events;

  Course({
    required this.id,
    required this.name,
    required this.fullName,
    required this.type,
    required this.supervisor,
    required this.faculty,
    required this.institute,
    required this.department,
    required this.email,
    required this.learningOutcomes,
    required this.description,
    required this.examType,
    required this.language,
    required this.grading,
    required this.mosesLink,
    required this.isisLink,
    required this.relatedStudies,
    required this.ects,
    required this.events
  });

  static Course fromJson(Map<String, dynamic> jsonData, int id){
    return Course(
      id: id,
      name: jsonData["name"],
      fullName: jsonData["full_name"],
      type: jsonData["type"],
      supervisor: jsonData["supervisor"],
      faculty: jsonData["faculty"],
      institute: jsonData["institute"],
      department: jsonData["department"],
      email: jsonData["email"],
      learningOutcomes: jsonData["learning_outcomes"],
      description: jsonData["description"],
      examType: jsonData["exam_type"],
      language: jsonData["language"],
      grading: jsonData["grading"],
      mosesLink: jsonData["moses_link"],
      isisLink: jsonData["isis_link"],
      relatedStudies: List.generate(jsonData["studies"].length, (int index){
        return jsonData["studies"][index].toString();
      }),
      ects: jsonData["ects"],
      events: List.generate(jsonData["events"].length, (int index){
        return CourseEvent.fromJson(jsonData["events"][index]);
      })
    );
  }

  bool isCurrent(){
    for(int i = 0; i < events.length; i++){
      if(events[i].isCurrent()){
        return true;
      }
    }
    return false;
  }

  @override
  String getDescription() {
    return description;
  }

  @override
  List<String> getIdentifiers() {
    return [fullName, type, faculty, institute, department];
  }

  @override
  Coordinates getPosition() {
    DateTime current = DateTime.now();
    int currentEventIndex = -1;
    for(int i = 0; i < events.length; i++){
      if(events[i].start.isBefore(current) && events[i].end.isAfter(current)){
        currentEventIndex = i;
        break;
      }
    }

    if(currentEventIndex != -1){
      for(int i = 0; i < navigationService.rooms.length; i++){
        if(events[currentEventIndex].roomNames.join(" ").contains(navigationService.rooms[i].name)){
          return navigationService.rooms[i].getPosition();
        }
      }
    }
    return const Coordinates(latitude: 0, longitude: 0);
  }

  @override
  String getShortName() {
    DateTime current = DateTime.now();
    int currentEventIndex = -1;
    for(int i = 0; i < events.length; i++){
      if(events[i].start.isBefore(current) && events[i].end.isAfter(current)){
        currentEventIndex = i;
        break;
      }
    }

    if(currentEventIndex != -1){
      return events[currentEventIndex].roomNames[0];
    }
    return "Course";
  }

  @override
  String getTitle() {
    return name;
  }

  CourseEvent? getCurrentEvent(){
    for(int i = 0; i < events.length; i++){
      if(events[i].isCurrent()){
        return events[i];
      }
    }
    return null;
  }

}