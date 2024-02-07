import 'package:flutter/material.dart';
import 'package:remix_flutter/remix_flutter.dart';

import '../services/navigation_service.dart';

const Color black = Color.fromARGB(255, 15, 15, 15);
const Color darkGrey = Color.fromARGB(255, 187, 187, 187);
const Color lightGrey = Color.fromARGB(255, 241, 241, 241);
const Color white = Color.fromARGB(255, 250, 250, 250);
const Color green = Color.fromARGB(255, 71, 192, 131);
const Color blue = Color.fromARGB(255, 188, 196, 255);
const Color yellow = Color.fromARGB(255, 250, 242, 104);
const Color pink = Color.fromARGB(255, 255, 187, 245);
const Color beige = Color.fromARGB(255, 232, 212, 199);

const List<String> tagNames = ["All", "Buildings", "Canteens", "Courses", "Events"];
const List<Color> tagColors = [green, blue, yellow, pink, beige];
const List<IconData> tagIcons = [RemixIcon.function_line, RemixIcon.community_line, RemixIcon.restaurant_line, RemixIcon.presentation_line, RemixIcon.calendar_event_line];

const Duration animationDuration = Duration(milliseconds: 250);
const Curve animationCurve = Curves.ease;

const double geofenceRadiusInMeters = 5;
const double averageWalkingSpeedInMetersPerSecond = 1.42;

const String mapLoadedIdentifier = "MAP_LOADED";

final NavigationService navigationService = NavigationService();