using System;
using System.Collections.Generic;
using ABSTRACTIONS;
using DAL;

namespace BLL
{
    /// <summary>
    /// Business Logic Layer for Homepage Advertisement operations
    /// Implements business rules and validation before calling DAL
    /// </summary>
    public class HomepageAdBLL
    {
        private readonly HomepageAdDAL _homepageAdDal;

        public HomepageAdBLL()
        {
            _homepageAdDal = new HomepageAdDAL();
        }

        /// <summary>
        /// Retrieves all homepage ads
        /// </summary>
        public DatabaseResult<List<HomepageAd>> GetAllAds()
        {
            try
            {
                var ads = _homepageAdDal.GetAllAds();
                return DatabaseResult<List<HomepageAd>>.Success(ads ?? new List<HomepageAd>());
            }
            catch (Exception ex)
            {
                return DatabaseResult<List<HomepageAd>>.Failure("Unable to load advertisements.", ex);
            }
        }

        /// <summary>
        /// Retrieves a single homepage ad by ID with validation
        /// </summary>
        public DatabaseResult<HomepageAd> GetAdById(int adId)
        {
            if (adId <= 0)
            {
                return DatabaseResult<HomepageAd>.Failure(-1, "Advertisement identifier is required.");
            }

            try
            {
                var ad = _homepageAdDal.GetAdById(adId);
                if (ad == null)
                {
                    return DatabaseResult<HomepageAd>.Failure(-2, "Advertisement not found.");
                }

                return DatabaseResult<HomepageAd>.Success(ad);
            }
            catch (Exception ex)
            {
                return DatabaseResult<HomepageAd>.Failure("Unable to load advertisement.", ex);
            }
        }

        /// <summary>
        /// Retrieves the selected ad for display on the homepage
        /// Public method - no authentication required
        /// </summary>
        public DatabaseResult<HomepageAd> GetSelectedAdForDisplay()
        {
            try
            {
                var ad = _homepageAdDal.GetSelectedAdForDisplay();
                // Returning null is valid - means no ad to display
                return DatabaseResult<HomepageAd>.Success(ad);
            }
            catch (Exception ex)
            {
                return DatabaseResult<HomepageAd>.Failure("Unable to load advertisement for display.", ex);
            }
        }

        /// <summary>
        /// Validates and saves a homepage ad
        /// Performs comprehensive validation before calling DAL
        /// </summary>
        public DatabaseResult SaveAd(HomepageAd ad, int? auditUserId)
        {
            if (ad == null)
            {
                return DatabaseResult.Failure(-1, "Advertisement information is required.");
            }

            // Validate required field: Title
            if (string.IsNullOrWhiteSpace(ad.Title))
            {
                return DatabaseResult.Failure(-2, "Advertisement title is required.");
            }

            // Trim and validate Title length (max 200)
            ad.Title = ad.Title.Trim();
            if (ad.Title.Length > 200)
            {
                return DatabaseResult.Failure(-3, "Advertisement title cannot exceed 200 characters.");
            }

            // Validate optional BadgeText length (max 100)
            if (!string.IsNullOrWhiteSpace(ad.BadgeText))
            {
                ad.BadgeText = ad.BadgeText.Trim();
                if (ad.BadgeText.Length > 100)
                {
                    return DatabaseResult.Failure(-4, "Badge text cannot exceed 100 characters.");
                }
            }
            else
            {
                ad.BadgeText = null;
            }

            // Validate optional Description length (max 500)
            if (!string.IsNullOrWhiteSpace(ad.Description))
            {
                ad.Description = ad.Description.Trim();
                if (ad.Description.Length > 500)
                {
                    return DatabaseResult.Failure(-5, "Description cannot exceed 500 characters.");
                }
            }
            else
            {
                ad.Description = null;
            }

            // Validate optional CtaText length (max 100)
            if (!string.IsNullOrWhiteSpace(ad.CtaText))
            {
                ad.CtaText = ad.CtaText.Trim();
                if (ad.CtaText.Length > 100)
                {
                    return DatabaseResult.Failure(-6, "Call-to-action text cannot exceed 100 characters.");
                }
            }
            else
            {
                ad.CtaText = null;
            }

            // Validate optional TargetUrl length (max 500)
            if (!string.IsNullOrWhiteSpace(ad.TargetUrl))
            {
                ad.TargetUrl = ad.TargetUrl.Trim();
                if (ad.TargetUrl.Length > 500)
                {
                    return DatabaseResult.Failure(-7, "Target URL cannot exceed 500 characters.");
                }

                // Basic URL validation
                if (!IsValidUrl(ad.TargetUrl))
                {
                    return DatabaseResult.Failure(-8, "Target URL format is invalid. Must start with http:// or https://");
                }
            }
            else
            {
                ad.TargetUrl = null;
            }

            try
            {
                return _homepageAdDal.SaveAd(ad, auditUserId);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure("Unable to save advertisement.", ex);
            }
        }

        /// <summary>
        /// Validates and deletes a homepage ad
        /// </summary>
        public DatabaseResult DeleteAd(int adId, int? auditUserId)
        {
            if (adId <= 0)
            {
                return DatabaseResult.Failure(-1, "Advertisement identifier is required.");
            }

            try
            {
                // Verify ad exists before attempting delete
                var ad = _homepageAdDal.GetAdById(adId);
                if (ad == null)
                {
                    return DatabaseResult.Failure(-2, "Advertisement not found.");
                }

                return _homepageAdDal.DeleteAd(adId, auditUserId);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure("Unable to delete advertisement.", ex);
            }
        }

        /// <summary>
        /// Validates and sets the selected ad for display
        /// Pass null to deselect all ads
        /// </summary>
        public DatabaseResult SetSelectedAd(int? adId, int? auditUserId)
        {
            try
            {
                // If adId is provided, verify it exists and is active
                if (adId.HasValue && adId.Value > 0)
                {
                    var ad = _homepageAdDal.GetAdById(adId.Value);
                    if (ad == null)
                    {
                        return DatabaseResult.Failure(-2, "Advertisement not found.");
                    }

                    if (!ad.IsActive)
                    {
                        return DatabaseResult.Failure(-3, "Cannot select an inactive advertisement.");
                    }
                }

                return _homepageAdDal.SetSelectedAd(adId, auditUserId);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure("Unable to set selected advertisement.", ex);
            }
        }

        #region Private Helper Methods

        /// <summary>
        /// Validates URL format
        /// </summary>
        private static bool IsValidUrl(string url)
        {
            if (string.IsNullOrWhiteSpace(url))
            {
                return false;
            }

            // Check for common URL patterns
            if (url.StartsWith("http://", StringComparison.OrdinalIgnoreCase) ||
                url.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
            {
                // Attempt to create a Uri to validate format
                return Uri.TryCreate(url, UriKind.Absolute, out Uri result) &&
                       (result.Scheme == Uri.UriSchemeHttp || result.Scheme == Uri.UriSchemeHttps);
            }

            return false;
        }

        #endregion
    }
}
