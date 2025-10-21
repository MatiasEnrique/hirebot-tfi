using System;
using System.Configuration;
using System.Security.Cryptography;
using System.Text;

namespace SERVICES
{
    public class EncryptionService
    {
        public static string EncryptPassword(string password)
        {
            using (SHA256 sha256Hash = SHA256.Create())
            {
                byte[] bytes = sha256Hash.ComputeHash(Encoding.UTF8.GetBytes(password));
                StringBuilder builder = new StringBuilder();
                for (int i = 0; i < bytes.Length; i++)
                {
                    builder.Append(bytes[i].ToString("x2"));
                }
                return builder.ToString();
            }
        }

        public static bool VerifyPassword(string password, string hashedPassword)
        {
            return EncryptPassword(password) == hashedPassword;
        }

        public static string EncryptSymmetric(string plainText)
        {
            if (string.IsNullOrEmpty(plainText))
            {
                return string.Empty;
            }

            byte[] key = GetSymmetricKey();

            using (Aes aes = Aes.Create())
            {
                aes.Key = key;
                aes.Mode = CipherMode.CBC;
                aes.Padding = PaddingMode.PKCS7;
                aes.GenerateIV();

                using (ICryptoTransform encryptor = aes.CreateEncryptor())
                {
                    byte[] plainBytes = Encoding.UTF8.GetBytes(plainText);
                    byte[] cipherBytes = encryptor.TransformFinalBlock(plainBytes, 0, plainBytes.Length);

                    byte[] combined = new byte[aes.IV.Length + cipherBytes.Length];
                    Buffer.BlockCopy(aes.IV, 0, combined, 0, aes.IV.Length);
                    Buffer.BlockCopy(cipherBytes, 0, combined, aes.IV.Length, cipherBytes.Length);

                    return Convert.ToBase64String(combined);
                }
            }
        }

        public static string DecryptSymmetric(string cipherText)
        {
            if (string.IsNullOrEmpty(cipherText))
            {
                return string.Empty;
            }

            byte[] key = GetSymmetricKey();
            byte[] combined = Convert.FromBase64String(cipherText);

            using (Aes aes = Aes.Create())
            {
                aes.Key = key;
                aes.Mode = CipherMode.CBC;
                aes.Padding = PaddingMode.PKCS7;

                byte[] iv = new byte[aes.BlockSize / 8];
                byte[] cipherBytes = new byte[combined.Length - iv.Length];

                Buffer.BlockCopy(combined, 0, iv, 0, iv.Length);
                Buffer.BlockCopy(combined, iv.Length, cipherBytes, 0, cipherBytes.Length);

                aes.IV = iv;

                using (ICryptoTransform decryptor = aes.CreateDecryptor())
                {
                    byte[] plainBytes = decryptor.TransformFinalBlock(cipherBytes, 0, cipherBytes.Length);
                    return Encoding.UTF8.GetString(plainBytes);
                }
            }
        }

        public static string EncryptAsymmetric(string plainText)
        {
            if (string.IsNullOrEmpty(plainText))
            {
                return string.Empty;
            }

            using (var rsa = new RSACryptoServiceProvider())
            {
                rsa.PersistKeyInCsp = false;
                rsa.ImportCspBlob(GetRsaPublicKey());

                byte[] plainBytes = Encoding.UTF8.GetBytes(plainText);
                byte[] cipherBytes = rsa.Encrypt(plainBytes, true);
                return Convert.ToBase64String(cipherBytes);
            }
        }

        public static string DecryptAsymmetric(string cipherText)
        {
            if (string.IsNullOrEmpty(cipherText))
            {
                return string.Empty;
            }

            using (var rsa = new RSACryptoServiceProvider())
            {
                rsa.PersistKeyInCsp = false;
                rsa.ImportCspBlob(GetRsaPrivateKey());

                byte[] cipherBytes = Convert.FromBase64String(cipherText);
                byte[] plainBytes = rsa.Decrypt(cipherBytes, true);
                return Encoding.UTF8.GetString(plainBytes);
            }
        }

        private static byte[] GetSymmetricKey()
        {
            string keyBase64 = ConfigurationManager.AppSettings["Encryption.SymmetricKey"];
            if (string.IsNullOrWhiteSpace(keyBase64))
            {
                throw new InvalidOperationException("Symmetric encryption key is not configured.");
            }

            byte[] key = Convert.FromBase64String(keyBase64);
            if (key.Length != 32)
            {
                throw new InvalidOperationException("Symmetric encryption key must be 32 bytes (256 bits).");
            }

            return key;
        }

        private static byte[] GetRsaPublicKey()
        {
            string publicKeyBase64 = ConfigurationManager.AppSettings["Encryption.RsaPublicKey"];
            if (string.IsNullOrWhiteSpace(publicKeyBase64))
            {
                throw new InvalidOperationException("RSA public key is not configured.");
            }

            return Convert.FromBase64String(publicKeyBase64);
        }

        private static byte[] GetRsaPrivateKey()
        {
            string privateKeyBase64 = ConfigurationManager.AppSettings["Encryption.RsaPrivateKey"];
            if (string.IsNullOrWhiteSpace(privateKeyBase64))
            {
                throw new InvalidOperationException("RSA private key is not configured.");
            }

            return Convert.FromBase64String(privateKeyBase64);
        }
    }
}
