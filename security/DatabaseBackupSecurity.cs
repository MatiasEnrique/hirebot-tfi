using System;
using System.Collections.Generic;
using System.Web;
using Hirebot_TFI.Abstractions;
using Hirebot_TFI.BLL;
using ABSTRACTIONS;
using SECURITY;

namespace Hirebot_TFI.Security
{
    /// <summary>
    /// Capa de seguridad para operaciones de backup y restore de la base de datos
    /// Solo permite acceso a usuarios con rol de Administrador
    /// </summary>
    public class DatabaseBackupSecurity
    {
        private readonly DatabaseBackupBLL _bll;
        private readonly AdminSecurity _adminSecurity;

        public DatabaseBackupSecurity()
        {
            _bll = new DatabaseBackupBLL();
            _adminSecurity = new AdminSecurity();
        }

        /// <summary>
        /// Verifica si el usuario actual tiene permisos de administrador
        /// </summary>
        private bool IsUserAdmin()
        {
            return _adminSecurity.IsUserAdmin();
        }

        /// <summary>
        /// Crea un backup completo de la base de datos
        /// Requiere permisos de administrador
        /// </summary>
        public DatabaseOperationResult CreateBackup(string backupPath)
        {
            if (!IsUserAdmin())
            {
                return new DatabaseOperationResult
                {
                    Success = false,
                    Message = "No tiene permisos para realizar esta operación"
                };
            }

            return _bll.CreateBackup(backupPath);
        }

        /// <summary>
        /// Restaura la base de datos desde un archivo de backup
        /// Requiere permisos de administrador
        /// </summary>
        public DatabaseOperationResult RestoreDatabase(string backupPath)
        {
            if (!IsUserAdmin())
            {
                return new DatabaseOperationResult
                {
                    Success = false,
                    Message = "No tiene permisos para realizar esta operación"
                };
            }

            return _bll.RestoreDatabase(backupPath);
        }

        /// <summary>
        /// Lista los archivos de backup disponibles en el directorio especificado
        /// Requiere permisos de administrador
        /// </summary>
        public List<DatabaseBackup> ListBackups(string backupDirectory)
        {
            if (!IsUserAdmin())
            {
                return new List<DatabaseBackup>();
            }

            return _bll.ListBackups(backupDirectory);
        }

        /// <summary>
        /// Obtiene información sobre un archivo de backup
        /// Requiere permisos de administrador
        /// </summary>
        public DatabaseOperationResult GetBackupInfo(string backupPath)
        {
            if (!IsUserAdmin())
            {
                return new DatabaseOperationResult
                {
                    Success = false,
                    Message = "No tiene permisos para realizar esta operación"
                };
            }

            return _bll.GetBackupInfo(backupPath);
        }
    }
}
