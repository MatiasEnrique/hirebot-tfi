using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using ABSTRACTIONS;
using DAL;

namespace BLL
{
    public class BillingBLL
    {
        private readonly BillingDAL billingDal;

        public BillingBLL()
        {
            billingDal = new BillingDAL();
        }

        public BillingDocumentResult CreateDocument(BillingDocument document, int currentUserId)
        {
            if (document == null)
            {
                return BillingDocumentResult.Failure("Billing document payload cannot be null.");
            }

            if (currentUserId <= 0)
            {
                return BillingDocumentResult.Failure("A valid user must be provided to create billing documents.");
            }

            if (document.UserId <= 0)
            {
                return BillingDocumentResult.Failure("A target user must be specified for the billing document.");
            }

            document.CreatedBy = currentUserId;
            document.LastModifiedBy = currentUserId;

            if (string.IsNullOrWhiteSpace(document.DocumentType))
            {
                document.DocumentType = BillingDocumentTypes.Invoice;
            }

            if (!BillingDocumentTypes.Allowed.Contains(document.DocumentType))
            {
                return BillingDocumentResult.Failure("Unsupported billing document type.");
            }

            if (string.IsNullOrWhiteSpace(document.DocumentNumber))
            {
                document.DocumentNumber = GenerateDocumentNumber(document.DocumentType);
            }

            document.CurrencyCode = string.IsNullOrWhiteSpace(document.CurrencyCode)
                ? (RegionInfo.CurrentRegion?.ISOCurrencySymbol ?? "ARS")
                : document.CurrencyCode.Trim().ToUpperInvariant();

            document.Items = document.Items ?? new List<BillingDocumentItem>();
            CalculateDocumentTotals(document);

            var validation = document.Validate();
            if (!validation.IsValid)
            {
                return BillingDocumentResult.Failure(string.Join("; ", validation.Errors));
            }

            var dalResult = billingDal.Create(document);
            if (dalResult.IsSuccessful)
            {
                return BillingDocumentResult.Success(dalResult.Data, dalResult.ErrorMessage);
            }

            return BillingDocumentResult.Failure(dalResult.ErrorMessage ?? "Failed to create billing document.", dalResult.Exception);
        }

        public BillingDocumentResult GetDocumentById(int billingDocumentId)
        {
            if (billingDocumentId <= 0)
            {
                return BillingDocumentResult.Failure("Billing document identifier is required.");
            }

            var dalResult = billingDal.GetById(billingDocumentId);
            if (dalResult.IsSuccessful)
            {
                return BillingDocumentResult.Success(dalResult.Data, dalResult.ErrorMessage);
            }

            return BillingDocumentResult.Failure(dalResult.ErrorMessage ?? "Billing document not found.", dalResult.Exception);
        }

        public BillingDocumentListResult SearchDocuments(BillingDocumentSearchCriteria criteria)
        {
            criteria = criteria ?? new BillingDocumentSearchCriteria();
            criteria.Normalize();

            if (criteria.DocumentType != null && !BillingDocumentTypes.Allowed.Contains(criteria.DocumentType))
            {
                return BillingDocumentListResult.Failure("Invalid document type filter.");
            }

            if (criteria.Status != null && !BillingDocumentStatuses.Allowed.Contains(criteria.Status))
            {
                return BillingDocumentListResult.Failure("Invalid document status filter.");
            }

            var dalResult = billingDal.Search(criteria);
            if (dalResult.IsSuccessful)
            {
                return BillingDocumentListResult.Success(dalResult.Data ?? new List<BillingDocument>(), dalResult.ErrorMessage);
            }

            return BillingDocumentListResult.Failure(dalResult.ErrorMessage ?? "Unable to retrieve billing documents.", dalResult.Exception);
        }

        public DatabaseResult UpdateStatus(int billingDocumentId, string newStatus, int currentUserId)
        {
            if (currentUserId <= 0)
            {
                return DatabaseResult.Failure(-1, "A valid user must be provided to update billing document status.");
            }

            return billingDal.UpdateStatus(billingDocumentId, newStatus, currentUserId);
        }

