using System;
using System.Collections.Generic;
using Hirebot_TFI.Abstractions;
using Hirebot_TFI.DAL;

namespace Hirebot_TFI.BLL
{
    /// <summary>
    /// Capa de lógica de negocio para operaciones de backup y restore de la base de datos
    /// </summary>
    public class DatabaseBackupBLL
    {
        private readonly DatabaseBackupDAL _dal;

        public DatabaseBackupBLL()
        {
            _dal = new DatabaseBackupDAL();
        }

        /// <summary>
        /// Crea un backup completo de la base de datos
        /// </summary>
        public DatabaseOperationResult CreateBackup(string backupPath)
        {
            // Validación básica
            if (string.IsNullOrWhiteSpace(backupPath))
            {
                return new DatabaseOperationResult
                {
                    Success = false,
                    Message = "La ruta del backup es requerida"
                };
            }

            if (!backupPath.EndsWith(".bak", StringComparison.OrdinalIgnoreCase))
            {
                return new DatabaseOperationResult
                {
                    Success = false,
                    Message = "La ruta del backup debe terminar en .bak"
                };
            }

            // Llamar a DAL
            return _dal.CreateBackup(backupPath);
        }

        /// <summary>
        /// Restaura la base de datos desde un archivo de backup
        /// </summary>
        public DatabaseOperationResult RestoreDatabase(string backupPath)
        {
            // Validación básica
            if (string.IsNullOrWhiteSpace(backupPath))
            {
                return new DatabaseOperationResult
                {
                    Success = false,
                    Message = "La ruta del backup es requerida"
                };
            }

            if (!backupPath.EndsWith(".bak", StringComparison.OrdinalIgnoreCase))
            {
                return new DatabaseOperationResult
                {
                    Success = false,
                    Message = "El archivo debe ser un archivo .bak válido"
                };
            }

            // Llamar a DAL
            return _dal.RestoreDatabase(backupPath);
        }

        /// <summary>
        /// Lista los archivos de backup disponibles en el directorio especificado
        /// </summary>
        public List<DatabaseBackup> ListBackups(string backupDirectory)
        {
            if (string.IsNullOrWhiteSpace(backupDirectory))
            {
                return new List<DatabaseBackup>();
            }

            return _dal.ListBackups(backupDirectory);
        }

        /// <summary>
        /// Obtiene información sobre un archivo de backup
        /// </summary>
        public DatabaseOperationResult GetBackupInfo(string backupPath)
        {
            if (string.IsNullOrWhiteSpace(backupPath))
            {
                return new DatabaseOperationResult
                {
                    Success = false,
                    Message = "La ruta del backup es requerida"
                };
            }

            return _dal.GetBackupInfo(backupPath);
        }
    }
}
