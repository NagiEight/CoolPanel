import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cool_panel_app/models/SystemUsageModel.dart';
import '../services/SystemUsageServices.dart';

class SystemUsagePage extends StatefulWidget {
  const SystemUsagePage({Key? key}) : super(key: key);

  @override
  _SystemUsagePageState createState() => _SystemUsagePageState();
}

class _SystemUsagePageState extends State<SystemUsagePage> {
  final SystemUsageService _service = SystemUsageService();
  SystemUsage? systemUsage;
  Timer? _timer;
  bool isGridView = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _service.loadApiEndpoint();
    if (_service.apiEndpoint != null) {
      _startAutoUpdate();
    }
  }

  void _startAutoUpdate() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchData();
    });
    _fetchData(); // Initial fetch
  }

  Future<void> _fetchData() async {
    try {
      final usage = await _service.fetchSystemUsage();
      setState(() {
        systemUsage = usage;
      });
    } catch (e) {
      debugPrint(e.toString());
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
      body: _service.apiEndpoint == null
          ? _buildNoApiConfiguredView()
          : systemUsage == null
              ? const Center(child: CircularProgressIndicator())
              : _buildMainContent(),
    );
  }

  Widget _buildNoApiConfiguredView() {
    return Center(
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
    );
  }

  Widget _buildMainContent() {
    return Padding(
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
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
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
    );
  }

  Widget _buildViewSwitcherButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              isGridView = !isGridView;
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
              Icon(icon, color: color, size: 15),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
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