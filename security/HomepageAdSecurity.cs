using System;
using System.Collections.Generic;
using ABSTRACTIONS;
using BLL;

namespace SECURITY
{
    /// <summary>
    /// Security Layer for Homepage Advertisement operations
    /// Enforces admin-only access for management operations
    /// Follows UI -> Security -> BLL -> DAL architectural flow
    /// </summary>
    public class HomepageAdSecurity
    {
        private const string AdminAdsPagePermissionKey = "~/AdminAds.aspx";

        private readonly HomepageAdBLL _homepageAdBll;
        private readonly UserSecurity _userSecurity;
        private readonly AuthorizationSecurity _authorizationSecurity;

        public HomepageAdSecurity()
        {
            _homepageAdBll = new HomepageAdBLL();
            _userSecurity = new UserSecurity();
            _authorizationSecurity = new AuthorizationSecurity();
        }

        /// <summary>
        /// Retrieves all homepage ads
        /// Requires admin permission: ~/AdminAds.aspx
        /// </summary>
        public DatabaseResult<List<HomepageAd>> GetAllAds(int userId)
        {
            if (!HasAdminAdsPagePermission())
            {
                return DatabaseResult<List<HomepageAd>>.Failure(-401, "Unauthorized access.");
            }

            return _homepageAdBll.GetAllAds();
        }

        /// <summary>
        /// Retrieves a single homepage ad by ID
        /// Requires admin permission: ~/AdminAds.aspx
        /// </summary>
        public DatabaseResult<HomepageAd> GetAdById(int userId, int adId)
        {
            if (!HasAdminAdsPagePermission())
            {
                return DatabaseResult<HomepageAd>.Failure(-401, "Unauthorized access.");
            }

            if (adId <= 0)
            {
                return DatabaseResult<HomepageAd>.Failure(-2, "Advertisement identifier is required.");
            }

            return _homepageAdBll.GetAdById(adId);
        }

        /// <summary>
        /// Retrieves the selected ad for display on the homepage
        /// PUBLIC METHOD - No authentication required
        /// This method is accessible to all users for homepage display
        /// </summary>
        public DatabaseResult<HomepageAd> GetSelectedAdForDisplay()
        {
            return _homepageAdBll.GetSelectedAdForDisplay();
        }

        /// <summary>
        /// Saves (creates or updates) a homepage ad
        /// Requires admin permission: ~/AdminAds.aspx
        /// </summary>
        public DatabaseResult SaveAd(int userId, HomepageAd ad)
        {
            if (!HasAdminAdsPagePermission())
            {
                return DatabaseResult.Failure(-401, "Unauthorized access.");
            }

            if (ad == null)
            {
                return DatabaseResult.Failure(-2, "Advertisement information is required.");
            }

            // Pass userId as audit user ID
            return _homepageAdBll.SaveAd(ad, userId);
        }

        /// <summary>
        /// Deletes (soft delete) a homepage ad
        /// Requires admin permission: ~/AdminAds.aspx
        /// </summary>
        public DatabaseResult DeleteAd(int userId, int adId)
        {
            if (!HasAdminAdsPagePermission())
            {
                return DatabaseResult.Failure(-401, "Unauthorized access.");
            }

            if (adId <= 0)
            {
                return DatabaseResult.Failure(-2, "Advertisement identifier is required.");
            }

            // Pass userId as audit user ID
            return _homepageAdBll.DeleteAd(adId, userId);
        }

        /// <summary>
        /// Sets the selected ad for display on the homepage
        /// Requires admin permission: ~/AdminAds.aspx
        /// Pass null to deselect all ads
        /// </summary>
        public DatabaseResult SetSelectedAd(int userId, int? adId)
        {
            if (!HasAdminAdsPagePermission())
            {
                return DatabaseResult.Failure(-401, "Unauthorized access.");
            }

            // Pass userId as audit user ID
            return _homepageAdBll.SetSelectedAd(adId, userId);
        }

        #region Private Helper Methods

        /// <summary>
        /// Checks if the current user has permission to access the AdminAds page
        /// This aligns with the page-level authorization system
        /// </summary>
        private bool HasAdminAdsPagePermission()
        {
            return _authorizationSecurity.UserHasPermission(AdminAdsPagePermissionKey);
        }

        #endregion
    }
}
