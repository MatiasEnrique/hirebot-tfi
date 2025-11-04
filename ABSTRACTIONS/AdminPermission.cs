using System;

namespace ABSTRACTIONS
{
    [Serializable]
    public class AdminPermission
    {
        public string PermissionKey { get; set; }
        public string DisplayName { get; set; }
        public string Category { get; set; }
        public int SortOrder { get; set; }
        public bool IsActive { get; set; }
        public bool IsAssigned { get; set; }

        public string NormalizedKey => string.IsNullOrWhiteSpace(PermissionKey)
            ? string.Empty
            : PermissionKey.Trim().ToLowerInvariant();
    }
}
