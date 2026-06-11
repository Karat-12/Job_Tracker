import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/application.dart';
import '../models/application_event.dart';
import '../models/resume.dart';

class ApiService {
  static const String _baseUrl =
    'https://job-tracker-api-vavk.onrender.com';
  static const String _appsUrl = '$_baseUrl/api/applications';
  static const String _resumesUrl = '$_baseUrl/api/resumes';
  static const Duration _timeout = Duration(seconds: 15);

  // ===========================================================================
  // Applications
  // ===========================================================================

  static Future<List<Application>> getApplications() async {
    try {
      final response = await http.get(Uri.parse(_appsUrl)).timeout(_timeout);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((j) => Application.fromJson(j)).toList();
      }
      debugPrint('GET applications error: ${response.statusCode} ${response.body}');
      throw Exception('Failed to load applications');
    } on SocketException catch (e) {
      debugPrint('SocketException getApplications: $e');
      throw Exception('Unable to connect to server');
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException getApplications: $e');
      throw Exception('Unable to connect to server');
    } catch (e) {
      debugPrint('Unknown error getApplications: $e');
      throw Exception('Failed to load applications');
    }
  }

  static Future<Application> createApplication(Application application) async {
    try {
      final payload = Map<String, dynamic>.from(application.toJson())
        ..remove('id')
        ..remove('timeline'); // server seeds the first event
      final response = await http
          .post(
            Uri.parse(_appsUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(_timeout);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Application.fromJson(jsonDecode(response.body));
      }
      debugPrint('POST application error: ${response.statusCode} ${response.body}');
      throw Exception('Failed to create application');
    } on SocketException catch (e) {
      debugPrint('SocketException createApplication: $e');
      throw Exception('Unable to connect to server');
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException createApplication: $e');
      throw Exception('Unable to connect to server');
    } catch (e) {
      debugPrint('Unknown error createApplication: $e');
      throw Exception('Failed to create application');
    }
  }

  static Future<Application> updateApplication(Application application) async {
    try {
      final payload = Map<String, dynamic>.from(application.toJson())
        ..remove('timeline'); // server manages timeline
      final response = await http
          .put(
            Uri.parse('$_appsUrl/${application.id}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(_timeout);
      if (response.statusCode == 200) {
        return Application.fromJson(jsonDecode(response.body));
      }
      debugPrint('PUT application error: ${response.statusCode} ${response.body}');
      throw Exception('Failed to update application');
    } on SocketException catch (e) {
      debugPrint('SocketException updateApplication: $e');
      throw Exception('Unable to connect to server');
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException updateApplication: $e');
      throw Exception('Unable to connect to server');
    } catch (e) {
      debugPrint('Unknown error updateApplication: $e');
      throw Exception('Failed to update application');
    }
  }

  static Future<void> deleteApplication(String id) async {
    try {
      final response =
          await http.delete(Uri.parse('$_appsUrl/$id')).timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 204) return;
      debugPrint('DELETE application error: ${response.statusCode} ${response.body}');
      throw Exception('Failed to delete application');
    } on SocketException catch (e) {
      debugPrint('SocketException deleteApplication: $e');
      throw Exception('Unable to connect to server');
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException deleteApplication: $e');
      throw Exception('Unable to connect to server');
    } catch (e) {
      debugPrint('Unknown error deleteApplication: $e');
      throw Exception('Failed to delete application');
    }
  }

  // ===========================================================================
  // Resumes — metadata CRUD
  // ===========================================================================

  static Future<List<Resume>> getResumes() async {
    try {
      final response =
          await http.get(Uri.parse(_resumesUrl)).timeout(_timeout);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((j) => Resume.fromJson(j)).toList();
      }
      debugPrint('GET resumes error: ${response.statusCode} ${response.body}');
      throw Exception('Failed to load resumes');
    } on SocketException catch (e) {
      debugPrint('SocketException getResumes: $e');
      throw Exception('Unable to connect to server');
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException getResumes: $e');
      throw Exception('Unable to connect to server');
    } catch (e) {
      debugPrint('Unknown error getResumes: $e');
      throw Exception('Failed to load resumes');
    }
  }

  /// Upload a resume PDF file with a name and optional notes.
  /// [filePath] is the absolute path to the local PDF file.
  static Future<Resume> uploadResume({
    required String name,
    required String filePath,
    String? notes,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_resumesUrl/upload'),
      );
      request.fields['name'] = name;
      if (notes != null && notes.isNotEmpty) {
        request.fields['notes'] = notes;
      }
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamed = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Resume.fromJson(jsonDecode(response.body));
      }
      debugPrint('POST resume error: ${response.statusCode} ${response.body}');
      throw Exception('Failed to upload resume');
    } on SocketException catch (e) {
      debugPrint('SocketException uploadResume: $e');
      throw Exception('Unable to connect to server');
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException uploadResume: $e');
      throw Exception('Unable to connect to server');
    } catch (e) {
      debugPrint('Unknown error uploadResume: $e');
      throw Exception('Failed to upload resume');
    }
  }

  static Future<Resume> updateResume(
    String id, {
    required String name,
    String? notes,
  }) async {
    try {
      final uri = Uri.parse('$_resumesUrl/$id')
          .replace(queryParameters: {
            'name': name,
            if (notes != null && notes.isNotEmpty) 'notes': notes,
          });
      final response = await http.put(uri).timeout(_timeout);
      if (response.statusCode == 200) {
        return Resume.fromJson(jsonDecode(response.body));
      }
      debugPrint('PUT resume error: ${response.statusCode} ${response.body}');
      throw Exception('Failed to update resume');
    } on SocketException catch (e) {
      debugPrint('SocketException updateResume: $e');
      throw Exception('Unable to connect to server');
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException updateResume: $e');
      throw Exception('Unable to connect to server');
    } catch (e) {
      debugPrint('Unknown error updateResume: $e');
      throw Exception('Failed to update resume');
    }
  }

  static Future<void> deleteResume(String id) async {
    try {
      final response =
          await http.delete(Uri.parse('$_resumesUrl/$id')).timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 204) return;
      debugPrint('DELETE resume error: ${response.statusCode} ${response.body}');
      throw Exception('Failed to delete resume');
    } on SocketException catch (e) {
      debugPrint('SocketException deleteResume: $e');
      throw Exception('Unable to connect to server');
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException deleteResume: $e');
      throw Exception('Unable to connect to server');
    } catch (e) {
      debugPrint('Unknown error deleteResume: $e');
      throw Exception('Failed to delete resume');
    }
  }

  /// Returns the full URL to stream the resume PDF from the backend.
  static String getResumeFileUrl(String resumeId) =>
      '$_resumesUrl/$resumeId/file';

  // ===========================================================================
  // Application Events
  // ===========================================================================

  static Future<List<ApplicationEvent>> getEvents(
      String applicationId) async {
    try {
      final response = await http
          .get(Uri.parse('$_appsUrl/$applicationId/events'))
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((j) => ApplicationEvent.fromJson(j)).toList();
      }
      debugPrint(
          'GET events error: ${response.statusCode} ${response.body}');
      throw Exception('Failed to load events');
    } on SocketException catch (e) {
      debugPrint('SocketException getEvents: $e');
      throw Exception('Unable to connect to server');
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException getEvents: $e');
      throw Exception('Unable to connect to server');
    } catch (e) {
      debugPrint('Unknown error getEvents: $e');
      throw Exception('Failed to load events');
    }
  }

  /// [event] must have [eventType] and [eventDate] set.
  /// [applicationId] is the parent application's ID.
  static Future<ApplicationEvent> createEvent(
      String applicationId, ApplicationEvent event) async {
    try {
      final payload = {
        'eventType': event.eventType,
        'eventDate': event.eventDate,
        if (event.notes != null && event.notes!.isNotEmpty)
          'notes': event.notes,
      };
      final response = await http
          .post(
            Uri.parse('$_appsUrl/$applicationId/events'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApplicationEvent.fromJson(jsonDecode(response.body));
      }
      debugPrint(
          'POST event error: ${response.statusCode} ${response.body}');
      throw Exception('Failed to create event');
    } on SocketException catch (e) {
      debugPrint('SocketException createEvent: $e');
      throw Exception('Unable to connect to server');
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException createEvent: $e');
      throw Exception('Unable to connect to server');
    } catch (e) {
      debugPrint('Unknown error createEvent: $e');
      throw Exception('Failed to create event');
    }
  }

  static Future<ApplicationEvent> updateEvent(
      String eventId, ApplicationEvent event) async {
    try {
      final payload = {
        'eventType': event.eventType,
        'eventDate': event.eventDate,
        if (event.notes != null && event.notes!.isNotEmpty)
          'notes': event.notes,
      };
      final response = await http
          .put(
            Uri.parse('$_baseUrl/api/events/$eventId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(_timeout);
      if (response.statusCode == 200) {
        return ApplicationEvent.fromJson(jsonDecode(response.body));
      }
      debugPrint(
          'PUT event error: ${response.statusCode} ${response.body}');
      throw Exception('Failed to update event');
    } on SocketException catch (e) {
      debugPrint('SocketException updateEvent: $e');
      throw Exception('Unable to connect to server');
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException updateEvent: $e');
      throw Exception('Unable to connect to server');
    } catch (e) {
      debugPrint('Unknown error updateEvent: $e');
      throw Exception('Failed to update event');
    }
  }

  static Future<void> deleteEvent(String eventId) async {
    try {
      final response = await http
          .delete(Uri.parse('$_baseUrl/api/events/$eventId'))
          .timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 204) return;
      debugPrint(
          'DELETE event error: ${response.statusCode} ${response.body}');
      throw Exception('Failed to delete event');
    } on SocketException catch (e) {
      debugPrint('SocketException deleteEvent: $e');
      throw Exception('Unable to connect to server');
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException deleteEvent: $e');
      throw Exception('Unable to connect to server');
    } catch (e) {
      debugPrint('Unknown error deleteEvent: $e');
      throw Exception('Failed to delete event');
    }
  }
}
