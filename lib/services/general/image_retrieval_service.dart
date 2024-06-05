import 'dart:convert';

import 'package:http/http.dart' as http;

class ImageRetrievalService {
  static const String _baseUrl = 'https://api.pexels.com/v1/search';

  Future<List<String>> fetchCityImagesList(String cityName) async {
    final apiKey = 'dNOVFmKOmM7qXacTM2hlf3XJNBxfYFyrRptI0OrjpbDYsBAGXeBWlnfo';
    final response = await http.get(
      Uri.parse('$_baseUrl').replace(queryParameters: {
        'query': cityName,
        'per_page': '2',
        'orientation': 'landscape',
      }),
      headers: <String, String>{
        'Authorization': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final photos = body['photos'];
      final imageUrls = photos.map<String>((photo) {
        return photo['src']['large'] as String;
      }).toList();
      return imageUrls;
    } else {
      throw Exception('Failed to load images');
    }
  }
}
