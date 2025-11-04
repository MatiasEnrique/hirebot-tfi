using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Security;
using ABSTRACTIONS;
using SECURITY;
using BLL;
using Hirebot_TFI;

namespace UI
{
    public partial class Catalog : BasePage
    {
        private CatalogBLL catalogBLL;
        private ProductBLL productBLL;
        private CommentSecurity commentSecurity;

        protected void Page_Load(object sender, EventArgs e)
        {
            catalogBLL = new CatalogBLL();
            productBLL = new ProductBLL();
            commentSecurity = new CommentSecurity();

            if (!IsPostBack)
            {
                LoadDisplayedCatalog();
                InitializeCommentsSection();
                InitializeCommentCounts();
            }
        }


        protected void ddlCategories_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadDisplayedCatalog();
            InitializeCommentCounts();
        }

        private void LoadDisplayedCatalog()
        {
            try
            {
                // Get the displayed catalog ID from application state or config
                var displayedCatalogId = GetDisplayedCatalogId();
                
                if (displayedCatalogId == 0)
                {
                    ShowNoCatalogMessage();
                    return;
                }

                var catalog = catalogBLL.GetCatalogById(displayedCatalogId);
                if (catalog == null || !catalog.IsActive)
                {
                    ShowNoCatalogMessage();
                    return;
                }

                // Set catalog information
                litCatalogTitle.Text = catalog.Name;
                litCatalogDescription.Text = !string.IsNullOrEmpty(catalog.Description) ? 
                    catalog.Description : GetLocalizedString("ExploreOurProducts");

                // Load products from this catalog
                LoadCatalogProducts(displayedCatalogId);
                LoadCategories(displayedCatalogId);
            }
            catch (Exception ex)
            {
                ShowMessage(GetLocalizedString("UnexpectedError"), "danger");
            }
        }

        private void LoadCatalogProducts(int catalogId)
        {
            try
            {
                var allProducts = catalogBLL.GetProductsByCatalogId(catalogId);
                var filteredProducts = allProducts;

                // Filter by category if selected
                if (ddlCategories.SelectedValue != "all" && !string.IsNullOrEmpty(ddlCategories.SelectedValue))
                {
                    filteredProducts = allProducts.Where(p => p.Category == ddlCategories.SelectedValue).ToList();
                }

                // Only show active products
                filteredProducts = filteredProducts.Where(p => p.IsActive).ToList();

                litProductCount.Text = filteredProducts.Count().ToString();

                if (!filteredProducts.Any())
                {
                    ShowNoProductsMessage();
                    return;
                }

                rptProducts.DataSource = filteredProducts;
                rptProducts.DataBind();

                // Hide no products message
                phNoProducts.Visible = false;
                phNoCatalog.Visible = false;
            }
            catch (Exception ex)
            {
                ShowMessage(GetLocalizedString("UnexpectedError"), "danger");
            }
        }

        private void LoadCategories(int catalogId)
        {
            try
            {
                var products = catalogBLL.GetProductsByCatalogId(catalogId);
                var categories = products
                    .Where(p => p.IsActive && !string.IsNullOrEmpty(p.Category))
                    .Select(p => p.Category)
                    .Distinct()
                    .OrderBy(c => c)
                    .ToList();

                ddlCategories.Items.Clear();
                ddlCategories.Items.Add(new ListItem(GetLocalizedString("AllCategories"), "all"));

                foreach (var category in categories)
                {
                    ddlCategories.Items.Add(new ListItem(category, category));
                }
            }
            catch (Exception ex)
            {
                // Fallback to showing all categories option only
                ddlCategories.Items.Clear();
                ddlCategories.Items.Add(new ListItem(GetLocalizedString("AllCategories"), "all"));
            }
        }

        private int GetDisplayedCatalogId()
        {
            // Try to get from Application state first
            if (Application["DisplayedCatalogId"] != null)
            {
                if (int.TryParse(Application["DisplayedCatalogId"].ToString(), out int catalogId))
                {
                    return catalogId;
                }
            }

            // Fallback: Get the first active catalog
            try
            {
                var catalogs = catalogBLL.GetActiveCatalogs();
                if (catalogs.Any())
                {
                    var firstCatalog = catalogs.First();
                    Application["DisplayedCatalogId"] = firstCatalog.CatalogId;
                    return firstCatalog.CatalogId;
                }
            }
            catch
            {
                // Return 0 if no catalogs available
            }

            return 0;
        }

