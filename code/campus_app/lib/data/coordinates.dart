
class Coordinates{
  double latitude, longitude;

  Coordinates({required this.latitude, required this.longitude});

  @override
  String toString() {
    return "$latitude, $longitude";
  }
}