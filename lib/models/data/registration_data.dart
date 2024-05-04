class RegistrationData {
  RegistrationData({
    required this.uid,
    required this.description,
    required this.uploadedIdURL,
  });

  String uid;
  String description;
  String uploadedIdURL;

  factory RegistrationData.fromMap(Map<String, dynamic> map) {
    return RegistrationData(
      uid: map['uid'] ?? '',
      description: map['description'] ?? '',
      uploadedIdURL: map['uploadedIdURL'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'description': description,
      'uploadedIdURL': uploadedIdURL,
    };
  }
}