        private void ShowNoCatalogMessage()
        {
            phNoCatalog.Visible = true;
            phNoProducts.Visible = false;
            rptProducts.DataSource = null;
            rptProducts.DataBind();
            litCatalogTitle.Text = GetLocalizedString("ProductCatalog");
            litCatalogDescription.Text = GetLocalizedString("NoCatalogSelectedMessage");
            litProductCount.Text = "0";
            
            ddlCategories.Items.Clear();
            ddlCategories.Items.Add(new ListItem(GetLocalizedString("AllCategories"), "all"));
        }

        private void ShowNoProductsMessage()
        {
            phNoProducts.Visible = true;
            phNoCatalog.Visible = false;
            rptProducts.DataSource = null;
            rptProducts.DataBind();
        }

        private void ShowMessage(string message, string type)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = "alert alert-" + type;
            lblMessage.CssClass = lblMessage.CssClass.Replace("d-none", "");
        }

        private void ShowModalMessage(string message, string type)
        {
            lblModalMessage.Text = message;
            lblModalMessage.CssClass = "alert alert-" + type + " mb-3";
            lblModalMessage.CssClass = lblModalMessage.CssClass.Replace("d-none", "");
            
            // Use the enhanced frontend message system
            string jsMessage = HttpUtility.JavaScriptStringEncode(message);
            string script = "setTimeout(function() { if (typeof showModalMessage === 'function') { showModalMessage('" + jsMessage + "', '" + type + "'); } }, 100);";
            ClientScript.RegisterStartupScript(this.GetType(), "ShowEnhancedModalMessage", script, true);
        }

        private string GetLocalizedString(string key)
        {
            return key;
        }

        private void InitializeCommentCounts()
        {
            try
            {
                // Get all products currently displayed to load their comment counts
                var displayedCatalogId = GetDisplayedCatalogId();
                if (displayedCatalogId == 0) return;

                var allProducts = catalogBLL.GetProductsByCatalogId(displayedCatalogId);
                if (allProducts == null || !allProducts.Any()) return;

                var filteredProducts = allProducts.Where(p => p.IsActive);
                
                // Apply category filter if selected
                if (ddlCategories.SelectedValue != "all" && !string.IsNullOrEmpty(ddlCategories.SelectedValue))
                {
                    filteredProducts = filteredProducts.Where(p => p.Category == ddlCategories.SelectedValue);
                }

                string commentCountsScript = "try { ";
                
                foreach (var product in filteredProducts)
                {
                    var commentsResult = commentSecurity.GetCommentsByProductId(product.ProductId);
                    int commentCount = (commentsResult.IsSuccessful && commentsResult.Data != null) ? commentsResult.Data.Count : 0;
                    
                    commentCountsScript += "var badge" + product.ProductId + " = document.querySelector('.comment-count[data-product-id=\"" + product.ProductId + "\"]'); ";
                    commentCountsScript += "if (badge" + product.ProductId + ") badge" + product.ProductId + ".textContent = '" + commentCount + "'; ";
                }
                
                commentCountsScript += "console.log('Initialized comment counts for all products'); ";
                commentCountsScript += "} catch (e) { console.warn('Error initializing comment counts:', e); }";

                ClientScript.RegisterStartupScript(this.GetType(), "InitializeCommentCounts", commentCountsScript, true);
            }
            catch (Exception ex)
            {
                // Log error but don't break the page
                string errorScript = "console.error('InitializeCommentCounts Exception: " + HttpUtility.JavaScriptStringEncode(ex.Message) + "');";
                ClientScript.RegisterStartupScript(this.GetType(), "CommentCountsError", errorScript, true);
            }
        }

        #region Comment Operations

        private void InitializeCommentsSection()
        {
            // Check if user is authenticated
            bool isAuthenticated = Request.IsAuthenticated;
            
            phLoginPrompt.Visible = !isAuthenticated;
            phAddCommentInPanel.Visible = isAuthenticated;
            
            // Initialize rating options with safe HTML entities
            if (isAuthenticated && rblRating.Items.Count == 0)
            {
                rblRating.Items.Add(new ListItem("★", "1"));
                rblRating.Items.Add(new ListItem("★★", "2"));
                rblRating.Items.Add(new ListItem("★★★", "3"));
                rblRating.Items.Add(new ListItem("★★★★", "4"));
                rblRating.Items.Add(new ListItem("★★★★★", "5"));
                
                // Ensure proper rendering mode for radio buttons
                rblRating.RepeatLayout = RepeatLayout.Flow;
            }
        }

        protected void btnLoadComments_Click(object sender, EventArgs e)
        {
            try
            {
                string productIdString = Request.Form["__EVENTARGUMENT"];
                int productId = 0;
                
                // DEBUG: Log product ID retrieval attempts
                string debugMsg = $"Attempting to load comments - EventArgument: '{productIdString}', HiddenField: '{hfSelectedProductId.Value}'";
                
                // Try to get product ID from event argument first, then from hidden field
                if (!int.TryParse(productIdString, out productId))
                {
                    int.TryParse(hfSelectedProductId.Value, out productId);
                }
                
                debugMsg += $" | Final ProductId: {productId}";
                
                // DEBUG: Log to browser console
                string debugScript = "console.log('DEBUG btnLoadComments_Click: " + HttpUtility.JavaScriptStringEncode(debugMsg) + "');";
                ClientScript.RegisterStartupScript(this.GetType(), "LoadCommentsDebug", debugScript, true);
                
                if (productId > 0)
                {
                    // Store the product ID in the hidden field for consistency
                    hfSelectedProductId.Value = productId.ToString();
                    LoadCommentsForProduct(productId);
                    
                    // Update the UpdatePanel
                    upComments.Update();
                    
                    // Use enhanced modal management
                    string script = "setTimeout(function() { if (typeof ensureModalStaysOpen === 'function') { ensureModalStaysOpen(); } }, 100);";
                    ClientScript.RegisterStartupScript(this.GetType(), "ShowCommentsModal", script, true);
                }
                else
                {
                    ShowModalMessage(GetLocalizedString("CommentError"), "warning");
                    
                    // DEBUG: Log the error case
                    string errorScript = "console.error('Failed to load comments - Invalid product ID: " + productId + "');";
                    ClientScript.RegisterStartupScript(this.GetType(), "LoadCommentsError", errorScript, true);
                }
            }
            catch (Exception ex)
            {
                ShowModalMessage(GetLocalizedString("CommentError"), "danger");
                
                // DEBUG: Log exception details
                string errorScript = "console.error('btnLoadComments_Click Exception: " + HttpUtility.JavaScriptStringEncode(ex.Message) + "');";
                ClientScript.RegisterStartupScript(this.GetType(), "LoadCommentsException", errorScript, true);
            }
        }

        protected void btnPostComment_Click(object sender, EventArgs e)
        {
            try
            {
                if (!Request.IsAuthenticated)
                {
                    ShowModalMessage(GetLocalizedString("PleaseSignIn"), "warning");
                    
                    // Reset button state and keep modal open
                    string resetScript = "setTimeout(function() { " +
                        "if (typeof ensureModalStaysOpen === 'function') { ensureModalStaysOpen(); } " +
                        "if (typeof resetPostButton === 'function') { resetPostButton(); } " +
                        "}, 200);";
                    ClientScript.RegisterStartupScript(this.GetType(), "HandleAuthError", resetScript, true);
                    return;
                }

                int productId = 0;
                if (!int.TryParse(hfSelectedProductId.Value, out productId) || productId <= 0)
                {
                    ShowModalMessage(GetLocalizedString("CommentError"), "danger");
                    
                    // Reset button state and keep modal open
                    string resetScript = "setTimeout(function() { " +
                        "if (typeof ensureModalStaysOpen === 'function') { ensureModalStaysOpen(); } " +
                        "if (typeof resetPostButton === 'function') { resetPostButton(); } " +
                        "}, 200);";
                    ClientScript.RegisterStartupScript(this.GetType(), "HandleProductError", resetScript, true);
                    return;
                }

                // Get current user information
                var identity = HttpContext.Current.User.Identity;
                int userId = GetCurrentUserId();
                string userName = identity.Name;

                if (userId <= 0)
                {
                    ShowModalMessage(GetLocalizedString("CommentError"), "danger");
                    
                    // Reset button state and keep modal open
                    string resetScript = "setTimeout(function() { " +
                        "if (typeof ensureModalStaysOpen === 'function') { ensureModalStaysOpen(); } " +
                        "if (typeof resetPostButton === 'function') { resetPostButton(); } " +
                        "}, 200);";
                    ClientScript.RegisterStartupScript(this.GetType(), "HandleUserError", resetScript, true);
                    return;
                }

                // Validate comment text
                string commentText = txtComment.Text.Trim();
                if (string.IsNullOrWhiteSpace(commentText))
                {
                    ShowModalMessage(GetLocalizedString("CommentRequired"), "warning");
                    upComments.Update();
                    
                    // Reset button state and keep modal open
                    string resetScript = "setTimeout(function() { " +
                        "if (typeof ensureModalStaysOpen === 'function') { ensureModalStaysOpen(); } " +
                        "if (typeof resetPostButton === 'function') { resetPostButton(); } " +
                        "}, 200);";
                    ClientScript.RegisterStartupScript(this.GetType(), "HandleValidationError1", resetScript, true);
                    return;
                }

                if (commentText.Length < 10)
                {
                    ShowModalMessage(GetLocalizedString("CommentTooShort"), "warning");
                    upComments.Update();
                    
                    // Reset button state and keep modal open
                    string resetScript = "setTimeout(function() { " +
                        "if (typeof ensureModalStaysOpen === 'function') { ensureModalStaysOpen(); } " +
                        "if (typeof resetPostButton === 'function') { resetPostButton(); } " +
                        "}, 200);";
                    ClientScript.RegisterStartupScript(this.GetType(), "HandleValidationError2", resetScript, true);
                    return;
                }

                if (commentText.Length > 1000)
                {
                    ShowModalMessage(GetLocalizedString("CommentTooLong"), "warning");
                    upComments.Update();
                    
                    // Reset button state and keep modal open
                    string resetScript = "setTimeout(function() { " +
                        "if (typeof ensureModalStaysOpen === 'function') { ensureModalStaysOpen(); } " +
                        "if (typeof resetPostButton === 'function') { resetPostButton(); } " +
                        "}, 200);";
                    ClientScript.RegisterStartupScript(this.GetType(), "HandleValidationError3", resetScript, true);
                    return;
                }

                // Get rating value
                int? commentRating = null;
                if (!string.IsNullOrEmpty(rblRating.SelectedValue))
                {
                    if (int.TryParse(rblRating.SelectedValue, out int rating))
                    {
                        commentRating = Math.Max(1, Math.Min(5, rating));
                    }
                }

                // Save comment using Security layer (proper architectural flow: UI -> Security -> BLL -> DAL)
                var result = commentSecurity.CreateComment(productId, commentText, commentRating);

                if (result.IsSuccessful)
                {
                    ShowModalMessage(GetLocalizedString("CommentPendingApproval"), "success");
                    
                    // Clear form
                    txtComment.Text = string.Empty;
                    rblRating.ClearSelection();
                    
                    // Reload comments for the product
                    LoadCommentsForProduct(productId);
                    
                    // Update the UpdatePanel (this will automatically refresh the entire comment section)
                    upComments.Update();
                    
                    // Enhanced modal and form management
                    string script = "setTimeout(function() { " +
                        "if (typeof ensureModalStaysOpen === 'function') { ensureModalStaysOpen(); } " +
                        "if (typeof initializeCharacterCounter === 'function') { initializeCharacterCounter(); } " +
                        "if (typeof initializeRatingStars === 'function') { initializeRatingStars(); } " +
                        "}, 200);";
                    ClientScript.RegisterStartupScript(this.GetType(), "ShowCommentsModalAfterPost", script, true);
                }
                else
                {
                    string errorMessage = GetLocalizedString("CommentCreationFailed");
                    if (!string.IsNullOrEmpty(result.ErrorMessage))
                    {
                        errorMessage = errorMessage + ": " + result.ErrorMessage;
                    }
                    ShowModalMessage(errorMessage, "danger");
                    upComments.Update();
                    
                    // Ensure modal stays open and reset button state
                    string script = "setTimeout(function() { " +
                        "if (typeof ensureModalStaysOpen === 'function') { ensureModalStaysOpen(); } " +
                        "if (typeof resetPostButton === 'function') { resetPostButton(); } " +
                        "}, 200);";
                    ClientScript.RegisterStartupScript(this.GetType(), "HandlePostError", script, true);
                }
            }
            catch (Exception ex)
            {
                ShowModalMessage(GetLocalizedString("CommentError"), "danger");
                upComments.Update();
                
                // Ensure modal stays open and reset button state on error
                string script = "setTimeout(function() { " +
                    "if (typeof ensureModalStaysOpen === 'function') { ensureModalStaysOpen(); } " +
                    "if (typeof resetPostButton === 'function') { resetPostButton(); } " +
                    "}, 200);";
                ClientScript.RegisterStartupScript(this.GetType(), "HandlePostException", script, true);
            }
        }

        private void LoadCommentsForProduct(int productId)
        {
            try
            {
                // DEBUG: Add comprehensive logging to track comment loading
                string debugInfo = $"Loading comments for ProductId: {productId}";
                
                // Use Security layer for proper architectural flow: UI -> Security -> BLL -> DAL
                var comments = commentSecurity.GetCommentsByProductId(productId);
                debugInfo += $" | Comments result - IsSuccessful: {comments.IsSuccessful}";
                
                if (comments.IsSuccessful && comments.Data != null)
                {
                    debugInfo += $" | Comments count: {comments.Data.Count}";
                    foreach (var comment in comments.Data)
                    {
                        debugInfo += $" | Comment {comment.CommentId}: IsActive={comment.IsActive}, IsApproved={comment.IsApproved}, Text='{comment.CommentText.Substring(0, Math.Min(50, comment.CommentText.Length))}...'";
                    }
                }
                else
                {
                    debugInfo += $" | Error: {comments.ErrorMessage}";
                }
                
                var statisticsResult = commentSecurity.GetCommentStatistics(productId);
                debugInfo += $" | Statistics result - IsSuccessful: {statisticsResult.IsSuccessful}";
                
                var commentsSummary = statisticsResult.IsSuccessful ? statisticsResult.Data : new CommentStatistics { ProductId = productId, TotalComments = 0, AverageRating = 0 };

              
                // Update UI with comment data
                rptComments.DataSource = comments.IsSuccessful ? comments.Data : new List<Comment>();
                rptComments.DataBind();

                // Show/hide no comments message
                phNoComments.Visible = !comments.IsSuccessful || comments.Data == null || comments.Data.Count == 0;

                // Update comment counts and rating information via JavaScript
                int commentsCount = 0;
                if (comments.IsSuccessful && comments.Data != null)
                {
                    commentsCount = comments.Data.Count;
                }
                
                double averageRating = (double)(commentsSummary.AverageRating ?? 0m);
                string averageRatingString = averageRating.ToString("F1");
                
                string script = "try { ";
                script += "console.log('🔍 DOM INSPECTION - Looking for comment UI elements...'); ";
                
                // DOM inspection and element finding
                script += "var commentsCountElement = document.getElementById('commentsCount'); ";
                script += "var totalCommentsElement = document.getElementById('totalComments'); ";
                script += "var averageRatingElement = document.getElementById('averageRating'); ";
                script += "var productCommentBadge = document.querySelector('.comment-count[data-product-id=\"" + productId.ToString() + "\"]'); ";
                
                // Log element inspection results
                script += "console.log('🔍 Element inspection results:'); ";
                script += "console.log('  - commentsCount element:', commentsCountElement, commentsCountElement ? 'EXISTS' : 'MISSING'); ";
                script += "console.log('  - totalComments element:', totalCommentsElement, totalCommentsElement ? 'EXISTS' : 'MISSING'); ";
                script += "console.log('  - averageRating element:', averageRatingElement, averageRatingElement ? 'EXISTS' : 'MISSING'); ";
                script += "console.log('  - productCommentBadge element:', productCommentBadge, productCommentBadge ? 'EXISTS' : 'MISSING'); ";
                
                // Log current values before update
                script += "if (commentsCountElement) { console.log('  - commentsCount current value:', commentsCountElement.textContent); } ";
                script += "if (totalCommentsElement) { console.log('  - totalComments current value:', totalCommentsElement.textContent); } ";
                
                // Update all comment count displays with detailed logging
                script += "if (commentsCountElement) { ";
                script += "  var oldValue = commentsCountElement.textContent; ";
                script += "  commentsCountElement.textContent = '" + commentsCount.ToString() + "'; ";
                script += "  console.log('✅ Updated modal header badge: ' + oldValue + ' → ' + '" + commentsCount.ToString() + "'); ";
                script += "} else { console.error('❌ Modal header badge (#commentsCount) not found!'); } ";
                
                script += "if (totalCommentsElement) { ";
                script += "  totalCommentsElement.textContent = '" + commentsCount.ToString() + "'; ";
                script += "  console.log('✅ Updated modal summary count: " + commentsCount.ToString() + "'); ";
                script += "} ";
                
                script += "if (averageRatingElement) { ";
                script += "  averageRatingElement.textContent = '" + averageRatingString + "'; ";
                script += "  console.log('✅ Updated average rating: " + averageRatingString + "'); ";
                script += "} ";
                
                script += "if (productCommentBadge) { ";
                script += "  productCommentBadge.textContent = '" + commentsCount.ToString() + "'; ";
                script += "  console.log('✅ Updated product card badge: " + commentsCount.ToString() + "'); ";
                script += "} ";
                
                script += "console.log('🎯 FINAL UPDATE STATUS - Count: " + commentsCount.ToString() + ", Rating: " + averageRatingString + ", ProductId: " + productId.ToString() + "'); ";
                script += "} catch (e) { console.error('❌ Error updating comment UI:', e); }";

                ClientScript.RegisterStartupScript(this.GetType(), "UpdateCommentUI", script, true);

                // Additional delayed update with comprehensive element search
                string delayedScript = "setTimeout(function() { try { ";
                delayedScript += "console.log('🔄 DELAYED UPDATE - Searching for comments badge after UpdatePanel...'); ";
                delayedScript += "var commentsCountBadge = document.getElementById('commentsCount'); ";
                delayedScript += "console.log('🔍 Delayed search result:', commentsCountBadge, commentsCountBadge ? 'FOUND' : 'STILL MISSING'); ";
                
                // Try alternative search methods if primary fails
                delayedScript += "if (!commentsCountBadge) { ";
                delayedScript += "  console.log('⚠️ Trying alternative selectors...'); ";
                delayedScript += "  commentsCountBadge = document.querySelector('#commentsCount'); ";
                delayedScript += "  console.log('  - querySelector result:', commentsCountBadge ? 'FOUND' : 'NOT FOUND'); ";
                delayedScript += "  if (!commentsCountBadge) { ";
                delayedScript += "    commentsCountBadge = document.querySelector('.badge'); ";
                delayedScript += "    console.log('  - generic badge selector result:', commentsCountBadge ? 'FOUND' : 'NOT FOUND'); ";
                delayedScript += "  } ";
                delayedScript += "} ";
                
                delayedScript += "if (commentsCountBadge) { ";
                delayedScript += "  var beforeValue = commentsCountBadge.textContent; ";
                delayedScript += "  commentsCountBadge.textContent = '" + commentsCount.ToString() + "'; ";
                delayedScript += "  console.log('✅ Delayed update SUCCESS - Comments badge: ' + beforeValue + ' → " + commentsCount.ToString() + "'); ";
                delayedScript += "} else { ";
                delayedScript += "  console.error('❌ CRITICAL: Comments count badge still not found after 500ms delay!'); ";
                delayedScript += "  console.log('🔍 Full DOM search for any element with commentsCount...'); ";
                delayedScript += "  var allElements = document.querySelectorAll('*[id*=\"commentsCount\"], *[class*=\"commentsCount\"]'); ";
                delayedScript += "  console.log('  - Found elements:', allElements); ";
                delayedScript += "} ";
                delayedScript += "} catch (e) { console.error('❌ Delayed update error:', e); } }, 500);";
                
                ClientScript.RegisterStartupScript(this.GetType(), "DelayedCommentUIUpdate", delayedScript, true);

                // Get product name for modal header
                var product = GetProductById(productId);
                if (product != null && !string.IsNullOrEmpty(product.Name))
                {
                    string safeName = HttpUtility.JavaScriptStringEncode(product.Name);
                    string productScript = "document.getElementById('commentProductName').textContent = '" + safeName + "';";
                    ClientScript.RegisterStartupScript(this.GetType(), "UpdateProductName", productScript, true);
                }
            }
            catch (Exception ex)
            {
                ShowMessage(GetLocalizedString("CommentError"), "danger");
                // DEBUG: Log exception details to browser console
                string errorScript = "console.error('LoadCommentsForProduct Exception: " + HttpUtility.JavaScriptStringEncode(ex.Message) + "');";
                ClientScript.RegisterStartupScript(this.GetType(), "CommentLoadError", errorScript, true);
            }
        }

        private int GetCurrentUserId()
        {
            try
            {
                if (Request.IsAuthenticated)
                {
                    // First try to get user ID from session
                    if (Session["UserId"] != null && int.TryParse(Session["UserId"].ToString(), out int sessionUserId))
                    {
                        return sessionUserId;
                    }
                    
                    // If not in session, get from database using username
                    string username = HttpContext.Current.User.Identity.Name;
                    if (!string.IsNullOrEmpty(username))
                    {
                        var userBLL = new UserBLL();
                        var user = userBLL.GetUserByUsername(username);
                        if (user != null)
                        {
                            // Store in session for future use
                            Session["UserId"] = user.UserId;
                            return user.UserId;
                        }
                    }
                }
                return 0;
            }
            catch
            {
                return 0;
            }
        }

        private Product GetProductById(int productId)
        {
            try
            {
                // Use the existing productBLL to get product information
                var productResult = productBLL.GetProductById(productId);
                
                if (productResult != null)
                {
                    return productResult;
                }
                else
                {
                    // DEBUG: Log when product is not found
                    string debugScript = "console.warn('Product not found for ID: " + productId + "');";
                    ClientScript.RegisterStartupScript(this.GetType(), "ProductNotFound", debugScript, true);
                    return null;
                }
            }
            catch (Exception ex)
            {
                // DEBUG: Log exception details
                string errorScript = "console.error('GetProductById Exception: " + HttpUtility.JavaScriptStringEncode(ex.Message) + "');";
                ClientScript.RegisterStartupScript(this.GetType(), "GetProductError", errorScript, true);
                return null;
            }
        }

        /// <summary>
        /// Safe method to generate rating stars for display
        /// </summary>
        protected string GetRatingStars(object ratingValue)
        {
            try
            {
                if (ratingValue == null || ratingValue == DBNull.Value)
                {
                    return string.Empty;
                }

                if (!int.TryParse(ratingValue.ToString(), out int rating) || rating < 1 || rating > 5)
                {
                    return string.Empty;
                }

                string stars = new string('★', rating);
                return "<div class=\"comment-rating text-warning\">" + HttpUtility.HtmlEncode(stars) + "</div>";
            }
            catch
            {
                return string.Empty;
            }
        }

        #endregion

        protected override void Render(HtmlTextWriter writer)
        {
            // Register basic event validation for the comments button
            try
            {
                Page.ClientScript.RegisterForEventValidation(btnLoadComments.UniqueID);
                
                // Register common product IDs if available
                for (int i = 1; i <= 100; i++)
                {
                    Page.ClientScript.RegisterForEventValidation(btnLoadComments.UniqueID, i.ToString());
                }
            }
            catch
            {
                // If registration fails, continue with render
            }
            
            base.Render(writer);
        }
    }
}