using System;

namespace ABSTRACTIONS
{
    public class Log
    {
        public int Id { get; set; }
        public string LogType { get; set; }
        public int? UserId { get; set; }
        public string Description { get; set; }
        public DateTime CreatedAt { get; set; }

        public Log()
        {
            CreatedAt = DateTime.Now;
        }

        public Log(string logType, int? userId, string description)
        {
            LogType = logType;
            UserId = userId;
            Description = description;
            CreatedAt = DateTime.Now;
        }
    }
}