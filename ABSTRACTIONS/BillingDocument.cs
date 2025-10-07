using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Globalization;
using System.Linq;

namespace ABSTRACTIONS
{
    public static class BillingDocumentTypes
    {
        public const string Invoice = "Invoice";
        public const string DebitNote = "DebitNote";
        public const string CreditNote = "CreditNote";

        public static readonly HashSet<string> Allowed = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            Invoice,
            DebitNote,
            CreditNote
        };
    }

    public static class BillingDocumentStatuses
    {
        public const string Draft = "Draft";
        public const string Issued = "Issued";
        public const string Paid = "Paid";
        public const string Cancelled = "Cancelled";

        public static readonly HashSet<string> Allowed = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            Draft,
            Issued,
            Paid,
            Cancelled
        };
    }

    public class BillingDocument
    {
        public BillingDocument()
        {
            Items = new List<BillingDocumentItem>();
            IssueDateUtc = DateTime.UtcNow;
            CurrencyCode = RegionInfo.CurrentRegion?.ISOCurrencySymbol ?? "ARS";
            Status = BillingDocumentStatuses.Draft;
        }

        public int BillingDocumentId { get; set; }

        [Required]
        public int UserId { get; set; }

        [Required]
        [StringLength(20)]
        public string DocumentType { get; set; }

        [Required]
        [StringLength(50)]
        public string DocumentNumber { get; set; }

        public int? ReferenceDocumentId { get; set; }
        public DateTime IssueDateUtc { get; set; }
        public DateTime? DueDateUtc { get; set; }

        [Required]
        [StringLength(3)]
        public string CurrencyCode { get; set; }

        [Range(0, double.MaxValue)]
        public decimal SubtotalAmount { get; set; }

        [Range(0, double.MaxValue)]
        public decimal TaxAmount { get; set; }

        [Range(0, double.MaxValue)]
        public decimal TotalAmount { get; set; }

        [Required]
        [StringLength(20)]
        public string Status { get; set; }

        public string Notes { get; set; }
        public int CreatedBy { get; set; }
        public DateTime CreatedDateUtc { get; set; }
        public int? LastModifiedBy { get; set; }
        public DateTime? LastModifiedDateUtc { get; set; }

        public List<BillingDocumentItem> Items { get; set; }

        public BillingDocumentValidationResult Validate()
        {
            var result = new BillingDocumentValidationResult();

            if (UserId <= 0)
            {
                result.AddError("UserId must be greater than zero.");
            }

            if (string.IsNullOrWhiteSpace(DocumentType) || !BillingDocumentTypes.Allowed.Contains(DocumentType))
            {
                result.AddError("Invalid document type.");
            }

            if (string.IsNullOrWhiteSpace(DocumentNumber))
            {
                result.AddError("Document number is required.");
            }
            else if (DocumentNumber.Trim().Length > 50)
            {
                result.AddError("Document number cannot exceed 50 characters.");
            }

            if (string.IsNullOrWhiteSpace(CurrencyCode))
            {
                result.AddError("Currency code is required.");
            }
            else if (CurrencyCode.Trim().Length != 3)
            {
                result.AddError("Currency code must be 3 characters long.");
            }

            if (string.IsNullOrWhiteSpace(Status) || !BillingDocumentStatuses.Allowed.Contains(Status))
            {
                result.AddError("Invalid status value.");
            }

            if (Items == null || !Items.Any())
            {
                result.AddError("At least one line item is required.");
            }
            else
            {
                foreach (var item in Items)
                {
                    var itemResult = item.Validate();
                    if (!itemResult.IsValid)
                    {
                        foreach (var error in itemResult.Errors)
                        {
                            result.AddError(error);
                        }
                    }
                }
            }

            return result;
        }
    }

    public class BillingDocumentItem
    {
        public int BillingDocumentItemId { get; set; }
        public int BillingDocumentId { get; set; }
        public int ProductId { get; set; }

        [Required]
        [StringLength(300)]
        public string Description { get; set; }

        [Range(0.01, double.MaxValue)]
        public decimal Quantity { get; set; }

        [Range(0, double.MaxValue)]
        public decimal UnitPrice { get; set; }

        [Range(0, 100)]
        public decimal TaxRate { get; set; }

        [Range(0, double.MaxValue)]
        public decimal LineSubtotal { get; set; }

        [Range(0, double.MaxValue)]
        public decimal LineTaxAmount { get; set; }

        [Range(0, double.MaxValue)]
        public decimal LineTotal { get; set; }

        public string LineNotes { get; set; }

        public BillingDocumentValidationResult Validate()
        {
            var result = new BillingDocumentValidationResult();

            if (ProductId <= 0)
            {
                result.AddError("Product selection is required for each billing item.");
            }

            if (string.IsNullOrWhiteSpace(Description))
            {
                result.AddError("Line description is required.");
            }

            if (Quantity <= 0)
            {
                result.AddError("Quantity must be greater than zero.");
            }

            if (UnitPrice < 0)
            {
                result.AddError("Unit price cannot be negative.");
            }

            if (TaxRate < 0)
            {
                result.AddError("Tax rate cannot be negative.");
            }

            return result;
        }
    }

    public class BillingDocumentValidationResult
    {
        public BillingDocumentValidationResult()
        {
            Errors = new List<string>();
        }

        public bool IsValid => Errors.Count == 0;
        public List<string> Errors { get; }

        public void AddError(string message)
        {
            if (!string.IsNullOrWhiteSpace(message))
            {
                Errors.Add(message);
            }
        }
    }

    public class BillingDocumentSearchCriteria
    {
        private static readonly HashSet<string> AllowedSortColumns = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "IssueDateUtc",
            "DocumentNumber",
            "TotalAmount"
        };

        private static readonly HashSet<string> AllowedSortDirections = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "ASC",
            "DESC"
        };

        public string DocumentType { get; set; }
        public string Status { get; set; }
        public DateTime? FromIssueDateUtc { get; set; }
        public DateTime? ToIssueDateUtc { get; set; }
        public int? UserId { get; set; }
        public string DocumentNumber { get; set; }
        public string SortColumn { get; set; } = "IssueDateUtc";
        public string SortDirection { get; set; } = "DESC";

        public void Normalize()
        {
            DocumentType = string.IsNullOrWhiteSpace(DocumentType) ? null : DocumentType.Trim();
            Status = string.IsNullOrWhiteSpace(Status) ? null : Status.Trim();
            DocumentNumber = string.IsNullOrWhiteSpace(DocumentNumber) ? null : DocumentNumber.Trim();

            if (string.IsNullOrWhiteSpace(SortColumn) || !AllowedSortColumns.Contains(SortColumn))
            {
                SortColumn = "IssueDateUtc";
            }

            if (string.IsNullOrWhiteSpace(SortDirection) || !AllowedSortDirections.Contains(SortDirection))
            {
                SortDirection = "DESC";
            }
        }
    }

    public class BillingDocumentResult : DatabaseResult<BillingDocument>
    {
        public static BillingDocumentResult Success(BillingDocument document, string message = "Success")
        {
            return new BillingDocumentResult
            {
                IsSuccessful = true,
                ResultCode = 1,
                ErrorMessage = message,
                Data = document
            };
        }

        public new static BillingDocumentResult Failure(string errorMessage, Exception exception = null)
        {
            return new BillingDocumentResult
            {
                IsSuccessful = false,
                ResultCode = -1,
                ErrorMessage = errorMessage,
                Exception = exception,
                Data = null
            };
        }
    }

    public class BillingDocumentListResult : DatabaseResult<List<BillingDocument>>
    {
        public BillingDocumentListResult()
        {
            Data = new List<BillingDocument>();
        }

        public static BillingDocumentListResult Success(List<BillingDocument> documents, string message = "Success")
        {
            return new BillingDocumentListResult
            {
                IsSuccessful = true,
                ResultCode = 1,
                ErrorMessage = message,
                Data = documents ?? new List<BillingDocument>()
            };
        }

        public new static BillingDocumentListResult Failure(string errorMessage, Exception exception = null)
        {
            return new BillingDocumentListResult
            {
                IsSuccessful = false,
                ResultCode = -1,
                ErrorMessage = errorMessage,
                Exception = exception,
                Data = new List<BillingDocument>()
            };
        }
    }
}
