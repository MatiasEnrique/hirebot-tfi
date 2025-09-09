using System;

namespace ABSTRACTIONS
{
    public class User
    {
        public int UserId { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public string PasswordHash { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime? LastLoginDate { get; set; }
        public bool IsActive { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string UserRole { get; set; }

        public User()
        {
            CreatedDate = DateTime.Now;
            IsActive = true;
            UserRole = "user";
        }
    }
}