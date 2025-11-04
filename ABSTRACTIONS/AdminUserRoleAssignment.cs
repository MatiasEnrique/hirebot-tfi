using System;

namespace ABSTRACTIONS
{
    [Serializable]
    public class AdminUserRoleAssignment
    {
        public int AdminUserRoleId { get; set; }
        public int UserId { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public DateTime AssignedDateUtc { get; set; }

        public string FullName => string.IsNullOrWhiteSpace(FirstName) && string.IsNullOrWhiteSpace(LastName)
            ? Username
            : string.Format("{0} {1}", FirstName, LastName).Trim();
    }
}
