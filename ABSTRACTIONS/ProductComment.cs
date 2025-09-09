using System;

namespace ABSTRACTIONS
{
    public class ProductComment
    {
        public int CommentId { get; set; }
        public int ProductId { get; set; }
        public int UserId { get; set; }
        public string CommentText { get; set; }
        public int Rating { get; set; } // 1-5 star rating
        public DateTime CreatedDate { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public bool IsActive { get; set; }
        public bool IsApproved { get; set; } // For moderation
        
        // Navigation properties for display purposes
        public string Username { get; set; }
        public string UserFullName { get; set; }
        public string ProductName { get; set; }

        public ProductComment()
        {
            CreatedDate = DateTime.Now;
            IsActive = true;
            IsApproved = false; // Comments need approval by default
            Rating = 0; // No rating by default
        }
    }
}