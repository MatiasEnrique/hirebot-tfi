using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using ABSTRACTIONS;
using Hirebot_TFI;
using SECURITY;

namespace UI
{
    public partial class AdminUsers : BasePage
    {
        private const string AdminUsersPermissionKey = "~/AdminUsers.aspx";
        
        private AdminSecurity adminSecurity;
        private AuthorizationSecurity authorizationSecurity;
        private List<User> allUsers;

        protected void Page_Load(object sender, EventArgs e)
        {
            adminSecurity = new AdminSecurity();
            authorizationSecurity = new AuthorizationSecurity();
            
            // Ensure user has permission to access this page
            if (!authorizationSecurity.UserHasPermission(AdminUsersPermissionKey))
            {
                Response.Redirect("~/AccessDenied.aspx", true);
                return;
            }

            if (!IsPostBack)
            {
                LoadStatistics();
                LoadUsers();
            }
        }

        #region Event Handlers

        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            LoadUsers();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadStatistics();
            LoadUsers();
        }

        protected void btnCreateUser_Click(object sender, EventArgs e)
        {
            // Clear the form and show the modal
            ClearCreateForm();
            litShowModalScript.Text = "showCreateModal();";
        }

        protected void btnSaveNewUser_Click(object sender, EventArgs e)
        {
            CreateNewUser();
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            try
            {
                var button = (LinkButton)sender;
                int userId = Convert.ToInt32(button.CommandArgument);
                LoadUserForEditing(userId);
            }
            catch (Exception ex)
            {
                ShowMessage("Error al cargar el usuario: " + ex.Message, "danger");
            }
        }

        protected void btnToggleStatus_Click(object sender, EventArgs e)
        {
            try
            {
                var button = (LinkButton)sender;
                int userId = Convert.ToInt32(button.CommandArgument);
                ToggleUserStatus(userId);
            }
            catch (Exception ex)
            {
                ShowMessage("Error al cambiar el estado del usuario: " + ex.Message, "danger");
            }
        }

        protected void btnSaveUser_Click(object sender, EventArgs e)
        {
            SaveUser();
        }

