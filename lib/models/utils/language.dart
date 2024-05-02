class Language {
  const Language({required this.name, required this.code});

  final String name;
  final String code;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
    };
  }
}
