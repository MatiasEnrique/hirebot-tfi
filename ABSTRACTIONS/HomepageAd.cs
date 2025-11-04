using System;

namespace ABSTRACTIONS
{
    /// <summary>
    /// Represents a homepage advertisement entity
    /// </summary>
    [Serializable]
    public class HomepageAd
    {
        public int AdId { get; set; }
        public string BadgeText { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string CtaText { get; set; }
        public string TargetUrl { get; set; }
        public bool IsActive { get; set; }
        public bool IsSelected { get; set; }
        public DateTime CreatedDateUtc { get; set; }
        public DateTime? ModifiedDateUtc { get; set; }
        public int? CreatedByUserId { get; set; }
        public int? ModifiedByUserId { get; set; }

        public HomepageAd()
        {
            IsActive = true;
            IsSelected = false;
        }
    }
}
