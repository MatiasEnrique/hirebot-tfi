using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI.WebControls;
using ABSTRACTIONS;
using SECURITY;

namespace Hirebot_TFI
{
    public partial class AdminRoles : BasePage
    {
        private const string PermissionCatalogKey = "PermissionCatalog";

        private readonly AdminRoleSecurity _adminRoleSecurity = new AdminRoleSecurity();

        private List<AdminPermission> PermissionCatalog
        {
            get => ViewState[PermissionCatalogKey] as List<AdminPermission> ?? new List<AdminPermission>();
            set => ViewState[PermissionCatalogKey] = value;
        }

        private int SelectedRoleId
        {
            get
            {
                if (int.TryParse(hdnSelectedRoleId.Value, out var roleId))
                {
                    return roleId;
                }

                return 0;
            }
            set => hdnSelectedRoleId.Value = value.ToString();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadPermissions();
                LoadRoles();
            }
        }

        protected void btnNewRole_Click(object sender, EventArgs e)
        {
            ClearRoleForm();
            pnlRoleDetail.Visible = true;
            ShowMessage(GetGlobalString("AdminRolesReadyToCreate"), true);
        }

        protected void btnSaveRole_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
            {
                return;
            }

            var role = new AdminRole
            {
                RoleId = SelectedRoleId,
                RoleName = txtRoleName.Text?.Trim(),
                Description = string.IsNullOrWhiteSpace(txtRoleDescription.Text) ? null : txtRoleDescription.Text.Trim(),
                IsActive = chkIsActive.Checked
            };

            var saveResult = _adminRoleSecurity.SaveRole(role);
            if (!saveResult.IsSuccessful)
            {
                ShowMessage(saveResult.ErrorMessage ?? GetGlobalString("AdminRolesSaveError"), false);
                return;
            }

            SelectedRoleId = role.RoleId;

            var selectedPermissions = GetSelectedPermissionKeys();
            var permissionResult = _adminRoleSecurity.UpdateRolePermissions(role.RoleId, selectedPermissions);
            if (!permissionResult.IsSuccessful)
            {
                ShowMessage(permissionResult.ErrorMessage ?? GetGlobalString("AdminRolesPermissionsUpdateError"), false);
                return;
            }

