
class CourseEvent{
  final List<String> roomNames;
  final List<int> roomIds;
  final DateTime start, end;

  CourseEvent({required this.roomNames, required this.roomIds, required this.start, required this.end});

  static CourseEvent fromJson(Map<String, dynamic> jsonData){
    return CourseEvent(
      roomNames: List.generate(jsonData["rooms"].length, (int index){
        return jsonData["rooms"][index].toString();
      }),
      roomIds: List.generate(jsonData["room_ids"].length, (int index){
        return int.parse(jsonData["room_ids"][index]);
      }),
      start: DateTime.parse(jsonData["iso_start"]),
      end: DateTime.parse(jsonData["iso_end"])
    );
  }

  bool isCurrent(){
    DateTime current = DateTime.now();
    return start.isBefore(current) && end.isAfter(current);
  }
}