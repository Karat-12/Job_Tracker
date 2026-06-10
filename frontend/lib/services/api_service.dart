import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/application.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api/applications';

  static Future<List<Application>> getApplications() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((appJson) => Application.fromJson(appJson)).toList();
    }

    throw Exception('Failed to load applications');
  }

  static Future<Application> createApplication(Application application) async {
    final payload = Map<String, dynamic>.from(application.toJson())
      ..remove('id');
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Application.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to create application');
  }

  static Future<Application> updateApplication(Application application) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${application.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(application.toJson()),
    );

    if (response.statusCode == 200) {
      return Application.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to update application');
  }

  static Future<void> deleteApplication(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete application');
    }
  }
}