            ShowMessage(GetGlobalString("AdminRolesSaveSuccess"), true);
            LoadRoles();
            LoadRoleDetail(role.RoleId);
        }

        protected void btnDeleteRole_Click(object sender, EventArgs e)
        {
            if (SelectedRoleId <= 0)
            {
                ShowMessage(GetGlobalString("AdminRolesSelectRoleWarning"), false);
                return;
            }

            var result = _adminRoleSecurity.DeleteRole(SelectedRoleId);
            if (!result.IsSuccessful)
            {
                ShowMessage(result.ErrorMessage ?? GetGlobalString("AdminRolesDeleteError"), false);
                return;
            }

            ShowMessage(GetGlobalString("AdminRolesDeleteSuccess"), true);
            SelectedRoleId = 0;
            ClearRoleForm();
            pnlRoleDetail.Visible = false;
            LoadRoles();
        }

        protected void btnAssignRole_Click(object sender, EventArgs e)
        {
            if (SelectedRoleId <= 0)
            {
                ShowMessage(GetGlobalString("AdminRolesSelectRoleWarning"), false);
                return;
            }

            var username = txtAssignUsername.Text?.Trim();
            if (string.IsNullOrWhiteSpace(username))
            {
                ShowMessage(GetGlobalString("AdminRolesUsernameRequired"), false);
                return;
            }

            var assignResult = _adminRoleSecurity.AssignRoleToUser(username, SelectedRoleId);
            if (!assignResult.IsSuccessful)
            {
                ShowMessage(assignResult.ErrorMessage ?? GetGlobalString("AdminRolesAssignError"), false);
                return;
            }

            txtAssignUsername.Text = string.Empty;
            ShowMessage(GetGlobalString("AdminRolesAssignSuccess"), true);
            LoadRoleDetail(SelectedRoleId);
        }

        protected void rptRoles_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!string.Equals(e.CommandName, "SelectRole", StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            if (!int.TryParse(e.CommandArgument?.ToString(), out var roleId))
            {
                return;
            }

            SelectedRoleId = roleId;
            LoadRoleDetail(roleId);
            LoadRoles();
        }

        protected void rptAssignedUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!string.Equals(e.CommandName, "RemoveUser", StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            if (SelectedRoleId <= 0)
            {
                ShowMessage(GetGlobalString("AdminRolesSelectRoleWarning"), false);
                return;
            }

            if (!int.TryParse(e.CommandArgument?.ToString(), out var userId))
            {
                return;
            }

            var result = _adminRoleSecurity.RemoveRoleFromUser(userId, SelectedRoleId);
            if (!result.IsSuccessful)
            {
                ShowMessage(result.ErrorMessage ?? GetGlobalString("AdminRolesRemoveError"), false);
                return;
            }

            ShowMessage(GetGlobalString("AdminRolesRemoveSuccess"), true);
            LoadRoleDetail(SelectedRoleId);
        }

        protected void rptAssignedUsers_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem)
            {
                return;
            }

            var removeButton = e.Item.FindControl("btnRemoveUser") as LinkButton;
            if (removeButton != null)
            {
                var confirmText = HttpUtility.JavaScriptStringEncode(GetGlobalString("AdminRolesRemoveUserConfirm"));
                removeButton.OnClientClick = $"return confirm('{confirmText}');";
            }
        }

        public string GetRoleCardCss(object roleIdObj)
        {
            var classes = "role-card mb-3";

            if (roleIdObj != null && int.TryParse(roleIdObj.ToString(), out var roleId) && roleId == SelectedRoleId)
            {
                classes += " active";
            }

            return classes;
        }

        public string GetRoleSummary(object isActiveObj, object assignedCountObj, object permissionCountObj)
        {
            var isActive = false;
            if (isActiveObj != null)
            {
                bool.TryParse(isActiveObj.ToString(), out isActive);
            }

            var assignedCount = 0;
            if (assignedCountObj != null)
            {
                int.TryParse(assignedCountObj.ToString(), out assignedCount);
            }

            var permissionCount = 0;
            if (permissionCountObj != null)
            {
                int.TryParse(permissionCountObj.ToString(), out permissionCount);
            }

            var statusKey = isActive ? "AdminRolesStatusActive" : "AdminRolesStatusInactive";
            var status = GetGlobalString(statusKey);
            var format = GetGlobalString("AdminRolesSummaryFormat");

            return string.Format(format, status, assignedCount, permissionCount);
        }

        private void LoadRoles()
        {
            var result = _adminRoleSecurity.GetAllRoles();

            if (!result.IsSuccessful)
            {
                rptRoles.DataSource = null;
                rptRoles.DataBind();
                pnlNoRoles.Visible = true;
                ShowMessage(result.ErrorMessage ?? GetGlobalString("AdminRolesLoadError"), false);
                return;
            }

            var roles = result.Data ?? new List<AdminRoleSummary>();
            rptRoles.DataSource = roles.OrderByDescending(r => r.IsActive).ThenBy(r => r.RoleName).ToList();
            rptRoles.DataBind();

            pnlNoRoles.Visible = roles.Count == 0;
        }

        private void LoadPermissions()
        {
            var result = _adminRoleSecurity.GetActivePermissions();

            if (!result.IsSuccessful)
            {
                ShowMessage(result.ErrorMessage ?? GetGlobalString("AdminRolesLoadPermissionsError"), false);
                return;
            }

            var permissions = result.Data ?? new List<AdminPermission>();
            var ordered = permissions
                .OrderBy(p => p.Category)
                .ThenBy(p => p.SortOrder)
                .ThenBy(p => p.DisplayName)
                .ToList();

            PermissionCatalog = ordered;

            cblPermissions.DataSource = ordered;
            cblPermissions.DataTextField = "DisplayName";
            cblPermissions.DataValueField = "PermissionKey";
            cblPermissions.DataBind();

            for (var i = 0; i < ordered.Count && i < cblPermissions.Items.Count; i++)
            {
                var permission = ordered[i];
                var label = string.IsNullOrWhiteSpace(permission.Category)
                    ? permission.DisplayName
                    : string.Format("{0} · {1}", permission.Category, permission.DisplayName);

                cblPermissions.Items[i].Text = label;
            }
        }

        private void LoadRoleDetail(int roleId)
        {
            ClearMessage();

            if (roleId <= 0)
            {
                ClearRoleForm();
                pnlRoleDetail.Visible = false;
                return;
            }

            var result = _adminRoleSecurity.GetRoleById(roleId);
            if (!result.IsSuccessful || result.Data == null)
            {
                ShowMessage(result.ErrorMessage ?? GetGlobalString("AdminRolesLoadDetailError"), false);
                return;
            }

            BindRoleDetail(result.Data);
        }

        private void BindRoleDetail(AdminRoleDetail detail)
        {
            if (detail == null)
            {
                return;
            }

            pnlRoleDetail.Visible = true;

            var role = detail.Role ?? new AdminRole();

            SelectedRoleId = role.RoleId;
            txtRoleName.Text = role.RoleName;
            txtRoleDescription.Text = role.Description;
            chkIsActive.Checked = role.IsActive;

            litRoleHeader.Text = string.IsNullOrWhiteSpace(role.RoleName)
                ? GetGlobalString("AdminRolesNewRole")
                : role.RoleName;

            SetRoleStatusBadge(role.IsActive);
            btnDeleteRole.Visible = role.RoleId > 0;
            SetDeleteConfirmation();

            var assigned = new HashSet<string>(detail.PermissionKeys ?? new List<string>(), StringComparer.OrdinalIgnoreCase);
            foreach (ListItem item in cblPermissions.Items)
            {
                item.Selected = assigned.Contains(item.Value);
            }

            BindAssignedUsers(detail.AssignedUsers);
        }

        private void BindAssignedUsers(ICollection<AdminUserRoleAssignment> assignments)
        {
            var items = assignments?.OrderBy(a => a.FullName).ToList() ?? new List<AdminUserRoleAssignment>();
            rptAssignedUsers.DataSource = items;
            rptAssignedUsers.DataBind();
            pnlNoAssignedUsers.Visible = items.Count == 0;
        }

        private void ClearRoleForm()
        {
            SelectedRoleId = 0;
            txtRoleName.Text = string.Empty;
            txtRoleDescription.Text = string.Empty;
            chkIsActive.Checked = true;
            litRoleHeader.Text = GetGlobalString("AdminRolesNewRole");
            SetRoleStatusBadge(true);
            btnDeleteRole.Visible = false;
            SetDeleteConfirmation();

            foreach (ListItem item in cblPermissions.Items)
            {
                item.Selected = false;
            }

            BindAssignedUsers(null);
        }

        private List<string> GetSelectedPermissionKeys()
        {
            return cblPermissions.Items.Cast<ListItem>()
                .Where(item => item.Selected)
                .Select(item => item.Value)
                .ToList();
        }

        private void SetRoleStatusBadge(bool isActive)
        {
            badgeRoleStatus.InnerText = GetGlobalString(isActive ? "AdminRolesStatusActive" : "AdminRolesStatusInactive");
            badgeRoleStatus.Attributes["class"] = isActive ? "badge bg-success-subtle text-success" : "badge bg-secondary";
        }

        private void SetDeleteConfirmation()
        {
            var confirmText = HttpUtility.JavaScriptStringEncode(GetGlobalString("AdminRolesDeleteConfirm"));
            btnDeleteRole.OnClientClick = btnDeleteRole.Visible ? $"return confirm('{confirmText}');" : string.Empty;
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            if (string.IsNullOrWhiteSpace(message))
            {
                pnlMessage.Visible = false;
                return;
            }

            pnlMessage.Visible = true;
            pnlMessage.CssClass = isSuccess ? "alert alert-success" : "alert alert-danger";
            pnlMessage.Controls.Clear();
            pnlMessage.Controls.Add(new Literal { Text = HttpUtility.HtmlEncode(message) });
        }

        private void ClearMessage()
        {
            pnlMessage.Visible = false;
            pnlMessage.Controls.Clear();
        }

        private static string GetGlobalString(string key)
        {
            return key;
        }
    }
}
