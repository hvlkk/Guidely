import 'package:flutter/material.dart';
import 'package:guidely/models/data/waypoint.dart';
import 'package:guidely/models/data/activity.dart';
import 'package:guidely/models/utils/language.dart';

class TourCreationData {
  final String title;
  final String description;
  final TimeOfDay startTime;
  final DateTime startDate;
  final List<Waypoint>? waypoints;
  final String messageToParticipants;
  final List<Activity> activities;
  final List<Language> languages;

  TourCreationData({
    this.title = '',
    this.description = '',
    this.startTime = const TimeOfDay(hour: 0, minute: 0),
    required this.startDate,
    this.waypoints,
    this.messageToParticipants = '',
    this.activities = const [],
    this.languages = const [],
  });

  @override
  String toString() {
    return 'TourCreationData{title: $title, description: $description, startTime: $startTime, startDate: $startDate, waypoints: $waypoints, messageToParticipants: $messageToParticipants, activities: $activities, languages: $languages}';
  }

  TourCreationData copyWith({
    String? title,
    String? description,
    TimeOfDay? startTime,
    DateTime? startDate,
    List<Waypoint>? waypoints,
    String? messageToParticipants,
    List<Activity>? activities,
    List<Language>? languages,
  }) {
    return TourCreationData(
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      startDate: startDate ?? this.startDate,
      waypoints: waypoints ?? this.waypoints,
      messageToParticipants:
          messageToParticipants ?? this.messageToParticipants,
      activities: activities ?? this.activities,
      languages: languages ?? this.languages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startTime': '${startTime.hour}:${startTime.minute}',
      'startDate': startDate.toString(),
      'waypoints': waypoints?.map((waypoint) => waypoint.toMap()).toList(),
      'messageToParticipants': messageToParticipants,
      'activities': activities.map((activity) => activity.name).toList(),
      'languages': languages.map((language) => language.name).toList(),
    };
  }
}
