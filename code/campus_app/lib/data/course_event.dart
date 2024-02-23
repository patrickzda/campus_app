
class CourseEvent{
  final List<String> rooms;
  final DateTime start, end;

  CourseEvent({required this.rooms, required this.start, required this.end});

  static CourseEvent fromJson(Map<String, dynamic> jsonData){
    return CourseEvent(
      rooms: List.generate(jsonData["rooms"].length, (int index){
        return jsonData["rooms"][index].toString();
      }),
      start: DateTime.parse(jsonData["iso_start"]),
      end: DateTime.parse(jsonData["iso_end"])
    );
  }
}