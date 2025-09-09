<%@ Page Title="Organization Dashboard - Hirebot-TFI" Language="C#" MasterPageFile="~/Protected.master" AutoEventWireup="true" CodeBehind="OrganizationDashboard.aspx.cs" Inherits="Hirebot_TFI.OrganizationDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,OrganizationDashboard %>" /> - Hirebot-TFI
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .organization-header {
            background: linear-gradient(135deg, var(--ultra-violet), var(--tiffany-blue));
            color: white;
            border-radius: 15px;
            padding: 2rem;
            margin-bottom: 2rem;
        }
        
        .organization-stats {
            display: flex;
            gap: 2rem;
            margin-top: 1.5rem;
            flex-wrap: wrap;
        }
        
        .stat-card {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            padding: 1rem;
            text-align: center;
            flex: 1;
            min-width: 150px;
        }
        
        .stat-number {
            font-size: 2rem;
            font-weight: bold;
            display: block;
            margin-bottom: 0.5rem;
        }
        
        .stat-label {
            font-size: 0.9rem;
            opacity: 0.9;
        }
        
        .member-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            overflow: hidden;
        }
        
        .member-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 0.5rem 2rem 0 rgba(58, 59, 69, 0.25);
        }
        
        .member-avatar {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--ultra-violet), var(--tiffany-blue));
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 1.2rem;
        }
        
        .role-badge {
            font-size: 0.75rem;
            padding: 0.25rem 0.5rem;
        }
        
        .role-owner {
            background: linear-gradient(135deg, #ffd700, #ffed4e);
            color: #b8860b;
        }
        
        .role-admin {
            background: linear-gradient(135deg, var(--ultra-violet), var(--tiffany-blue));
            color: white;
        }
        
        .role-member {
            background: linear-gradient(135deg, var(--cadet-gray), #adb5bd);
            color: white;
        }
        
        .action-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            text-decoration: none;
            color: inherit;
            display: block;
        }
        
        .action-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 0.5rem 2rem 0 rgba(58, 59, 69, 0.25);
            text-decoration: none;
            color: inherit;
        }
        
        .action-icon {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            color: white;
            margin: 0 auto 1rem;
        }
        
        .icon-members { background: linear-gradient(135deg, var(--ultra-violet), var(--tiffany-blue)); }
        .icon-settings { background: linear-gradient(135deg, var(--cadet-gray), var(--ultra-violet)); }
        .icon-stats { background: linear-gradient(135deg, var(--tiffany-blue), var(--cadet-gray)); }
        
        .section-header {
            border-bottom: 2px solid var(--ultra-violet);
            padding-bottom: 0.5rem;
            margin-bottom: 1.5rem;
        }
        
        .recent-activity {
            max-height: 400px;
            overflow-y: auto;
        }
        
        .activity-item {
            border-left: 3px solid var(--tiffany-blue);
            padding: 1rem;
            margin-bottom: 1rem;
            background: #f8f9fa;
            border-radius: 0 8px 8px 0;
        }
        
        .activity-time {
            font-size: 0.85rem;
            color: var(--cadet-gray);
        }
        
        @media (max-width: 768px) {
            .organization-stats {
                flex-direction: column;
                gap: 1rem;
            }
            
            .stat-card {
                min-width: auto;
            }
            
            .organization-header {
                padding: 1.5rem;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="NavigationContent" runat="server">
    <li class="nav-item">
        <a class="nav-link" href="MyOrganizations.aspx">
            <i class="fas fa-building me-1"></i>
            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,MyOrganizations %>" />
        </a>
    </li>
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePartialRendering="true" />
    
    <div class="content-card">
        <asp:UpdatePanel ID="upMain" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <!-- Alert Messages -->
                <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert" role="alert">
                    <asp:Label ID="lblAlert" runat="server"></asp:Label>
                </asp:Panel>

                <!-- Organization Header -->
                <div class="organization-header">
                    <div class="row align-items-center">
                        <div class="col-md-8">
                            <h1 class="mb-2">
                                <i class="fas fa-building me-3"></i>
                                <asp:Label ID="lblOrganizationName" runat="server" />
                            </h1>
                            <p class="mb-0 fs-5">
                                <asp:Label ID="lblOrganizationDescription" runat="server" />
                            </p>
                            <small class="opacity-75">
                                <i class="fas fa-link me-1"></i>
                                <asp:Label ID="lblOrganizationSlug" runat="server" />
                            </small>
                        </div>
                        <div class="col-md-4 text-md-end mt-3 mt-md-0">
                            <span class="badge role-owner fs-6 me-2" id="badgeOwner" runat="server" visible="false">
                                <i class="fas fa-crown me-1"></i>
                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Owner %>" />
                            </span>
                            <span class="badge role-admin fs-6" id="badgeAdmin" runat="server" visible="false">
                                <i class="fas fa-user-shield me-1"></i>
                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Admin %>" />
                            </span>
                        </div>
                    </div>
                    
                    <!-- Organization Statistics -->
                    <div class="organization-stats">
                        <div class="stat-card">
                            <span class="stat-number">
                                <asp:Label ID="lblTotalMembers" runat="server">0</asp:Label>
                            </span>
                            <span class="stat-label">
                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,TotalMembers %>" />
                            </span>
                        </div>
                        <div class="stat-card">
                            <span class="stat-number">
                                <asp:Label ID="lblAdminCount" runat="server">0</asp:Label>
                            </span>
                            <span class="stat-label">
                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Administrators %>" />
                            </span>
                        </div>
                        <div class="stat-card">
                            <span class="stat-number">
                                <asp:Label ID="lblCreatedDate" runat="server" />
                            </span>
                            <span class="stat-label">
                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Established %>" />
                            </span>
                        </div>
                        <div class="stat-card">
                            <span class="stat-number">
                                <i class="fas fa-circle text-success" id="statusIcon" runat="server"></i>
                            </span>
                            <span class="stat-label">
                                <asp:Label ID="lblStatus" runat="server" />
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Quick Actions Row -->
                <div class="row g-4 mb-4">
                    <div class="col-md-4">
                        <a href="javascript:void(0);" class="action-card p-4 h-100 text-center" onclick="showMembersSection();">
                            <div class="action-icon icon-members">
                                <i class="fas fa-users"></i>
                            </div>
                            <h5 class="mb-3">
                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ManageMembers %>" />
                            </h5>
                            <p class="text-muted mb-0">
                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ManageMembersDescription %>" />
                            </p>
                        </a>
                    </div>
                    <div class="col-md-4" id="settingsCard" runat="server">
                        <a href="javascript:void(0);" class="action-card p-4 h-100 text-center" onclick="showSettingsModal();">
                            <div class="action-icon icon-settings">
                                <i class="fas fa-cog"></i>
                            </div>
                            <h5 class="mb-3">
                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,OrganizationSettings %>" />
                            </h5>
                            <p class="text-muted mb-0">
                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,UpdateOrgDetails %>" />
                            </p>
                        </a>
                    </div>
                    <div class="col-md-4">
                        <a href="javascript:void(0);" class="action-card p-4 h-100 text-center" onclick="showStatsSection();">
                            <div class="action-icon icon-stats">
                                <i class="fas fa-chart-bar"></i>
                            </div>
                            <h5 class="mb-3">
                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ViewStatistics %>" />
                            </h5>
                            <p class="text-muted mb-0">
                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,DetailedAnalytics %>" />
                            </p>
                        </a>
                    </div>
                </div>

                <!-- Members Section -->
                <div class="row" id="membersSection">
                    <div class="col-12">
                        <div class="d-flex justify-content-between align-items-center section-header">
                            <h3>
                                <i class="fas fa-users me-2"></i>
                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,OrganizationMembers %>" />
                            </h3>
                            <div id="memberActions" runat="server">
                                <button type="button" class="btn btn-success" onclick="showAddMemberModal();">
                                    <i class="fas fa-user-plus me-1"></i>
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AddMember %>" />
                                </button>
                            </div>
                        </div>
                        
                        <asp:Repeater ID="rptMembers" runat="server" OnItemCommand="rptMembers_ItemCommand">
                            <HeaderTemplate>
                                <div class="row g-3">
                            </HeaderTemplate>
                            <ItemTemplate>
                                <div class="col-md-6 col-lg-4">
                                    <div class="member-card">
                                        <div class="card-body p-3">
                                            <div class="d-flex align-items-center mb-3">
                                                <div class="member-avatar me-3">
                                                    <%# GetUserInitials(Eval("Username")?.ToString()) %>
                                                </div>
                                                <div class="flex-grow-1">
                                                    <h6 class="mb-1"><%# Eval("FirstName") %> <%# Eval("LastName") %></h6>
                                                    <small class="text-muted">@<%# Eval("Username") %></small>
                                                </div>
                                                <span class="badge role-<%# Eval("Role")?.ToString().ToLower().Replace("_", "-") %> role-badge">
                                                    <%# GetRoleDisplayName(Eval("Role")?.ToString()) %>
                                                </span>
                                            </div>
                                            
                                            <div class="text-muted small mb-2">
                                                <i class="fas fa-calendar me-1"></i>
                                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,JoinedOn %>" />: 
                                                <%# ((DateTime)Eval("JoinDate")).ToString("MMM dd, yyyy") %>
                                            </div>
                                            
                                            <div class="d-flex gap-1" id="memberActionButtons" runat="server" 
                                                 visible='<%# CanManageMember(Eval("Role")?.ToString(), Eval("UserId")) %>'>
                                                <asp:DropDownList ID="ddlMemberRole" runat="server" CssClass="form-select form-select-sm flex-grow-1"
                                                    Visible='<%# CanUpdateRole(Eval("Role")?.ToString()) %>'>
                                                    <asp:ListItem Value="member" Text="<%$ Resources:GlobalResources,Member %>" />
                                                    <asp:ListItem Value="organization_admin" Text="<%$ Resources:GlobalResources,OrganizationAdmin %>" />
                                                </asp:DropDownList>
                                                <asp:LinkButton ID="btnUpdateRole" runat="server" CssClass="btn btn-outline-primary btn-sm"
                                                    CommandName="UpdateRole" CommandArgument='<%# Eval("UserId") %>'
                                                    Visible='<%# CanUpdateRole(Eval("Role")?.ToString()) %>'>
                                                    <i class="fas fa-sync"></i>
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnRemoveMember" runat="server" CssClass="btn btn-outline-danger btn-sm"
                                                    CommandName="RemoveMember" CommandArgument='<%# Eval("UserId") %>'
                                                    OnClientClick='<%# "return confirm(\u0027" + HttpContext.GetGlobalResourceObject("GlobalResources", "ConfirmRemoveMember") + "\u0027);" %>'
                                                    Visible='<%# CanRemoveMember(Eval("Role")?.ToString()) %>'>
                                                    <i class="fas fa-user-minus"></i>
                                                </asp:LinkButton>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                            <FooterTemplate>
                                </div>
                            </FooterTemplate>
                        </asp:Repeater>
                        
                        <!-- No Members Message -->
                        <asp:Panel ID="pnlNoMembers" runat="server" Visible="false" CssClass="text-center py-4">
                            <div class="mb-3">
                                <i class="fas fa-users display-4 text-muted"></i>
                            </div>
                            <h5 class="text-muted mb-3">
                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,NoMembers %>" />
                            </h5>
                            <p class="text-muted">
                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AddFirstMember %>" />
                            </p>
                        </asp:Panel>
                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>

    <!-- Add Member Modal -->
    <div class="modal fade" id="addMemberModal" tabindex="-1" aria-labelledby="addMemberModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <asp:UpdatePanel ID="upAddMember" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <div class="modal-header">
                            <h5 class="modal-title" id="addMemberModalLabel">
                                <i class="fas fa-user-plus me-2"></i>
                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AddMember %>" />
                            </h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <div class="mb-3">
                                <label for="ddlAddUser" class="form-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SelectUser %>" /> *
                                </label>
                                <asp:DropDownList ID="ddlAddUser" runat="server" CssClass="form-select" />
                                <asp:RequiredFieldValidator ID="rfvAddUser" runat="server" ControlToValidate="ddlAddUser" 
                                    InitialValue="" ErrorMessage="<%$ Resources:GlobalResources,UserRequired %>" 
                                    CssClass="text-danger small" Display="Dynamic" ValidationGroup="AddMember" />
                            </div>
                            <div class="mb-3">
                                <label for="ddlAddRole" class="form-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Role %>" /> *
                                </label>
                                <asp:DropDownList ID="ddlAddRole" runat="server" CssClass="form-select">
                                    <asp:ListItem Value="" Text="<%$ Resources:GlobalResources,SelectRole %>" />
                                    <asp:ListItem Value="member" Text="<%$ Resources:GlobalResources,Member %>" />
                                    <asp:ListItem Value="organization_admin" Text="<%$ Resources:GlobalResources,OrganizationAdmin %>" />
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="rfvAddRole" runat="server" ControlToValidate="ddlAddRole" 
                                    InitialValue="" ErrorMessage="<%$ Resources:GlobalResources,RoleRequired %>" 
                                    CssClass="text-danger small" Display="Dynamic" ValidationGroup="AddMember" />
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Cancel %>" />
                            </button>
                            <asp:Button ID="btnAddMember" runat="server" CssClass="btn btn-success" 
                                Text="<%$ Resources:GlobalResources,AddMember %>" OnClick="btnAddMember_Click" 
                                ValidationGroup="AddMember" />
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>
    </div>

    <!-- Organization Settings Modal -->
    <div class="modal fade" id="settingsModal" tabindex="-1" aria-labelledby="settingsModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <asp:UpdatePanel ID="upSettings" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <div class="modal-header">
                            <h5 class="modal-title" id="settingsModalLabel">
                                <i class="fas fa-cog me-2"></i>
                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,OrganizationSettings %>" />
                            </h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <div class="row g-3">
                                <div class="col-md-8">
                                    <label for="txtSettingsName" class="form-label">
                                        <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,OrganizationName %>" /> *
                                    </label>
                                    <asp:TextBox ID="txtSettingsName" runat="server" CssClass="form-control" MaxLength="100" />
                                    <asp:RequiredFieldValidator ID="rfvSettingsName" runat="server" ControlToValidate="txtSettingsName" 
                                        ErrorMessage="<%$ Resources:GlobalResources,OrganizationNameRequired %>" 
                                        CssClass="text-danger small" Display="Dynamic" ValidationGroup="Settings" />
                                </div>
                                <div class="col-md-4">
                                    <label for="chkSettingsActive" class="form-label">
                                        <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Status %>" />
                                    </label>
                                    <div class="form-check form-switch">
                                        <asp:CheckBox ID="chkSettingsActive" runat="server" CssClass="form-check-input" />
                                        <label class="form-check-label" for="chkSettingsActive">
                                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Active %>" />
                                        </label>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="row g-3 mt-1">
                                <div class="col-md-6">
                                    <label for="txtSettingsSlug" class="form-label">
                                        <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,OrganizationSlug %>" /> *
                                    </label>
                                    <asp:TextBox ID="txtSettingsSlug" runat="server" CssClass="form-control" MaxLength="50" />
                                    <div class="form-text">
                                        <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SlugHelpText %>" />
                                    </div>
                                    <asp:RequiredFieldValidator ID="rfvSettingsSlug" runat="server" ControlToValidate="txtSettingsSlug" 
                                        ErrorMessage="<%$ Resources:GlobalResources,OrganizationSlugRequired %>" 
                                        CssClass="text-danger small" Display="Dynamic" ValidationGroup="Settings" />
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">
                                        <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Owner %>" />
                                    </label>
                                    <asp:TextBox ID="txtOwnerDisplay" runat="server" CssClass="form-control" ReadOnly="true" />
                                    <div class="form-text">
                                        <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,OwnerCannotBeChanged %>" />
                                    </div>
                                </div>
                            </div>
                            
                            <div class="mt-3">
                                <label for="txtSettingsDescription" class="form-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,OrganizationDescription %>" />
                                </label>
                                <asp:TextBox ID="txtSettingsDescription" runat="server" CssClass="form-control" 
                                    TextMode="MultiLine" Rows="4" MaxLength="500" />
                                <div class="form-text">
                                    <span id="settingsCharCount">0</span>/500 <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Characters %>" />
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Cancel %>" />
                            </button>
                            <asp:Button ID="btnSaveSettings" runat="server" CssClass="btn btn-primary" 
                                Text="<%$ Resources:GlobalResources,SaveChanges %>" OnClick="btnSaveSettings_Click" 
                                ValidationGroup="Settings" />
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content5" ContentPlaceHolderID="ScriptContent" runat="server">
    <script>
        // Page initialization
        document.addEventListener('DOMContentLoaded', function() {
            initializeCharacterCounters();
            initializeMemberRoleDropdowns();
        });
        
        // Character counter for settings description
        function initializeCharacterCounters() {
            const settingsDesc = document.getElementById('<%= txtSettingsDescription.ClientID %>');
            const settingsCount = document.getElementById('settingsCharCount');
            
            if (settingsDesc && settingsCount) {
                function updateSettingsCount() {
                    const count = settingsDesc.value.length;
                    settingsCount.textContent = count;
                    
                    if (count > 450) {
                        settingsCount.style.color = '#dc3545';
                    } else if (count > 400) {
                        settingsCount.style.color = '#fd7e14';
                    } else {
                        settingsCount.style.color = '#6c757d';
                    }
                }
                
                settingsDesc.addEventListener('input', updateSettingsCount);
                updateSettingsCount(); // Initial count
            }
        }
        
        // Initialize member role dropdowns
        function initializeMemberRoleDropdowns() {
            const memberCards = document.querySelectorAll('.member-card');
            memberCards.forEach(function(card) {
                const roleDropdown = card.querySelector('select[id*="ddlMemberRole"]');
                const roleBadge = card.querySelector('.role-badge');
                
                if (roleDropdown && roleBadge) {
                    // Set dropdown value based on current role
                    const currentRole = roleBadge.textContent.toLowerCase().trim();
                    if (currentRole.includes('admin') || currentRole.includes('administrador')) {
                        roleDropdown.value = 'organization_admin';
                    } else {
                        roleDropdown.value = 'member';
                    }
                }
            });
        }
        
        // Show sections
        function showMembersSection() {
            const membersSection = document.getElementById('membersSection');
            if (membersSection) {
                membersSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        }
        
        function showStatsSection() {
            const statsSection = document.querySelector('.organization-header');
            if (statsSection) {
                statsSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        }
        
        // Modal functions
        function showAddMemberModal() {
            const modal = new bootstrap.Modal(document.getElementById('addMemberModal'));
            modal.show();
        }
        
        function hideAddMemberModal() {
            const modal = bootstrap.Modal.getInstance(document.getElementById('addMemberModal'));
            if (modal) {
                modal.hide();
            }
        }
        
        function showSettingsModal() {
            const modal = new bootstrap.Modal(document.getElementById('settingsModal'));
            modal.show();
        }
        
        function hideSettingsModal() {
            const modal = bootstrap.Modal.getInstance(document.getElementById('settingsModal'));
            if (modal) {
                modal.hide();
            }
        }
        
        // UpdatePanel refresh handler
        function pageLoad(sender, args) {
            if (args.get_isPartialLoad()) {
                // Re-initialize components after partial postback
                initializeCharacterCounters();
                initializeMemberRoleDropdowns();
            }
        }
        
        // Add page load handler for partial postbacks
        if (typeof(Sys) !== 'undefined') {
            Sys.Application.add_load(pageLoad);
        }
        
        // Auto-hide alerts
        setTimeout(function() {
            const alerts = document.querySelectorAll('.alert-success');
            alerts.forEach(function(alert) {
                if (alert.style.display !== 'none') {
                    alert.style.display = 'none';
                }
            });
        }, 5000);
    </script>
</asp:Content>