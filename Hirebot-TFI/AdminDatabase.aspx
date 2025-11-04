<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminDatabase.aspx.cs" Inherits="Hirebot_TFI.AdminDatabase" MasterPageFile="~/Admin.master" %>

<asp:Content ID="AdminDatabaseTitle" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="Gestión de base de datos" />
</asp:Content>

<asp:Content ID="AdminDatabaseHead" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .admin-title {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 1.5rem;
        }

        .admin-title .bi-database {
            font-size: 1.5rem;
            color: #4b4e6d;
        }

        .card-rounded {
            border-radius: 1rem;
            border: none;
            box-shadow: 0 0.5rem 1.5rem rgba(15, 23, 42, 0.08);
        }

        .card-rounded .card-header {
            border-bottom: 1px solid rgba(15, 23, 42, 0.08);
            background-color: #ffffff;
            border-radius: 1rem 1rem 0 0;
        }

        .backup-item {
            padding: 1rem;
            border: 1px solid rgba(15, 23, 42, 0.08);
            border-radius: 0.5rem;
            margin-bottom: 0.5rem;
            transition: all 0.2s ease;
        }

        .backup-item:hover {
            background-color: rgba(132, 220, 198, 0.05);
            border-color: #84dcc6;
        }

        .warning-box {
            background-color: #fff3cd;
            border: 1px solid #ffc107;
            border-radius: 0.5rem;
            padding: 1rem;
            margin-bottom: 1.5rem;
        }

        .warning-box i {
            color: #ffc107;
            font-size: 1.2rem;
        }
    </style>
</asp:Content>

<asp:Content ID="AdminDatabaseMain" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Panel ID="pnlAlert" runat="server" CssClass="alert alert-dismissible fade show d-none" Visible="false">
        <asp:Label ID="lblAlert" runat="server" />
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </asp:Panel>

    <div class="admin-title">
        <i class="bi bi-database"></i>
        <div>
            <h2 class="mb-0"><asp:Literal runat="server" Text="Gestión de base de datos" /></h2>
            <small class="text-muted"><asp:Literal runat="server" Text="Crea y restaura backups de la base de datos Hirebot." /></small>
        </div>
    </div>

    <div class="warning-box">
        <div class="d-flex align-items-start gap-3">
            <i class="bi bi-exclamation-triangle-fill"></i>
            <div>
                <strong>Advertencia:</strong>
                <p class="mb-0">Las operaciones de backup y restore son críticas. Asegúrate de tener suficiente espacio en disco y que ningún usuario esté usando activamente la aplicación durante la restauración.</p>
            </div>
        </div>
    </div>

    <!-- Crear Backup -->
    <div class="card card-rounded mb-4">
        <div class="card-header">
            <div class="d-flex align-items-center gap-2">
                <i class="bi bi-save text-primary"></i>
                <strong><asp:Literal runat="server" Text="Crear backup" /></strong>
            </div>
        </div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-9">
                    <label for="txtBackupPath" class="form-label"><asp:Literal runat="server" Text="Ruta completa del archivo de backup" /></label>
                    <asp:TextBox ID="txtBackupPath" runat="server" CssClass="form-control" placeholder="C:\Backups\Hirebot_Backup_20250104.bak" />
                    <small class="text-muted"><asp:Literal runat="server" Text="Ejemplo: C:\Backups\Hirebot_Backup_20250104.bak" /></small>
                </div>
                <div class="col-md-3 d-flex align-items-end">
                    <asp:Button ID="btnCreateBackup" runat="server" CssClass="btn btn-primary w-100" Text="Crear backup" OnClick="btnCreateBackup_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- Restaurar Backup -->
    <div class="card card-rounded mb-4">
        <div class="card-header">
            <div class="d-flex align-items-center gap-2">
                <i class="bi bi-arrow-counterclockwise text-warning"></i>
                <strong><asp:Literal runat="server" Text="Restaurar backup" /></strong>
            </div>
        </div>
        <div class="card-body">
            <div class="alert alert-danger">
                <i class="bi bi-exclamation-triangle me-2"></i>
                <strong><asp:Literal runat="server" Text="¡PRECAUCIÓN!" /></strong>
                <asp:Literal runat="server" Text=" Restaurar un backup reemplazará TODOS los datos actuales de la base de datos. Esta acción no se puede deshacer." />
                <br /><br />
                <strong><asp:Literal runat="server" Text="IMPORTANTE:" /></strong>
                <asp:Literal runat="server" Text=" Todos los usuarios serán desconectados automáticamente durante la restauración. Asegúrate de que nadie esté usando la aplicación." />
            </div>

            <div class="row g-3">
                <div class="col-md-9">
                    <label for="txtRestorePath" class="form-label"><asp:Literal runat="server" Text="Ruta completa del archivo de backup a restaurar" /></label>
                    <asp:TextBox ID="txtRestorePath" runat="server" CssClass="form-control" placeholder="C:\Backups\Hirebot_Backup_20250104.bak" />
                    <small class="text-muted"><asp:Literal runat="server" Text="Debe ser un archivo .bak válido" /></small>
                </div>
                <div class="col-md-3 d-flex align-items-end">
                    <asp:Button ID="btnRestoreBackup" runat="server" CssClass="btn btn-warning w-100" Text="Restaurar backup" OnClick="btnRestoreBackup_Click" OnClientClick="return confirm('¿Estás seguro de que deseas restaurar este backup?\n\n⚠️ Esto reemplazará todos los datos actuales.\n⚠️ Todos los usuarios serán desconectados.\n⚠️ Esta acción NO se puede deshacer.\n\n¿Deseas continuar?');" />
                </div>
            </div>
        </div>
    </div>

    <!-- Listar Backups Disponibles -->
    <div class="card card-rounded">
        <div class="card-header">
            <div class="d-flex justify-content-between align-items-center">
                <div class="d-flex align-items-center gap-2">
                    <i class="bi bi-folder2-open text-info"></i>
                    <strong><asp:Literal runat="server" Text="Backups disponibles" /></strong>
                </div>
            </div>
        </div>
        <div class="card-body">
            <div class="row g-3 mb-3">
                <div class="col-md-9">
                    <label for="txtBackupDirectory" class="form-label"><asp:Literal runat="server" Text="Directorio de backups" /></label>
                    <asp:TextBox ID="txtBackupDirectory" runat="server" CssClass="form-control" placeholder="C:\Backups" />
                </div>
                <div class="col-md-3 d-flex align-items-end">
                    <asp:Button ID="btnListBackups" runat="server" CssClass="btn btn-info w-100" Text="Listar backups" OnClick="btnListBackups_Click" />
                </div>
            </div>

            <asp:Panel ID="pnlBackupList" runat="server" Visible="false">
                <hr />
                <asp:Repeater ID="rptBackups" runat="server">
                    <ItemTemplate>
                        <div class="backup-item">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <i class="bi bi-file-earmark-zip me-2 text-primary"></i>
                                    <strong><%#: Eval("FileName") %></strong>
                                    <div class="text-muted small mt-1"><%#: Eval("FullPath") %></div>
                                </div>
                                <div>
                                    <button type="button" class="btn btn-sm btn-outline-secondary" onclick="copyToClipboard('<%# Eval("FullPath") %>')">
                                        <i class="bi bi-clipboard"></i> Copiar ruta
                                    </button>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Label ID="lblNoBackups" runat="server" CssClass="text-muted" Text="No se encontraron archivos de backup en este directorio." Visible="false" />
            </asp:Panel>
        </div>
    </div>
