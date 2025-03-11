using System;
using System.Text.Json.Serialization;

namespace CoolPanelApi.Models
{
    public class SystemUsage
    {
        private double _cpuUsage;
        private double _gpuUsage;
        private double _totalStorage;
        private double _availableStorage;
        private double _totalRam;
        private double _usedRam;

        /// <summary>
        /// CPU usage percentage (0-100).
        /// </summary>
        public double CpuUsage
        {
            get => _cpuUsage;
            set => _cpuUsage = (value >= 0 && value <= 100) 
                ? value 
                : throw new ArgumentOutOfRangeException(nameof(CpuUsage), "Value must be between 0 and 100.");
        }

        /// <summary>
        /// GPU usage percentage (0-100).
        /// </summary>
        public double GpuUsage
        {
            get => _gpuUsage;
            set => _gpuUsage = (value >= 0 && value <= 100) 
                ? value 
                : throw new ArgumentOutOfRangeException(nameof(GpuUsage), "Value must be between 0 and 100.");
        }

        /// <summary>
        /// Total storage in GB.
        /// </summary>
        public double TotalStorage
        {
            get => _totalStorage;
            set
            {
                if (value < 0) 
                    throw new ArgumentOutOfRangeException(nameof(TotalStorage), "Value cannot be negative.");
                _totalStorage = value;
            }
        }

        /// <summary>
        /// Available storage in GB.
        /// </summary>
        public double AvailableStorage
        {
            get => _availableStorage;
            set
            {
                if (value < 0 || value > TotalStorage) 
                    throw new ArgumentOutOfRangeException(nameof(AvailableStorage), "Value must be between 0 and TotalStorage.");
                _availableStorage = value;
            }
        }

        /// <summary>
        /// Total RAM in GB.
        /// </summary>
        public double TotalRam
        {
            get => _totalRam;
            set
            {
                if (value < 0) 
                    throw new ArgumentOutOfRangeException(nameof(TotalRam), "Value cannot be negative.");
                _totalRam = value;
            }
        }

        /// <summary>
        /// Used RAM in GB.
        /// </summary>
        public double UsedRam
        {
            get => _usedRam;
            set
            {
                if (value < 0 || value > TotalRam) 
                    throw new ArgumentOutOfRangeException(nameof(UsedRam), "Value must be between 0 and TotalRam.");
                _usedRam = value;
            }
        }

        /// <summary>
        /// Calculated used storage in GB.
        /// </summary>
        [JsonIgnore]
        public double UsedStorage => TotalStorage - AvailableStorage;

        /// <summary>
        /// Percentage of available RAM.
        /// </summary>
        [JsonIgnore]
        public double AvailableRamPercentage => (TotalRam > 0) 
            ? (100.0 - (UsedRam / TotalRam * 100)) 
            : 0;
    }
}
