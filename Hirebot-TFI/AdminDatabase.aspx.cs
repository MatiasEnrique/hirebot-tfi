using System;
using System.Collections.Generic;
using System.IO;
using System.Web.UI;
using Hirebot_TFI.Abstractions;
using Hirebot_TFI.Security;
using SECURITY;
using SERVICES;

namespace Hirebot_TFI
{
    public partial class AdminDatabase : BasePage
    {
        private DatabaseBackupSecurity _security;
        private AdminSecurity _adminSecurity;

        protected void Page_Load(object sender, EventArgs e)
        {
            _adminSecurity = new AdminSecurity();
            _adminSecurity.RedirectIfNotAdmin();

            _security = new DatabaseBackupSecurity();

            if (!IsPostBack)
            {
                // Sugerir ruta de backup predeterminada
                string suggestedPath = $"C:\\Backups\\Hirebot_Backup_{DateTime.Now:yyyyMMdd_HHmmss}.bak";
                txtBackupPath.Text = suggestedPath;

                // Sugerir directorio de backups predeterminado
                txtBackupDirectory.Text = "C:\\Backups";
            }
        }

        protected void btnCreateBackup_Click(object sender, EventArgs e)
        {
            try
            {
                string backupPath = txtBackupPath.Text.Trim();

                if (string.IsNullOrWhiteSpace(backupPath))
                {
                    ShowAlert("Debes ingresar una ruta para el backup.", "warning");
                    return;
                }

                // Validar extensión
                if (!backupPath.EndsWith(".bak", StringComparison.OrdinalIgnoreCase))
                {
                    ShowAlert("La ruta del backup debe terminar en .bak", "warning");
                    return;
                }

                // Verificar que el directorio existe
                string directory = Path.GetDirectoryName(backupPath);
                if (!string.IsNullOrEmpty(directory) && !Directory.Exists(directory))
                {
                    try
                    {
                        Directory.CreateDirectory(directory);
                    }
                    catch (Exception ex)
                    {
                        ShowAlert($"Error al crear el directorio: {ex.Message}", "danger");
                        return;
                    }
                }

                // Crear backup a través de la capa de seguridad
                DatabaseOperationResult result = _security.CreateBackup(backupPath);

                if (result.Success)
                {
                    ShowAlert($"Backup creado exitosamente en: {backupPath}", "success");

                    // Generar nueva ruta sugerida para el próximo backup
                    string suggestedPath = $"C:\\Backups\\Hirebot_Backup_{DateTime.Now:yyyyMMdd_HHmmss}.bak";
                    txtBackupPath.Text = suggestedPath;
                }
                else
                {
                    ShowAlert($"Error al crear el backup: {result.Message}", "danger");
                }
            }
            catch (Exception ex)
            {
                ShowAlert($"Error inesperado: {ex.Message}", "danger");
                LogError(ex, "Error al crear backup");
            }
        }

        protected void btnRestoreBackup_Click(object sender, EventArgs e)
        {
            try
            {
                string restorePath = txtRestorePath.Text.Trim();

                if (string.IsNullOrWhiteSpace(restorePath))
                {
                    ShowAlert("Debes ingresar la ruta del archivo de backup a restaurar.", "warning");
                    return;
                }

                // Validar extensión
                if (!restorePath.EndsWith(".bak", StringComparison.OrdinalIgnoreCase))
                {
                    ShowAlert("El archivo debe ser un archivo .bak válido.", "warning");
                    return;
                }

                // NO verificar File.Exists aquí - la aplicación web no tiene permisos
                // SQL Server verificará la existencia del archivo

                // Restaurar backup a través de la capa de seguridad
                DatabaseOperationResult result = _security.RestoreDatabase(restorePath);

                if (result.Success)
                {
                    ShowAlert("Base de datos restaurada exitosamente. Por favor, reinicia la aplicación.", "success");

                    // Limpiar campo
                    txtRestorePath.Text = string.Empty;
                }
                else
                {
                    ShowAlert($"Error al restaurar la base de datos: {result.Message}", "danger");
                }
            }
            catch (Exception ex)
            {
                ShowAlert($"Error inesperado: {ex.Message}", "danger");
                LogError(ex, "Error al restaurar backup");
            }
        }

        protected void btnListBackups_Click(object sender, EventArgs e)
        {
            try
            {
                string backupDirectory = txtBackupDirectory.Text.Trim();

                if (string.IsNullOrWhiteSpace(backupDirectory))
                {
                    ShowAlert("Debes ingresar un directorio para buscar backups.", "warning");
                    return;
                }

                if (!Directory.Exists(backupDirectory))
                {
                    ShowAlert("El directorio especificado no existe.", "warning");
                    return;
                }

                // Listar backups a través de la capa de seguridad
                List<DatabaseBackup> backups = _security.ListBackups(backupDirectory);

                pnlBackupList.Visible = true;

                if (backups != null && backups.Count > 0)
                {
                    rptBackups.DataSource = backups;
                    rptBackups.DataBind();
                    lblNoBackups.Visible = false;
                }
                else
                {
                    rptBackups.DataSource = null;
                    rptBackups.DataBind();
                    lblNoBackups.Visible = true;
                }
            }
            catch (Exception ex)
            {
                ShowAlert($"Error al listar backups: {ex.Message}", "danger");
                LogError(ex, "Error al listar backups");
            }
        }

        private void ShowAlert(string message, string type)
        {
            pnlAlert.Visible = true;
            lblAlert.Text = message;

            // Remover clases previas
            pnlAlert.CssClass = "alert alert-dismissible fade show";

            // Agregar clase según el tipo
            pnlAlert.CssClass += $" alert-{type}";

            // Registrar script para mostrar la alerta
            ScriptManager.RegisterStartupScript(this, GetType(), "showAlert",
                $"showAlert('{type}');", true);
        }

        private void LogError(Exception ex, string context)
        {
            try
            {
                // Log to admin security for audit trail
                _adminSecurity?.LogError(GetCurrentUserId(), $"{context}: {ex.Message}");
            }
            catch
            {
                // No hacer nada si el logging falla
            }
        }

        private int? GetCurrentUserId()
        {
            try
            {
                var userSecurity = new UserSecurity();
                var currentUser = userSecurity.GetCurrentUser();
                return currentUser?.UserId;
            }
            catch
            {
                return null;
            }
        }

        private string GetUsername()
        {
            try
            {
                var userSecurity = new UserSecurity();
                var currentUser = userSecurity.GetCurrentUser();
                return currentUser?.Username ?? "Unknown";
            }
            catch
            {
                return "Unknown";
            }
        }
    }
}