</asp:Content>

<asp:Content ID="AdminDatabaseScripts" ContentPlaceHolderID="ScriptContent" runat="server">
    <script>
        function copyToClipboard(text) {
            if (navigator.clipboard && navigator.clipboard.writeText) {
                navigator.clipboard.writeText(text).then(function() {
                    showToast('Ruta copiada al portapapeles', 'success');
                }).catch(function() {
                    fallbackCopy(text);
                });
            } else {
                fallbackCopy(text);
            }
        }

        function fallbackCopy(text) {
            const textArea = document.createElement('textarea');
            textArea.value = text;
            textArea.style.position = 'fixed';
            textArea.style.left = '-9999px';
            document.body.appendChild(textArea);
            textArea.select();
            try {
                document.execCommand('copy');
                showToast('Ruta copiada al portapapeles', 'success');
            } catch (err) {
                showToast('Error al copiar la ruta', 'danger');
            }
            document.body.removeChild(textArea);
        }

        function showToast(message, type) {
            const alertDiv = document.createElement('div');
            alertDiv.className = 'alert alert-' + type + ' alert-dismissible fade show position-fixed';
            alertDiv.style.top = '20px';
            alertDiv.style.right = '20px';
            alertDiv.style.zIndex = '9999';
            alertDiv.style.minWidth = '300px';
            alertDiv.innerHTML = message + '<button type="button" class="btn-close" data-bs-dismiss="alert"></button>';
            document.body.appendChild(alertDiv);

            setTimeout(function() {
                alertDiv.classList.remove('show');
                setTimeout(function() {
                    document.body.removeChild(alertDiv);
                }, 150);
            }, 3000);
        }

        function showAlert(type) {
            const panel = document.getElementById('<%= pnlAlert.ClientID %>');
            if (!panel) return;

            panel.classList.remove('d-none');
            panel.classList.remove('alert-success', 'alert-danger', 'alert-info', 'alert-warning');
            panel.classList.add('alert-' + type, 'd-block');
            window.scrollTo({ top: 0, behavior: 'smooth' });
        }
    </script>
</asp:Content>
