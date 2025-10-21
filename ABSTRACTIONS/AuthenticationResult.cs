namespace ABSTRACTIONS
{
    public class AuthenticationResult
    {
        public bool IsSuccessful { get; set; }
        public string ErrorMessage { get; set; }
        public string Message { get; set; }
        public User User { get; set; }

        public AuthenticationResult()
        {
            IsSuccessful = false;
            ErrorMessage = "";
            Message = "";
        }

        public AuthenticationResult(bool isSuccessful, string message = "")
        {
            IsSuccessful = isSuccessful;
            Message = message;
            ErrorMessage = isSuccessful ? "" : message;
        }
    }
}