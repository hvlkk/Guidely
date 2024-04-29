class RegistrationData {
  RegistrationData(
      {required this.uid,
      required this.description,
      required this.uploadedIdURL});

  String uid;
  String description;
  String uploadedIdURL;

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'description': description,
      'uploadedIdURL': uploadedIdURL,
    };
  }
}
