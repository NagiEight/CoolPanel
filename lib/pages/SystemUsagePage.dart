import 'dart:async';
import 'dart:convert';
import 'package:cool_panel_app/models/SystemUsageModel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SystemUsagePage extends StatefulWidget {
  const SystemUsagePage({Key? key}) : super(key: key);

  @override
  _SystemUsagePageState createState() => _SystemUsagePageState();
}

class _SystemUsagePageState extends State<SystemUsagePage> {
  SystemUsage? systemUsage;
  Timer? _timer;
  String? apiEndpoint;
  bool isGridView = true; // Tracks current view mode (Grid or List)

  @override
  void initState() {
    super.initState();
    _checkApiEndpoint();
  }

  Future<void> _checkApiEndpoint() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEndpoint = prefs.getString('apiEndpoint');
    setState(() {
      apiEndpoint = savedEndpoint;
    });
    if (apiEndpoint != null) {
      _startAutoUpdate();
    }
  }

  void _startAutoUpdate() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchSystemUsage();
    });

    fetchSystemUsage(); // Initial fetch
  }

  Future<void> fetchSystemUsage() async {
    if (apiEndpoint == null) return;

    try {
      final response = await http.get(Uri.parse(apiEndpoint!));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          systemUsage = SystemUsage.fromJson(jsonData);
        });
      } else {
        debugPrint('Failed to load system usage data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: apiEndpoint == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'API endpoint not configured.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                    child: const Text('Go to Settings'),
                  ),
                ],
              ),
            )
          : systemUsage == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildViewSwitcherButton(),
                      const SizedBox(height: 16),
                      Expanded(
                        child: isGridView
                            ? GridView(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.5,
                                ),
                                children: _buildUsageTiles(),
                              )
                            : ListView(
                                children: _buildUsageTiles(),
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildViewSwitcherButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              isGridView = !isGridView; // Toggles between Grid and List View
            });
          },
          child: Text(isGridView ? 'Switch to List View' : 'Switch to Grid View'),
        ),
      ],
    );
  }

  List<Widget> _buildUsageTiles() {
    return [
      _buildStatCard("CPU Usage", "${systemUsage!.cpuUsage.toStringAsFixed(2)}%", Icons.memory, Colors.red),
      _buildStatCard("GPU Usage", "${systemUsage!.gpuUsage.toStringAsFixed(2)}%", Icons.speed, Colors.green),
      _buildStatCard("Total Storage", "${systemUsage!.totalStorage.toStringAsFixed(2)} GB", Icons.sd_storage, Colors.blue),
      _buildStatCard("Available Storage", "${systemUsage!.availableStorage.toStringAsFixed(2)} GB", Icons.storage, Colors.teal),
      _buildStatCard("Used Storage", "${systemUsage!.usedStorage.toStringAsFixed(2)} GB", Icons.storage, Colors.orange),
      _buildStatCard("Total RAM", "${systemUsage!.totalRam.toStringAsFixed(2)} GB", Icons.memory, Colors.purple),
      _buildStatCard("Used RAM", "${systemUsage!.usedRam.toStringAsFixed(2)} GB", Icons.memory, Colors.pink),
    ];
  }

Widget _buildStatCard(String title, String value, IconData icon, Color color) {
  final textColor = Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : Colors.black87;

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    ),
  );
}

}
