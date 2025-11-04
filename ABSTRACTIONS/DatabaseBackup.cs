using System;

namespace Hirebot_TFI.Abstractions
{
    /// <summary>
    /// Representa información sobre un backup de base de datos
    /// </summary>
    public class DatabaseBackup
    {
        public string FileName { get; set; }
        public string FullPath { get; set; }
        public DateTime? BackupDate { get; set; }
        public long? FileSize { get; set; }
    }

    /// <summary>
    /// Resultado de operaciones de backup/restore
    /// </summary>
    public class DatabaseOperationResult
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public Exception Error { get; set; }
    }
}
