using System;
using System.Collections.Generic;

namespace ABSTRACTIONS
{
    [Serializable]
    public class AdminRoleDetail
    {
        public AdminRole Role { get; set; }
        public List<string> PermissionKeys { get; set; }
        public List<AdminUserRoleAssignment> AssignedUsers { get; set; }

        public AdminRoleDetail()
        {
            Role = new AdminRole();
            PermissionKeys = new List<string>();
            AssignedUsers = new List<AdminUserRoleAssignment>();
        }
    }
}
