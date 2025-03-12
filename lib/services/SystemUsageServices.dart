import 'dart:convert';
import 'dart:async';
import 'package:cool_panel_app/models/SystemUsageModel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SystemUsageService {
  String? apiEndpoint;

  Future<void> loadApiEndpoint() async {
    final prefs = await SharedPreferences.getInstance();
    apiEndpoint = prefs.getString('apiEndpoint');
  }

  Future<SystemUsage?> fetchSystemUsage() async {
    if (apiEndpoint == null) return null;

    try {
      final response = await http.get(Uri.parse(apiEndpoint!));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return SystemUsage.fromJson(jsonData);
      } else {
        throw Exception('Failed to fetch system usage data');
      }
    } catch (e) {
      throw Exception("Error fetching data: $e");
    }
  }
}
