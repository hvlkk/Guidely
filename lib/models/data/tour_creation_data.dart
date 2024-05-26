import 'package:flutter/material.dart';
import 'package:guidely/models/data/activity.dart';
import 'package:guidely/models/data/waypoint.dart';
import 'package:guidely/models/utils/language.dart';

class TourCreationData {
  final String title;
  final String description;
  final TimeOfDay startTime;
  final DateTime startDate;
  final TimeOfDay duration;
  final List<Waypoint>? waypoints;
  final String messageToParticipants;
  final List<Activity> activities;
  final List<Language> languages;

  TourCreationData({
    this.title = '',
    this.description = '',
    this.startTime = const TimeOfDay(hour: 0, minute: 0),
    required this.startDate,
    this.duration = const TimeOfDay(hour: 2, minute: 0),
    this.waypoints,
    this.messageToParticipants = '',
    this.activities = const [],
    this.languages = const [],
  });

  get startingLocation => waypoints?.first;

  TourCreationData copyWith({
    String? title,
    String? description,
    TimeOfDay? startTime,
    DateTime? startDate,
    TimeOfDay? duration,
    List<Waypoint>? waypoints,
    String? messageToParticipants,
    List<Activity>? activities,
    List<Language>? languages,
  }) {
    return TourCreationData(
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      waypoints: waypoints ?? this.waypoints,
      messageToParticipants:
          messageToParticipants ?? this.messageToParticipants,
      activities: activities ?? this.activities,
      languages: languages ?? this.languages,
    );
  }

  factory TourCreationData.fromMap(Map<String, dynamic> map) {
    return TourCreationData(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startTime: TimeOfDay(
        hour: int.parse(map['startTime'].split(':')[0]),
        minute: int.parse(map['startTime'].split(':')[1]),
      ),
      duration: TimeOfDay(
        hour: int.parse(map['duration'].split(':')[0]),
        minute: int.parse(map['duration'].split(':')[1]),
      ),
      startDate: DateTime.parse(map['startDate'] ?? ''),
      waypoints: (map['waypoints'] as List<dynamic>?)
          ?.map((waypoint) => Waypoint.fromMap(waypoint))
          .toList(),
      messageToParticipants: map['messageToParticipants'] ?? '',
      activities: (map['activities'] as List<dynamic>?)
              ?.map((activity) => Activity(name: activity))
              .toList() ??
          [],
      languages: (map['languages'] as List<dynamic>?)
              ?.map(
                (language) => Language(
                  name: language['name'],
                  code: language['code'],
                ), // this will need to be updated
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startTime': '${startTime.hour}:${startTime.minute}',
      'duration': '${duration.hour}:${duration.minute}',
      'startDate': startDate.toString(),
      'waypoints': waypoints?.map((waypoint) => waypoint.toMap()).toList(),
      'messageToParticipants': messageToParticipants,
      'activities': activities.map((activity) => activity.name).toList(),
      'languages': languages.map((language) => language.toMap()).toList(),
    };
  }

  @override
  String toString() {
    return 'TourCreationData{title: $title, description: $description, startTime: $startTime, startDate: $startDate, waypoints: $waypoints, messageToParticipants: $messageToParticipants, activities: $activities, languages: $languages}';
  }
}
