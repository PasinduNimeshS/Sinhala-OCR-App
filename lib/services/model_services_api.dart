// lib/services/model_services_api.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ModelServicesApi {
  static const String _baseUrl = 'http://127.0.0.1:8000';

  static Future<Map<String, dynamic>> predictImage(File imageFile) async {
    final uri = Uri.parse('$_baseUrl/api/v1/predict');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to predict: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}