        public DatabaseResult AddItem(int billingDocumentId, BillingDocumentItem item, int currentUserId)
        {
            if (currentUserId <= 0)
            {
                return DatabaseResult.Failure(-1, "A valid user must be provided to add billing document items.");
            }

            if (item == null)
            {
                return DatabaseResult.Failure(-2, "Billing item details are required.");
            }

            var validation = item.Validate();
            if (!validation.IsValid)
            {
                return DatabaseResult.Failure(-3, string.Join("; ", validation.Errors));
            }

            return billingDal.AddItem(billingDocumentId, item, currentUserId);
        }

        public DatabaseResult RemoveItem(int billingDocumentItemId, int currentUserId)
        {
            if (currentUserId <= 0)
            {
                return DatabaseResult.Failure(-1, "A valid user must be provided to remove billing document items.");
            }

             return billingDal.RemoveItem(billingDocumentItemId, currentUserId);
        }

        public DatabaseResult Delete(int billingDocumentId)
        {
            return billingDal.Delete(billingDocumentId);
        }

        public BillingStatisticsResult GetBillingStatistics(int? year, int maxMonths, string sortDirection)
        {
            if (year.HasValue && (year.Value < 2000 || year.Value > 2100))
            {
                return BillingStatisticsResult.Failure("Invalid year parameter for billing statistics.");
            }

            var dalResult = billingDal.GetMonthlyStatistics(year, maxMonths, sortDirection);
            if (dalResult.IsSuccessful)
            {
                var message = string.IsNullOrWhiteSpace(dalResult.ErrorMessage)
                    ? "Billing statistics retrieved successfully."
                    : dalResult.ErrorMessage;
                return BillingStatisticsResult.Success(dalResult.Data, message);
            }

            var failureMessage = string.IsNullOrWhiteSpace(dalResult.ErrorMessage)
                ? "Unable to retrieve billing statistics."
                : dalResult.ErrorMessage;

            return BillingStatisticsResult.Failure(failureMessage, dalResult.Exception);
        }

        private static void CalculateDocumentTotals(BillingDocument document)
        {
            if (document.Items == null)
            {
                document.SubtotalAmount = 0;
                document.TaxAmount = 0;
                document.TotalAmount = 0;
                return;
            }

            foreach (var item in document.Items)
            {
                item.LineSubtotal = Math.Round(item.Quantity * item.UnitPrice, 2, MidpointRounding.AwayFromZero);
                item.LineTaxAmount = Math.Round(item.LineSubtotal * (item.TaxRate / 100m), 2, MidpointRounding.AwayFromZero);
                item.LineTotal = Math.Round(item.LineSubtotal + item.LineTaxAmount, 2, MidpointRounding.AwayFromZero);
            }

            document.SubtotalAmount = document.Items.Sum(i => i.LineSubtotal);
            document.TaxAmount = document.Items.Sum(i => i.LineTaxAmount);
            document.TotalAmount = document.Items.Sum(i => i.LineTotal);
        }

        private static string GenerateDocumentNumber(string documentType)
        {
            string prefix = "BILL";

            if (!string.IsNullOrWhiteSpace(documentType))
            {
                if (documentType.Equals(BillingDocumentTypes.Invoice, StringComparison.OrdinalIgnoreCase))
                {
                    prefix = "INV";
                }
                else if (documentType.Equals(BillingDocumentTypes.DebitNote, StringComparison.OrdinalIgnoreCase))
                {
                    prefix = "DBN";
                }
                else if (documentType.Equals(BillingDocumentTypes.CreditNote, StringComparison.OrdinalIgnoreCase))
                {
                    prefix = "CRN";
                }
            }

            return string.Format(CultureInfo.InvariantCulture, "{0}-{1:yyyyMMddHHmmssfff}", prefix, DateTime.UtcNow);
        }
    }
}
