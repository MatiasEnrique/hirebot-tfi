using System;

namespace ABSTRACTIONS
{
    public class Product
    {
        public int ProductId { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public decimal Price { get; set; }
        public string BillingCycle { get; set; }
        public int MaxChatbots { get; set; }
        public int MaxMessagesPerMonth { get; set; }
        public string Features { get; set; }
        public string Category { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public int CreatedByUserId { get; set; }

        public Product()
        {
            CreatedDate = DateTime.Now;
            IsActive = true;
            BillingCycle = "Monthly";
            MaxChatbots = 1;
            MaxMessagesPerMonth = 1000;
        }
    }
}