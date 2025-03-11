class SystemUsage {
  double cpuUsage;
  double gpuUsage;
  double totalStorage;
  double availableStorage;
  double usedStorage;
  double totalRam;
  double usedRam;

  SystemUsage({
    required this.cpuUsage,
    required this.gpuUsage,
    required this.totalStorage,
    required this.availableStorage,
    required this.usedStorage,
    required this.totalRam,
    required this.usedRam,
  });

  factory SystemUsage.fromJson(Map<String, dynamic> json) {
    return SystemUsage(
      cpuUsage: (json['cpuUsage'] ?? 0).toDouble(),
      gpuUsage: (json['gpuUsage'] ?? 0).toDouble(),
      totalStorage: (json['totalStorage'] ?? 0).toDouble(),
      availableStorage: (json['availableStorage'] ?? 0).toDouble(),
      usedStorage: (json['usedStorage'] ?? 0).toDouble(),
      totalRam: (json['totalRam'] ?? 0).toDouble(),
      usedRam: (json['usedRam'] ?? 0).toDouble(),
    );
  }
}
