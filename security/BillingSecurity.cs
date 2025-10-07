using System;
using System.Collections.Generic;
using System.Linq;
using ABSTRACTIONS;
using BLL;
using SERVICES;

namespace SECURITY
{
    public class BillingSecurity
    {
        private readonly BillingBLL _billingBll;
        private readonly AdminSecurity _adminSecurity;
        private readonly UserSecurity _userSecurity;
        private readonly LogBLL _logBll;
        private readonly UserBLL _userBll;
        private readonly ProductBLL _productBll;

        public BillingSecurity()
        {
            _billingBll = new BillingBLL();
            _adminSecurity = new AdminSecurity();
            _userSecurity = new UserSecurity();
            _logBll = new LogBLL();
            _userBll = new UserBLL();
            _productBll = new ProductBLL();
        }

        public BillingDocumentListResult SearchDocuments(BillingDocumentSearchCriteria criteria)
        {
            if (!EnsureAdminAccess(out _))
            {
                return BillingDocumentListResult.Failure("Access denied. Admin privileges are required.");
            }

            return _billingBll.SearchDocuments(criteria ?? new BillingDocumentSearchCriteria());
        }

        public BillingDocumentResult GetDocumentById(int billingDocumentId)
        {
            if (!EnsureAdminAccess(out _))
            {
                return BillingDocumentResult.Failure("Access denied. Admin privileges are required.");
            }

            return _billingBll.GetDocumentById(billingDocumentId);
        }

        public BillingDocumentResult CreateDocument(BillingDocument document)
        {
            if (!EnsureAdminAccess(out var currentUserId))
            {
                return BillingDocumentResult.Failure("Access denied. Admin privileges are required.");
            }

            try
            {
                var result = _billingBll.CreateDocument(document, currentUserId.Value);
                LogBillingResult(result, LogService.LogTypes.CREATE, currentUserId, "Billing document created");
                return result;
            }
            catch (Exception ex)
            {
                LogError($"Security error creating billing document: {ex.Message}", currentUserId);
                return BillingDocumentResult.Failure("An unexpected error occurred while creating the billing document.");
            }
        }

        public DatabaseResult UpdateStatus(int billingDocumentId, string newStatus)
        {
            if (!EnsureAdminAccess(out var currentUserId))
            {
                return DatabaseResult.Failure(-1, "Access denied. Admin privileges are required.");
            }

            var result = _billingBll.UpdateStatus(billingDocumentId, newStatus, currentUserId.Value);
            if (result.IsSuccessful)
            {
                LogAction(LogService.LogTypes.UPDATE, $"Billing document status updated (ID {billingDocumentId} -> {newStatus})", currentUserId);
            }
            else
            {
                LogError($"Failed to update billing document status (ID {billingDocumentId}): {result.ErrorMessage}", currentUserId);
            }

            return result;
        }

        public DatabaseResult DeleteDocument(int billingDocumentId)
        {
            if (!EnsureAdminAccess(out var currentUserId))
            {
                return DatabaseResult.Failure(-1, "Access denied. Admin privileges are required.");
            }

            var result = _billingBll.Delete(billingDocumentId);
            if (result.IsSuccessful)
            {
                LogAction(LogService.LogTypes.DELETE, $"Billing document deleted (ID {billingDocumentId})", currentUserId);
            }
            else
            {
                LogError($"Failed to delete billing document (ID {billingDocumentId}): {result.ErrorMessage}", currentUserId);
            }

            return result;
        }

        public BillingStatisticsResult GetBillingStatistics(int? year, int maxMonths, string sortDirection)
        {
            if (!EnsureAdminAccess(out var currentUserId))
            {
                return BillingStatisticsResult.Failure("Access denied. Admin privileges are required.");
            }

            try
            {
                return _billingBll.GetBillingStatistics(year, maxMonths, sortDirection);
            }
            catch (Exception ex)
            {
                LogError($"Security error retrieving billing statistics: {ex.Message}", currentUserId);
                return BillingStatisticsResult.Failure("An unexpected error occurred while retrieving billing statistics.");
            }
        }

        public DatabaseResult AddItem(int billingDocumentId, BillingDocumentItem item)
        {
            if (!EnsureAdminAccess(out var currentUserId))
            {
                return DatabaseResult.Failure(-1, "Access denied. Admin privileges are required.");
            }

            var result = _billingBll.AddItem(billingDocumentId, item, currentUserId.Value);
            if (result.IsSuccessful)
            {
                LogAction(LogService.LogTypes.UPDATE, $"Billing document item added (Document {billingDocumentId})", currentUserId);
            }
            else
            {
                LogError($"Failed to add billing document item (Document {billingDocumentId}): {result.ErrorMessage}", currentUserId);
            }

            return result;
        }

        public DatabaseResult RemoveItem(int billingDocumentItemId)
        {
            if (!EnsureAdminAccess(out var currentUserId))
            {
                return DatabaseResult.Failure(-1, "Access denied. Admin privileges are required.");
            }

            var result = _billingBll.RemoveItem(billingDocumentItemId, currentUserId.Value);
            if (result.IsSuccessful)
            {
                LogAction(LogService.LogTypes.DELETE, $"Billing document item removed (Item {billingDocumentItemId})", currentUserId);
            }
            else
            {
                LogError($"Failed to remove billing document item (Item {billingDocumentItemId}): {result.ErrorMessage}", currentUserId);
            }

            return result;
        }

        public List<User> GetAssignableUsers()
        {
            if (!EnsureAdminAccess(out _))
            {
                return new List<User>();
            }

            return _userBll.GetAllUsers()?.Where(u => u.IsActive).OrderBy(u => u.FirstName).ThenBy(u => u.LastName).ToList()
                   ?? new List<User>();
        }

        public List<Product> GetActiveProducts()
        {
            if (!EnsureAdminAccess(out _))
            {
                return new List<Product>();
            }

            return _productBll.GetActiveProducts()?.Where(p => p.IsActive).OrderBy(p => p.Name, StringComparer.CurrentCultureIgnoreCase).ToList()
                   ?? new List<Product>();
        }

        private bool EnsureAdminAccess(out int? currentUserId)
        {
            currentUserId = GetCurrentUserId();
            if (!currentUserId.HasValue)
            {
                return false;
            }

            return _adminSecurity.IsUserAdmin();
        }

        private int? GetCurrentUserId()
        {
            var user = _userSecurity.GetCurrentUser();
            return user?.UserId;
        }

        private void LogBillingResult(BillingDocumentResult result, string logType, int? userId, string actionDescription)
        {
            if (result == null)
            {
                return;
            }

            if (result.IsSuccessful)
            {
                LogAction(logType, actionDescription, userId);
            }
            else
            {
                LogError($"{actionDescription} failed: {result.ErrorMessage}", userId);
            }
        }

        private void LogAction(string logType, string description, int? userId)
        {
            _logBll.CreateLog(new Log
            {
                LogType = logType,
                UserId = userId,
                Description = description,
                CreatedAt = DateTime.Now
            });
        }

        private void LogError(string message, int? userId)
        {
            _logBll.CreateLog(new Log
            {
                LogType = LogService.LogTypes.ERROR,
                UserId = userId,
                Description = message,
                CreatedAt = DateTime.Now
            });
        }
    }
}
