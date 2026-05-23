import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use ngrok public URL for stable connectivity across networks
  // URL de ton binôme (à décommenter avant de push si besoin) :
  // static const String baseUrl = 'https://randee-nonlicentious-seducingly.ngrok-free.dev/api';
  
  // Ton URL locale pour l'émulateur Android :
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  static Future<http.Response> post(
      String endpoint, Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    return http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 10));
  }

  static Future<http.Response> patch(
      String endpoint, Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    return http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 10));
  }

  static Future<http.Response> get(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    return http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));
  }

  static Future<http.Response> postMultipart(
      String endpoint,
      Map<String, String> fields,
      String? filePath,
      String fileFieldName) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    print("Mon Token actuel : $token");
    final request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
    request.headers['ngrok-skip-browser-warning'] = 'true';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);

    if (filePath != null) {
      request.files
          .add(await http.MultipartFile.fromPath(fileFieldName, filePath));
    }

    final streamlinedResponse = await request.send().timeout(const Duration(seconds: 15));
    return http.Response.fromStream(streamlinedResponse);
  }
}
