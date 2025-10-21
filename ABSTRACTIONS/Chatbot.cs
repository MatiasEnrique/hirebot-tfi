using System;

namespace ABSTRACTIONS
{
    /// <summary>
    /// Represents a chatbot entity with organization assignment capabilities
    /// </summary>
    public class Chatbot
    {
        /// <summary>
        /// Unique identifier for the chatbot
        /// </summary>
        public int ChatbotId { get; set; }

        /// <summary>
        /// Organization ID that this chatbot is assigned to (null for unassigned/global chatbots)
        /// </summary>
        public int? OrganizationId { get; set; }

        /// <summary>
        /// Display name of the organization (for display purposes only)
        /// </summary>
        public string OrganizationName { get; set; }

        /// <summary>
        /// Name of the chatbot
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// Instructions that define the chatbot's behavior and responses
        /// </summary>
        public string Instructions { get; set; }

        /// <summary>
        /// Color theme for the chatbot in hex format (#RRGGBB)
        /// </summary>
        public string Color { get; set; }

        /// <summary>
        /// Date and time when the chatbot was created
        /// </summary>
        public DateTime CreatedDate { get; set; }

        /// <summary>
        /// Date and time when the chatbot was last updated
        /// </summary>
        public DateTime UpdatedDate { get; set; }

        /// <summary>
        /// Whether the chatbot is active or has been soft-deleted
        /// </summary>
        public bool IsActive { get; set; }

        /// <summary>
        /// Constructor with default values
        /// </summary>
        public Chatbot()
        {
            ChatbotId = 0;
            OrganizationId = null;
            OrganizationName = string.Empty;
            Name = string.Empty;
            Instructions = string.Empty;
            Color = "#222222"; // Default to Eerie Black from project color palette
            CreatedDate = DateTime.UtcNow;
            UpdatedDate = DateTime.UtcNow;
            IsActive = true;
        }

        /// <summary>
        /// Constructor with basic parameters
        /// </summary>
        /// <param name="name">Chatbot name</param>
        /// <param name="instructions">Chatbot instructions</param>
        /// <param name="color">Chatbot color in hex format</param>
        /// <param name="organizationId">Optional organization assignment</param>
        public Chatbot(string name, string instructions, string color, int? organizationId = null)
        {
            ChatbotId = 0;
            OrganizationId = organizationId;
            OrganizationName = string.Empty;
            Name = name ?? string.Empty;
            Instructions = instructions ?? string.Empty;
            Color = color ?? "#222222";
            CreatedDate = DateTime.UtcNow;
            UpdatedDate = DateTime.UtcNow;
            IsActive = true;
        }
    }
}