using System;

namespace ABSTRACTIONS
{
    [Serializable]
    public class AdminRole
    {
        public int RoleId { get; set; }
        public string RoleName { get; set; }
        public string Description { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedDateUtc { get; set; }
        public DateTime? ModifiedDateUtc { get; set; }
        public int? CreatedByUserId { get; set; }
        public int? ModifiedByUserId { get; set; }

        public AdminRole()
        {
            IsActive = true;
        }
    }

    [Serializable]
    public class AdminRoleSummary : AdminRole
    {
        public int AssignedUserCount { get; set; }
        public int PermissionCount { get; set; }
    }
}
