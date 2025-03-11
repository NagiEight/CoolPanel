import 'dart:convert';
import 'package:cool_panel_app/models/SystemUsageModel.dart';
import 'package:http/http.dart' as http;

class ApiHelper {
  final String baseUrl;

  ApiHelper({required this.baseUrl});

  // Fetch system usage data
  Future<SystemUsage> fetchSystemUsage() async {
    final response = await http.get(Uri.parse('$baseUrl/home'));

    if (response.statusCode == 200) {
      // Parse the JSON response and convert it into a SystemUsage object
      final data = json.decode(response.body);
      return SystemUsage.fromJson(data);
    } else {
      throw Exception('Failed to load system usage data');
    }
  }
}
