using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Management;
using System.Threading.Tasks;
using CoolPanelApi.Models;

namespace CoolPanelApi.Helpers
{
    public static class SystemUsageHelper
    {
        private static readonly PerformanceCounter _cpuCounter;

        private static float _cachedGpuUsage = 0;
        private static DateTime _lastGpuQueryTime = DateTime.MinValue;

        private static (double TotalStorage, double AvailableStorage) _cachedStorageInfo = (0, 0);
        private static DateTime _lastStorageQueryTime = DateTime.MinValue;

        private const int CacheDurationSeconds = 5; // Cache for 5 seconds

        static SystemUsageHelper()
        {
            // Initialize CPU counter once to avoid recreation overhead
            _cpuCounter = new PerformanceCounter("Processor", "% Processor Time", "_Total");
            _cpuCounter.NextValue(); // Dummy read to initialize
        }

        // Get CPU Usage
        public static async Task<float> GetCpuUsageAsync()
        {
            try
            {
                await Task.Delay(500); // Reduced delay for responsiveness
                return _cpuCounter.NextValue();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching CPU usage: {ex.Message}");
                return 0;
            }
        }

        // Get GPU Usage (NVIDIA-specific with caching)
        public static async Task<float> GetGpuUsageAsync()
        {
            try
            {
                // Return cached value if still valid
                if ((DateTime.Now - _lastGpuQueryTime).TotalSeconds < CacheDurationSeconds)
                    return _cachedGpuUsage;

                var processInfo = new ProcessStartInfo
                {
                    FileName = "nvidia-smi",
                    Arguments = "--query-gpu=utilization.gpu --format=csv,noheader,nounits",
                    RedirectStandardOutput = true,
                    UseShellExecute = false,
                    CreateNoWindow = true
                };

                using var process = Process.Start(processInfo);
                if (process == null) throw new InvalidOperationException("Failed to start nvidia-smi process");

                string output = await process.StandardOutput.ReadLineAsync();
                _cachedGpuUsage = float.TryParse(output, out var gpuUsage) ? gpuUsage : 0;
                _lastGpuQueryTime = DateTime.Now; // Update cache time

                return _cachedGpuUsage;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching GPU usage: {ex.Message}");
                return 0;
            }
        }

        // Get Storage Information (with caching)
        public static (double TotalStorage, double AvailableStorage) GetStorageInfo(string driveLetter = null)
        {
            try
            {
                // Return cached value if still valid
                if ((DateTime.Now - _lastStorageQueryTime).TotalSeconds < CacheDurationSeconds)
                    return _cachedStorageInfo;

                var drive = DriveInfo.GetDrives()
                    .FirstOrDefault(d =>
                        d.IsReady && d.DriveType == DriveType.Fixed &&
                        (string.IsNullOrEmpty(driveLetter) || d.Name.StartsWith(driveLetter, StringComparison.OrdinalIgnoreCase)));

                if (drive != null)
                {
                    double totalStorage = drive.TotalSize / (1024.0 * 1024 * 1024); // GB
                    double availableStorage = drive.AvailableFreeSpace / (1024.0 * 1024 * 1024); // GB

                    _cachedStorageInfo = (totalStorage, availableStorage);
                    _lastStorageQueryTime = DateTime.Now; // Update cache time
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching storage info: {ex.Message}");
            }

            return _cachedStorageInfo; // Return cached or default value
        }

        // Get RAM Usage
        public static (double TotalRam, double UsedRam) GetRamUsage()
        {
            try
            {
                var searcher = new ManagementObjectSearcher("SELECT TotalVisibleMemorySize, FreePhysicalMemory FROM Win32_OperatingSystem");
                foreach (var obj in searcher.Get())
                {
                    double totalRam = Convert.ToDouble(obj["TotalVisibleMemorySize"]) / 1024; // MB
                    double freeRam = Convert.ToDouble(obj["FreePhysicalMemory"]) / 1024; // MB
                    double usedRam = totalRam - freeRam;

                    return (Math.Round(totalRam / 1024, 2), Math.Round(usedRam / 1024, 2)); // Convert MB to GB
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching RAM usage: {ex.Message}");
            }

            return (0, 0); // Fallback in case of an error
        }

        // Consolidated Method to Get All System Usage (with parallel execution)
        public static async Task<SystemUsage> GetSystemUsageAsync()
        {
            var cpuTask = GetCpuUsageAsync();
            var gpuTask = GetGpuUsageAsync();
            var storageInfo = GetStorageInfo();
            var ramInfo = GetRamUsage();

            await Task.WhenAll(cpuTask, gpuTask); // Execute CPU and GPU tasks in parallel

            return new SystemUsage
            {
                CpuUsage = cpuTask.Result,
                GpuUsage = gpuTask.Result,
                TotalStorage = storageInfo.TotalStorage,
                AvailableStorage = storageInfo.AvailableStorage,
                TotalRam = ramInfo.TotalRam,
                UsedRam = ramInfo.UsedRam
            };
        }
    }
}
