using System;

namespace ABSTRACTIONS
{
    /// <summary>
    /// Represents the result of a database operation with detailed error information
    /// </summary>
    public class DatabaseResult
    {
        public bool IsSuccessful { get; set; }
        public int ResultCode { get; set; }
        public string ErrorMessage { get; set; }
        public Exception Exception { get; set; }

        public DatabaseResult()
        {
            IsSuccessful = false;
            ResultCode = 0;
            ErrorMessage = string.Empty;
        }

        public DatabaseResult(bool isSuccessful, int resultCode = 0, string errorMessage = "")
        {
            IsSuccessful = isSuccessful;
            ResultCode = resultCode;
            ErrorMessage = errorMessage ?? string.Empty;
        }

        public static DatabaseResult Success()
        {
            return new DatabaseResult(true, 1, "Success");
        }

        public static DatabaseResult Success(string message)
        {
            return new DatabaseResult(true, 1, message);
        }

        public static DatabaseResult Failure(int resultCode, string errorMessage)
        {
            return new DatabaseResult(false, resultCode, errorMessage);
        }

        public static DatabaseResult Failure(string errorMessage, Exception exception = null)
        {
            return new DatabaseResult(false, -999, errorMessage) { Exception = exception };
        }
    }

    /// <summary>
    /// Represents the result of a database operation that returns data
    /// </summary>
    /// <typeparam name="T">Type of data returned</typeparam>
    public class DatabaseResult<T> : DatabaseResult
    {
        public T Data { get; set; }

        public DatabaseResult() : base()
        {
            Data = default(T);
        }

        public DatabaseResult(bool isSuccessful, T data, int resultCode = 0, string errorMessage = "") : base(isSuccessful, resultCode, errorMessage)
        {
            Data = data;
        }

        public static DatabaseResult<T> Success(T data)
        {
            return new DatabaseResult<T>(true, data, 1, "Success");
        }

        public static DatabaseResult<T> Success(T data, string message)
        {
            return new DatabaseResult<T>(true, data, 1, message);
        }

        public static new DatabaseResult<T> Failure(int resultCode, string errorMessage)
        {
            return new DatabaseResult<T>(false, default(T), resultCode, errorMessage);
        }

        public static new DatabaseResult<T> Failure(string errorMessage, Exception exception = null)
        {
            return new DatabaseResult<T>(false, default(T), -999, errorMessage) { Exception = exception };
        }
    }

    /// <summary>
    /// Represents the result of a user existence check
    /// </summary>
    public class UserExistenceResult : DatabaseResult
    {
        public bool UserExists { get; set; }
        public string ConflictType { get; set; } // "Username", "Email", or "Both"

        public UserExistenceResult() : base()
        {
            UserExists = false;
            ConflictType = string.Empty;
        }

        public UserExistenceResult(bool isSuccessful, bool userExists, string conflictType = "", string message = "") 
            : base(isSuccessful, userExists ? 1 : 0, message)
        {
            UserExists = userExists;
            ConflictType = conflictType ?? string.Empty;
        }
    }

    /// <summary>
    /// Represents the result of creating a password recovery request
    /// </summary>
    public class PasswordRecoveryCreateResult : DatabaseResult
    {
        public Guid RecoveryToken { get; set; }

        public PasswordRecoveryCreateResult() : base()
        {
            RecoveryToken = Guid.Empty;
        }

        public PasswordRecoveryCreateResult(bool isSuccessful, Guid recoveryToken, int resultCode = 0, string message = "") 
            : base(isSuccessful, resultCode, message)
        {
            RecoveryToken = recoveryToken;
        }

        public static PasswordRecoveryCreateResult Success(Guid recoveryToken, string message)
        {
            return new PasswordRecoveryCreateResult(true, recoveryToken, 1, message);
        }

        public static new PasswordRecoveryCreateResult Failure(int resultCode, string errorMessage)
        {
            return new PasswordRecoveryCreateResult(false, Guid.Empty, resultCode, errorMessage);
        }
    }

    /// <summary>
    /// Represents the result of validating a password recovery token
    /// </summary>
    public class PasswordRecoveryValidationResult : DatabaseResult
    {
        public int UserId { get; set; }
        public bool IsTokenValid { get; set; }
        public bool IsExpired { get; set; }
        public bool IsUsed { get; set; }

        public PasswordRecoveryValidationResult() : base()
        {
            UserId = 0;
            IsTokenValid = false;
            IsExpired = false;
            IsUsed = false;
        }

        public PasswordRecoveryValidationResult(bool isSuccessful, int userId, bool isTokenValid, bool isExpired, bool isUsed, int resultCode = 0, string message = "") 
            : base(isSuccessful, resultCode, message)
        {
            UserId = userId;
            IsTokenValid = isTokenValid;
            IsExpired = isExpired;
            IsUsed = isUsed;
        }

        public static PasswordRecoveryValidationResult Success(int userId, string message)
        {
            return new PasswordRecoveryValidationResult(true, userId, true, false, false, 1, message);
        }

        public static PasswordRecoveryValidationResult Invalid(int resultCode, string errorMessage, bool isExpired = false, bool isUsed = false)
        {
            return new PasswordRecoveryValidationResult(true, 0, false, isExpired, isUsed, resultCode, errorMessage);
        }

        public static new PasswordRecoveryValidationResult Failure(int resultCode, string errorMessage)
        {
            return new PasswordRecoveryValidationResult(false, 0, false, false, false, resultCode, errorMessage);
        }
    }

    /// <summary>
    /// Filter criteria for log queries
    /// Used across multiple layers to maintain consistency
    /// </summary>
    public class LogFilterCriteria
    {
        public string LogType { get; set; }
        public int? UserId { get; set; }
        public string Description { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
    }
}