        protected void gvUsers_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvUsers.PageIndex = e.NewPageIndex;
            LoadUsers();
        }

        #endregion

        #region Private Methods

        private void LoadStatistics()
        {
            try
            {
                // Get all users
                var users = adminSecurity.GetAllUsers(includeInactive: true);

                // Calculate statistics
                litTotalUsers.Text = users.Count.ToString();
                litActiveUsers.Text = users.Count(u => u.IsActive).ToString();
                litInactiveUsers.Text = users.Count(u => !u.IsActive).ToString();
                litAdminUsers.Text = users.Count(u => u.UserRole == "admin").ToString();
            }
            catch (Exception ex)
            {
                adminSecurity.LogError(GetCurrentUserId(), "Error loading user statistics: " + ex.Message);
                litTotalUsers.Text = "0";
                litActiveUsers.Text = "0";
                litInactiveUsers.Text = "0";
                litAdminUsers.Text = "0";
            }
        }

        private void LoadUsers()
        {
            try
            {
                // Get all users
                allUsers = adminSecurity.GetAllUsers(includeInactive: true);

                // Apply filters
                var filteredUsers = ApplyFilters(allUsers);

                // Bind to grid
                gvUsers.DataSource = filteredUsers;
                gvUsers.DataBind();
            }
            catch (Exception ex)
            {
                adminSecurity.LogError(GetCurrentUserId(), "Error loading users: " + ex.Message);
                gvUsers.DataSource = new List<User>();
                gvUsers.DataBind();
                ShowMessage("Error al cargar los usuarios: " + ex.Message, "danger");
            }
        }

        private List<User> ApplyFilters(List<User> users)
        {
            var filtered = users;

            // Role filter
            if (!string.IsNullOrEmpty(ddlRoleFilter.SelectedValue))
            {
                filtered = filtered.Where(u => u.UserRole == ddlRoleFilter.SelectedValue).ToList();
            }

            // Status filter
            if (!string.IsNullOrEmpty(ddlStatusFilter.SelectedValue))
            {
                bool isActive = ddlStatusFilter.SelectedValue == "active";
                filtered = filtered.Where(u => u.IsActive == isActive).ToList();
            }

            // Search filter
            if (!string.IsNullOrEmpty(txtSearchFilter.Text))
            {
                string search = txtSearchFilter.Text.Trim().ToLower();
                filtered = filtered.Where(u =>
                    u.Username.ToLower().Contains(search) ||
                    u.Email.ToLower().Contains(search) ||
                    u.FirstName.ToLower().Contains(search) ||
                    u.LastName.ToLower().Contains(search)
                ).ToList();
            }

            return filtered;
        }

        private void LoadUserForEditing(int userId)
        {
            try
            {
                var user = adminSecurity.GetUserById(userId);
                if (user == null)
                {
                    ShowMessage("Usuario no encontrado", "warning");
                    return;
                }

                // Populate edit form
                hfEditUserId.Value = user.UserId.ToString();
                txtEditUsername.Text = user.Username;
                txtEditEmail.Text = user.Email;
                txtEditFirstName.Text = user.FirstName;
                txtEditLastName.Text = user.LastName;
                ddlEditUserRole.SelectedValue = user.UserRole;
                chkEditIsActive.Checked = user.IsActive;

                // Show the modal
                litShowModalScript.Text = "showEditModal();";
            }
            catch (Exception ex)
            {
                adminSecurity.LogError(GetCurrentUserId(), $"Error loading user for editing: {ex.Message}");
                ShowMessage("Error al cargar el usuario: " + ex.Message, "danger");
            }
        }

        private void SaveUser()
        {
            try
            {
                // Validate inputs
                if (string.IsNullOrWhiteSpace(txtEditUsername.Text))
                {
                    ShowMessage("El nombre de usuario es requerido", "warning");
                    litShowModalScript.Text = "showEditModal();";
                    return;
                }

                if (string.IsNullOrWhiteSpace(txtEditEmail.Text))
                {
                    ShowMessage("El correo electrónico es requerido", "warning");
                    litShowModalScript.Text = "showEditModal();";
                    return;
                }

                if (string.IsNullOrWhiteSpace(txtEditFirstName.Text))
                {
                    ShowMessage("El nombre es requerido", "warning");
                    litShowModalScript.Text = "showEditModal();";
                    return;
                }

                if (string.IsNullOrWhiteSpace(txtEditLastName.Text))
                {
                    ShowMessage("El apellido es requerido", "warning");
                    litShowModalScript.Text = "showEditModal();";
                    return;
                }

                // Create user object
                var user = new User
                {
                    UserId = Convert.ToInt32(hfEditUserId.Value),
                    Username = txtEditUsername.Text.Trim(),
                    Email = txtEditEmail.Text.Trim(),
                    FirstName = txtEditFirstName.Text.Trim(),
                    LastName = txtEditLastName.Text.Trim(),
                    UserRole = ddlEditUserRole.SelectedValue,
                    IsActive = chkEditIsActive.Checked
                };

                // Update user
                var result = adminSecurity.UpdateUser(user);

                if (result.IsSuccessful)
                {
                    ShowMessage("Usuario actualizado exitosamente", "success");
                    LoadStatistics();
                    LoadUsers();
                    
                    // Clear form
                    ClearEditForm();
                }
                else
                {
                    ShowMessage(result.ErrorMessage, "danger");
                    litShowModalScript.Text = "showEditModal();";
                }
            }
            catch (Exception ex)
            {
                adminSecurity.LogError(GetCurrentUserId(), $"Error saving user: {ex.Message}");
                ShowMessage("Error al guardar el usuario: " + ex.Message, "danger");
                litShowModalScript.Text = "showEditModal();";
            }
        }

        private void ToggleUserStatus(int userId)
        {
            try
            {
                var user = adminSecurity.GetUserById(userId);
                if (user == null)
                {
                    ShowMessage("Usuario no encontrado", "warning");
                    return;
                }

                DatabaseResult result;
                
                if (user.IsActive)
                {
                    // Deactivate user
                    result = adminSecurity.DeleteUser(userId);
                    if (result.IsSuccessful)
                    {
                        ShowMessage($"Usuario {user.Username} desactivado exitosamente", "success");
                    }
                }
                else
                {
                    // Activate user
                    result = adminSecurity.ActivateUser(userId);
                    if (result.IsSuccessful)
                    {
                        ShowMessage($"Usuario {user.Username} activado exitosamente", "success");
                    }
                }

                if (!result.IsSuccessful)
                {
                    ShowMessage(result.ErrorMessage, "danger");
                }

                LoadStatistics();
                LoadUsers();
            }
            catch (Exception ex)
            {
                adminSecurity.LogError(GetCurrentUserId(), $"Error toggling user status: {ex.Message}");
                ShowMessage("Error al cambiar el estado del usuario: " + ex.Message, "danger");
            }
        }

        private void CreateNewUser()
        {
            try
            {
                // Validate inputs
                if (string.IsNullOrWhiteSpace(txtCreateUsername.Text))
                {
                    ShowMessage("El nombre de usuario es requerido", "warning");
                    litShowModalScript.Text = "showCreateModal();";
                    return;
                }

                if (string.IsNullOrWhiteSpace(txtCreateEmail.Text))
                {
                    ShowMessage("El correo electrónico es requerido", "warning");
                    litShowModalScript.Text = "showCreateModal();";
                    return;
                }

                if (string.IsNullOrWhiteSpace(txtCreateFirstName.Text))
                {
                    ShowMessage("El nombre es requerido", "warning");
                    litShowModalScript.Text = "showCreateModal();";
                    return;
                }

                if (string.IsNullOrWhiteSpace(txtCreateLastName.Text))
                {
                    ShowMessage("El apellido es requerido", "warning");
                    litShowModalScript.Text = "showCreateModal();";
                    return;
                }

                if (string.IsNullOrWhiteSpace(txtCreatePassword.Text))
                {
                    ShowMessage("La contraseña es requerida", "warning");
                    litShowModalScript.Text = "showCreateModal();";
                    return;
                }

                if (txtCreatePassword.Text != txtCreateConfirmPassword.Text)
                {
                    ShowMessage("Las contraseñas no coinciden", "warning");
                    litShowModalScript.Text = "showCreateModal();";
                    return;
                }

                // Create user through security layer
                var result = adminSecurity.CreateUser(
                    txtCreateUsername.Text.Trim(),
                    txtCreateEmail.Text.Trim(),
                    txtCreatePassword.Text,
                    txtCreateFirstName.Text.Trim(),
                    txtCreateLastName.Text.Trim(),
                    ddlCreateUserRole.SelectedValue,
                    chkCreateIsActive.Checked
                );

                if (result.IsSuccessful)
                {
                    ShowMessage("Usuario creado exitosamente", "success");
                    LoadStatistics();
                    LoadUsers();
                    
                    // Clear form
                    ClearCreateForm();
                }
                else
                {
                    ShowMessage(result.ErrorMessage, "danger");
                    litShowModalScript.Text = "showCreateModal();";
                }
            }
            catch (Exception ex)
            {
                adminSecurity.LogError(GetCurrentUserId(), $"Error creating user: {ex.Message}");
                ShowMessage("Error al crear el usuario: " + ex.Message, "danger");
                litShowModalScript.Text = "showCreateModal();";
            }
        }

        private void ClearCreateForm()
        {
            txtCreateUsername.Text = string.Empty;
            txtCreateEmail.Text = string.Empty;
            txtCreateFirstName.Text = string.Empty;
            txtCreateLastName.Text = string.Empty;
            txtCreatePassword.Text = string.Empty;
            txtCreateConfirmPassword.Text = string.Empty;
            ddlCreateUserRole.SelectedIndex = 0;
            chkCreateIsActive.Checked = true;
        }

        private void ClearEditForm()
        {
            hfEditUserId.Value = string.Empty;
            txtEditUsername.Text = string.Empty;
            txtEditEmail.Text = string.Empty;
            txtEditFirstName.Text = string.Empty;
            txtEditLastName.Text = string.Empty;
            ddlEditUserRole.SelectedIndex = 0;
            chkEditIsActive.Checked = true;
        }

        private void ShowMessage(string message, string type)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = $"alert alert-{type} alert-dismissible fade show";
            lblMessage.Attributes["role"] = "alert";
        }

        private int? GetCurrentUserId()
        {
            try
            {
                if (Session["UserId"] != null)
                {
                    return Convert.ToInt32(Session["UserId"]);
                }
                return null;
            }
            catch
            {
                return null;
            }
        }

        #endregion
    }
}
