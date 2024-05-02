class Activity {
  final String name;
  final String description;
  bool isSelected = false;

  Activity({
    required this.name,
    this.description = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'isSelected': isSelected,
    };
  }
}
