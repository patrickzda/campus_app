
class Coordinates{
  final double latitude, longitude;

  const Coordinates({required this.latitude, required this.longitude});

  @override
  String toString() {
    return "$latitude, $longitude";
  }
}