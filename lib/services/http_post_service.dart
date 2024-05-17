import 'dart:convert';

import 'package:http/http.dart' as http;

class HttpPostService {
  final String _baseUrl = 'http://localhost:5000'; 

  Future<void> postUserData(String endpoint, Map<String, dynamic> requestBody) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl + endpoint),
        body: json.encode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('User data posted successfully');
      } else {
        print('Failed to post user data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('An error occurred while posting user data: $error');
    }
  }
}
