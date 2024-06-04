import 'package:guidely/models/utils/tour_category.dart';

class Activity {
  final String name;
  final String description;
  bool isSelected = false;

  Activity({
    required this.name,
    this.description = '',
  });

  Activity copyWith({String? name, String? description, bool? isSelected}) {
    return Activity(
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'isSelected': isSelected,
    };
  }

  static List<TourCategory> mapActivityToTourCategory(Activity activity) {
    switch (activity.name) {
      case 'Walking tour':
        return [TourCategory.history, TourCategory.architecture];
      case 'Museum tour':
        return [TourCategory.history, TourCategory.art];
      case "Children's tour":
        return [TourCategory.family];
      case "Cycling tour":
        return [TourCategory.adventure, TourCategory.sports];
      case 'Hiking':
        return [TourCategory.nature, TourCategory.adventure];
      case 'City sightseeing':
        return [
          TourCategory.history,
          TourCategory.architecture,
          TourCategory.culture
        ];
      case 'Nature walk':
        return [TourCategory.nature];
      default:
        return [];
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Activity &&
        other.name == name &&
        other.description == description &&
        other.isSelected == isSelected;
  }

  @override
  int get hashCode =>
      name.hashCode ^ description.hashCode ^ isSelected.hashCode;

  @override
  String toString() =>
      'Activity(name: $name, description: $description, isSelected: $isSelected)';
}
