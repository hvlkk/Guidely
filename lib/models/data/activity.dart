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
