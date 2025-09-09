<%@ Page Title="" Language="C#" MasterPageFile="~/Public.master" AutoEventWireup="true" CodeBehind="Catalog.aspx.cs" Inherits="UI.Catalog" EnableEventValidation="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ProductCatalog %>" /> - Hirebot-TFI
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        :root {
            --eerie-black: #222222ff;
            --ultra-violet: #4b4e6dff;  
            --tiffany-blue: #84dcc6ff;
            --cadet-gray: #95a3b3ff;
            --white: #ffffffff;
        }
        
        .btn-primary { background-color: var(--ultra-violet); border-color: var(--ultra-violet); }
        .btn-primary:hover { background-color: var(--tiffany-blue); border-color: var(--tiffany-blue); color: var(--eerie-black); }
        .btn-outline-primary { border-color: var(--ultra-violet); color: var(--ultra-violet); }
        .btn-outline-primary:hover { background-color: var(--ultra-violet); border-color: var(--ultra-violet); }
        .product-card {
            transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out;
            border: 1px solid #e0e0e0;
            border-radius: 0.5rem;
            overflow: hidden;
            padding: 1.5rem;
        }
        .product-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .product-image {
            width: 100%;
            height: 200px;
            object-fit: cover;
            background-color: #f8f9fa;
        }
        .price-tag {
            color: var(--ultra-violet);
            font-weight: bold;
            font-size: 1.25rem;
        }
        .category-badge {
            background-color: var(--tiffany-blue);
            color: var(--eerie-black);
        }
        .catalog-header {
            background: linear-gradient(135deg, var(--ultra-violet), var(--tiffany-blue));
            color: white;
            padding: 2rem 0;
            margin-bottom: 2rem;
        }
        .no-products {
            text-align: center;
            padding: 3rem 0;
            color: var(--cadet-gray);
        }
        
        /* Comments Section Styling */
        .comments-toggle {
            border: 1px solid var(--cadet-gray) !important;
            color: var(--cadet-gray) !important;
            transition: all 0.3s ease;
        }
        .comments-toggle:hover {
            background-color: var(--tiffany-blue) !important;
            border-color: var(--tiffany-blue) !important;
            color: var(--eerie-black) !important;
        }
        
        .comment-count {
            font-size: 0.75rem;
        }
        
        .product-comment-header {
            background: linear-gradient(135deg, var(--ultra-violet), var(--tiffany-blue));
            color: white;
        }
        .product-comment-header h6 {
            color: white;
            font-weight: 600;
        }
        
        .rating-stars {
            color: #ffc107;
            font-size: 1.1rem;
            letter-spacing: 2px;
        }
        
        .rating-stars-input {
            display: flex;
            gap: 0.5rem;
        }
        .rating-stars-input input[type="radio"] {
            display: none;
        }
        .rating-stars-input label {
            cursor: pointer;
            color: #dee2e6;
            font-size: 1.5rem;
            transition: color 0.2s ease;
        }
        .rating-stars-input label:hover,
        .rating-stars-input input[type="radio"]:checked + label {
            color: #ffc107;
        }
        
        .comment-item {
            transition: transform 0.2s ease;
        }
        .comment-item:hover {
            transform: translateX(5px);
        }
        
        .comment-meta h6 {
            color: var(--ultra-violet);
            font-weight: 600;
        }
        
        .comment-text {
            color: var(--eerie-black);
            line-height: 1.6;
            word-wrap: break-word;
        }
        
        .comment-rating {
            font-size: 1rem;
            letter-spacing: 1px;
        }
        
        .no-comments i {
            color: var(--cadet-gray);
            opacity: 0.5;
        }
        
        .add-comment-section .card {
            border: 2px dashed var(--cadet-gray) !important;
            transition: border-color 0.3s ease;
        }
        .add-comment-section .card:hover {
            border-color: var(--tiffany-blue) !important;
        }
        
        .login-prompt-section .card {
            background: linear-gradient(135deg, rgba(75, 78, 109, 0.1), rgba(132, 220, 198, 0.1)) !important;
        }
        
        /* Modal Enhancements */
        .modal-content {
            border: none;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }
        
        .modal-header {
            background: linear-gradient(135deg, var(--ultra-violet), var(--tiffany-blue));
            color: white;
            border-bottom: none;
        }
        
        .modal-header .btn-close {
            filter: brightness(0) invert(1);
        }
        
        .modal-title {
            font-weight: 600;
        }
        
        .modal-footer {
            border-top: 1px solid #dee2e6;
            background-color: #f8f9fa;
        }
        
        /* Responsive Design */
        @media (max-width: 768px) {
            .modal-dialog {
                margin: 0.5rem;
            }
            
            .product-comment-header {
                padding: 1rem !important;
            }
            
            .rating-stars-input {
                justify-content: center;
                flex-wrap: wrap;
            }
            
            .rating-stars-input label {
                font-size: 1.2rem;
            }
            
            .comment-item:hover {
                transform: none;
            }
        }
        
        /* Character count styling */
        .form-text {
            font-size: 0.875rem;
        }
        .text-warning {
            color: #ffc107 !important;
        }
        .text-danger {
            color: #dc3545 !important;
        }
        
        /* Loading state styling for better UX */
        .loading-state {
            position: relative;
            pointer-events: none;
            opacity: 0.7;
        }
        
        .loading-state::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(255, 255, 255, 0.8);
            z-index: 10;
            border-radius: 0.375rem;
        }
        
        /* Enhanced modal message styling */
        #modalMessageContainer .alert {
            margin-bottom: 1rem !important;
            border: none;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        #modalMessageContainer .alert-success {
            background: linear-gradient(135deg, #d4edda, #c3e6cb);
            color: #155724;
            border-left: 4px solid #28a745;
        }
        
        #modalMessageContainer .alert-danger {
            background: linear-gradient(135deg, #f8d7da, #f5c6cb);
            color: #721c24;
            border-left: 4px solid #dc3545;
        }
        
        #modalMessageContainer .alert-warning {
            background: linear-gradient(135deg, #fff3cd, #ffeaa7);
            color: #856404;
            border-left: 4px solid #ffc107;
        }
        
        /* Smooth transitions for all interactive elements */
        .btn, .form-control, .form-select {
            transition: all 0.2s ease-in-out;
        }
        
        /* Disabled button state */
        .btn:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

        <div class="catalog-header">
            <div class="container">
                <div class="row align-items-center">
                    <div class="col-lg-8">
                        <h1 class="display-4 mb-2">
                            <i class="bi bi-collection me-3"></i>
                            <asp:Literal ID="litCatalogTitle" runat="server"></asp:Literal>
                        </h1>
                        <p class="lead mb-0">
                            <asp:Literal ID="litCatalogDescription" runat="server"></asp:Literal>
                        </p>
                    </div>
                    <div class="col-lg-4 text-lg-end">
                        <div class="d-flex align-items-center justify-content-lg-end gap-3">
                            <div class="text-center">
                                <h3 class="mb-0"><asp:Literal ID="litProductCount" runat="server"></asp:Literal></h3>
                                <small><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ProductsAvailable %>" /></small>
                            </div>
                            <div class="vr d-none d-lg-block"></div>
                            <div class="text-center">
                                <asp:DropDownList ID="ddlCategories" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlCategories_SelectedIndexChanged">
                                </asp:DropDownList>
                                <small class="text-light"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,FilterByCategory %>" /></small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="container">
            <asp:Label ID="lblMessage" runat="server" CssClass="alert d-none" role="alert"></asp:Label>
            
            <div class="row">
                <asp:PlaceHolder ID="phNoCatalog" runat="server" Visible="false">
                    <div class="col-12">
                        <div class="no-products">
                            <i class="bi bi-collection display-1 text-muted mb-4"></i>
                            <h3 class="text-muted"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,NoCatalogSelected %>" /></h3>
                            <p class="text-muted"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,NoCatalogSelectedMessage %>" /></p>
                        </div>
                    </div>
                </asp:PlaceHolder>

                <asp:PlaceHolder ID="phNoProducts" runat="server" Visible="false">
                    <div class="col-12">
                        <div class="no-products">
                            <i class="bi bi-box display-1 text-muted mb-4"></i>
                            <h3 class="text-muted"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,NoProductsFound %>" /></h3>
                            <p class="text-muted"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,NoProductsFoundMessage %>" /></p>
                        </div>
                    </div>
                </asp:PlaceHolder>

                <asp:Repeater ID="rptProducts" runat="server">
                    <ItemTemplate>
                        <div class="col-lg-4 col-md-6 mb-4">
                            <div class="product-card h-100">
                                <div class="card-body d-flex flex-column">
                                    <div class="d-flex justify-content-between align-items-start mb-2">
                                        <h5 class="card-title mb-0"><%# Eval("Name") %></h5>
                                        <span class="badge category-badge"><%# Eval("Category") ?? "Basic" %></span>
                                    </div>
                                    
                                    <%# !string.IsNullOrEmpty(Eval("Description")?.ToString()) ? 
                                        $"<p class=\"card-text text-muted mb-3\" style=\"font-size: 0.9rem;\">{(Eval("Description").ToString().Length > 100 ? Eval("Description").ToString().Substring(0, 97) + "..." : Eval("Description"))}</p>" : "" %>
                                    
                                    <div class="mt-auto">
                                        <div class="mb-3">
                                            <div class="d-flex justify-content-between align-items-center mb-2">
                                                <span class="price-tag">ARS <%# string.Format("{0:N2}", Eval("Price")) %></span>
                                                <small class="text-muted">
                                                    <i class="bi bi-arrow-repeat me-1"></i>
                                                    <%# Eval("BillingCycle") ?? "Monthly" %>
                                                </small>
                                            </div>
                                            <div class="row text-center">
                                                <div class="col-6">
                                                    <small class="text-muted d-block"><i class="bi bi-robot me-1"></i><%# Eval("MaxChatbots") %> <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,BotsText %>" /></small>
                                                </div>
                                                <div class="col-6">
                                                    <small class="text-muted d-block"><i class="bi bi-chat-dots me-1"></i><%# string.Format("{0:N0}", Eval("MaxMessagesPerMonth")) %>/<asp:Literal runat="server" Text="<%$ Resources:GlobalResources,MonthText %>" /></small>
                                                </div>
                                            </div>
                                        </div>
                                        
                                        <div class="d-grid gap-2">
                                            <button type="button" class="btn btn-outline-primary" disabled>
                                                <i class="bi bi-info-circle me-1"></i>
                                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ViewDetails %>" />
                                            </button>
                                            <button type="button" class="btn btn-sm btn-light comments-toggle" onclick="toggleComments(<%# Eval("ProductId") %>)">
                                                <i class="bi bi-chat-text me-1"></i>
                                                <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Comments %>" />
                                                <span class="comment-count badge bg-secondary ms-1" data-product-id="<%# Eval("ProductId") %>">0</span>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

        <!-- Comments Modal -->
        <div class="modal fade" id="commentsModal" tabindex="-1" aria-labelledby="commentsModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-scrollable">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="commentsModalLabel">
                            <i class="bi bi-chat-text me-2"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Comments %>" />
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <!-- Product Info Header -->
                        <div class="product-comment-header mb-4 p-3 bg-light rounded">
                            <h6 class="mb-2" id="commentProductName">Product Name</h6>
                            <div class="d-flex align-items-center gap-3">
                                <div class="rating-summary">
                                    <span class="rating-stars" id="productRatingStars">&#9734;&#9734;&#9734;&#9734;&#9734;</span>
                                    <small class="text-muted ms-2">
                                        <span id="averageRating">0.0</span> 
                                        (<span id="totalComments">0</span> <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Comments %>" />)
                                    </small>
                                </div>
                            </div>
                        </div>

                        <!-- Login Prompt for anonymous users - ONLY shown when not authenticated -->

                        <!-- Login Prompt for anonymous users -->
                        <asp:PlaceHolder ID="phLoginPrompt" runat="server" Visible="false">
                            <div class="login-prompt-section mb-4">
                                <div class="card border-0 bg-light text-center">
                                    <div class="card-body py-4">
                                        <i class="bi bi-person-circle display-4 text-muted mb-3"></i>
                                        <h6 class="mb-2"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,LoginToComment %>" /></h6>
                                        <p class="text-muted mb-3"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,LoginToCommentMessage %>" /></p>
                                        <a href="SignIn.aspx" class="btn btn-primary">
                                            <i class="bi bi-box-arrow-in-right me-2"></i>
                                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,SignIn %>" />
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </asp:PlaceHolder>

                        <!-- Comments List -->
                        <asp:UpdatePanel ID="upComments" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <!-- Message display inside modal - Fixed visibility and styling -->
                                <div id="modalMessageContainer" class="mb-3">
                                    <asp:Label ID="lblModalMessage" runat="server" CssClass="alert d-none" role="alert"></asp:Label>
                                </div>

                                <!-- CRITICAL: Comment Form MUST be inside UpdatePanel for proper postback -->
                                <asp:PlaceHolder ID="phAddCommentInPanel" runat="server">
                                    <div class="add-comment-section mb-4">
                                        <h6 class="mb-3"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,AddComment %>" /></h6>
                                        <div class="card border-0 bg-light">
                                            <div class="card-body">
                                                <div class="mb-3">
                                                    <label class="form-label"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Rating %>" /></label>
                                                    <div class="rating-input">
                                                        <asp:RadioButtonList ID="rblRating" runat="server" RepeatDirection="Horizontal" CssClass="rating-stars-input">
                                                        </asp:RadioButtonList>
                                                    </div>
                                                </div>
                                                <div class="mb-3">
                                                    <asp:TextBox ID="txtComment" runat="server" TextMode="MultiLine" Rows="3" 
                                                        CssClass="form-control" placeholder="<%$ Resources:GlobalResources,WriteComment %>" 
                                                        MaxLength="1000" />
                                                    <div class="form-text">
                                                        <span id="commentCharCount">0</span>/1000 caracteres
                                                    </div>
                                                    <asp:RequiredFieldValidator ID="rfvComment" runat="server" 
                                                        ControlToValidate="txtComment" 
                                                        ErrorMessage="<%$ Resources:GlobalResources,CommentRequired %>"
                                                        CssClass="text-danger" Display="Dynamic" ValidationGroup="CommentGroup" />
                                                </div>
                                                <div class="d-grid">
                                                    <asp:Button ID="btnPostComment" runat="server" 
                                                        Text="<%$ Resources:GlobalResources,PostComment %>" 
                                                        CssClass="btn btn-primary" 
                                                        OnClick="btnPostComment_Click" 
                                                        ValidationGroup="CommentGroup" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </asp:PlaceHolder>
                                
                                <div class="comments-list">
                                    <h6 class="mb-3">
                                        <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Comments %>" />
                                        <span class="badge bg-secondary ms-2" id="commentsCount">0</span>
                                    </h6>
                                    
                                    <!-- No Comments Message -->
                                    <asp:PlaceHolder ID="phNoComments" runat="server">
                                        <div class="no-comments text-center py-5">
                                            <i class="bi bi-chat display-1 text-muted mb-3"></i>
                                            <h6 class="text-muted mb-2"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,NoComments %>" /></h6>
                                            <p class="text-muted"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,NoCommentsMessage %>" /></p>
                                        </div>
                                    </asp:PlaceHolder>

                                    <!-- Comments Repeater -->
                                    <asp:Repeater ID="rptComments" runat="server">
                                        <ItemTemplate>
                                            <div class="comment-item mb-3">
                                                <div class="card border-0 bg-light">
                                                    <div class="card-body">
                                                        <div class="d-flex justify-content-between align-items-start mb-2">
                                                            <div class="comment-meta">
                                                                <h6 class="mb-1">
                                                                    <i class="bi bi-person-circle me-2 text-muted"></i>
                                                                    <%# Eval("Username") %>
                                                                </h6>
                                                                <small class="text-muted">
                                                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,CommentOn %>" />
                                                                    <%# ((DateTime)Eval("CreatedDate")).ToString("dd/MM/yyyy HH:mm") %>
                                                                </small>
                                                            </div>
                                                            <%# GetRatingStars(Eval("Rating")) %>
                                                        </div>
                                                        <p class="comment-text mb-0"><%# Eval("CommentText") %></p>
                                                    </div>
                                                </div>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                            </ContentTemplate>
                            <Triggers>
                                <asp:AsyncPostBackTrigger ControlID="btnLoadComments" EventName="Click" />
                            </Triggers>
                        </asp:UpdatePanel>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Cancel %>" />
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Hidden fields for JavaScript -->
        <asp:HiddenField ID="hfSelectedProductId" runat="server" />

        <script>
            // Function to toggle comments modal
            function toggleComments(productId) {
                try {
                    // Validate productId
                    if (!productId || isNaN(productId) || productId <= 0) {
                        return;
                    }
                    
                    // Store product ID
                    document.getElementById('<%= hfSelectedProductId.ClientID %>').value = productId;
                    
                    // Show modal first for better UX
                    var modal = new bootstrap.Modal(document.getElementById('commentsModal'));
                    modal.show();
                    
                    // Load comments for the product
                    loadProductComments(productId);
                    
                    // Additional safety update after modal is fully shown
                    setTimeout(function() {
                        updateCommentsCountFromRepeater();
                    }, 300);
                    
                } catch (e) {
                }
            }

            // Function to load product comments via AJAX
            function loadProductComments(productId) {
                try {
                    // Set loading state
                    updateLoadingState(true);
                    
                    // Store product ID in hidden field before postback
                    var hiddenField = document.getElementById('<%= hfSelectedProductId.ClientID %>');
                    if (hiddenField) {
                        hiddenField.value = productId;
                    }
                    
                    // Trigger postback with proper event validation
                    if (typeof __doPostBack === 'function') {
                        __doPostBack('<%= btnLoadComments.UniqueID %>', productId.toString());
                    } else {
                        updateLoadingState(false);
                    }
                } catch (e) {
                    updateLoadingState(false);
                }
            }
            
            // Helper function to manage loading states
            function updateLoadingState(isLoading) {
                var elements = [
                    document.getElementById('commentsCount'),
                    document.getElementById('averageRating'),
                    document.getElementById('totalComments')
                ];
                
                elements.forEach(function(element) {
                    if (element) {
                        element.textContent = isLoading ? '...' : '0';
                    }
                });
            }

            // Enhanced character counter for comment text
            function initializeCharacterCounter() {
                try {
                    const commentTextBox = document.getElementById('<%= txtComment.ClientID %>');
                    const charCount = document.getElementById('commentCharCount');
                    
                    if (commentTextBox && charCount) {
                        // Initialize character count
                        const updateCharCount = function() {
                            const length = commentTextBox.value ? commentTextBox.value.length : 0;
                            charCount.textContent = length;
                            
                            // Update styling based on character count
                            charCount.classList.remove('text-warning', 'text-danger');
                            if (length > 900 && length < 1000) {
                                charCount.classList.add('text-warning');
                            } else if (length >= 1000) {
                                charCount.classList.add('text-danger');
                            }
                        };
                        
                        // Set initial count
                        updateCharCount();
                        
                        // Remove existing event listeners to prevent duplicates
                        commentTextBox.removeEventListener('input', updateCharCount);
                        commentTextBox.addEventListener('input', updateCharCount);
                        
                        // Clear validation messages when user starts typing
                        commentTextBox.addEventListener('input', function() {
                            try {
                                hideModalMessage();
                            } catch (e) {
                                }
                        });
                    }
                } catch (e) {
                }
            }
            
            // Initialize on page load
            document.addEventListener('DOMContentLoaded', function() {
                initializeCharacterCounter();
            });

            // Enhanced rating stars interaction
            function initializeRatingStars() {
                try {
                    const ratingInputs = document.querySelectorAll('input[name*="rblRating"]');
                    if (ratingInputs.length === 0) return;
                    
                    ratingInputs.forEach(function(input, index) {
                        if (!input) return;
                        
                        // Remove existing listeners to prevent duplicates
                        input.removeEventListener('change', handleRatingChange);
                        input.addEventListener('change', function() {
                            handleRatingChange(index + 1);
                        });
                        
                        // Add hover effects with safety checks
                        if (input.parentElement) {
                            input.parentElement.addEventListener('mouseenter', function() {
                                highlightStarsOnHover(index + 1);
                            });
                            
                            input.parentElement.addEventListener('mouseleave', function() {
                                resetStarsAfterHover();
                            });
                        }
                    });
                } catch (e) {
                }
            }
            
            function handleRatingChange(rating) {
                try {
                    // Update visual feedback for rating selection
                    updateRatingStars(rating);
                    
                    // Clear validation messages when user selects rating
                    hideModalMessage();
                } catch (e) {
                }
            }
            
            // Initialize on page load
            document.addEventListener('DOMContentLoaded', function() {
                initializeRatingStars();
            });

            function updateRatingStars(rating) {
                try {
                    // Update the visual representation of selected rating
                    const ratingInputs = document.querySelectorAll('input[name*="rblRating"]');
                    if (!ratingInputs || ratingInputs.length === 0) return;
                    
                    ratingInputs.forEach(function(input, index) {
                        if (!input) return;
                        const label = input.nextElementSibling;
                        if (label) {
                            if (index < rating) {
                                label.style.color = '#ffc107';
                            } else {
                                label.style.color = '#dee2e6';
                            }
                        }
                    });
                } catch (e) {
                }
            }

            function highlightStarsOnHover(rating) {
                try {
                    const ratingInputs = document.querySelectorAll('input[name*="rblRating"]');
                    if (!ratingInputs || ratingInputs.length === 0) return;
                    
                    ratingInputs.forEach(function(input, index) {
                        if (!input) return;
                        const label = input.nextElementSibling;
                        if (label) {
                            if (index < rating) {
                                label.style.color = '#ffc107';
                            } else {
                                label.style.color = '#dee2e6';
                            }
                        }
                    });
                } catch (e) {
                }
            }

            function resetStarsAfterHover() {
                try {
                    const ratingInputs = document.querySelectorAll('input[name*="rblRating"]');
                    if (!ratingInputs || ratingInputs.length === 0) return;
                    
                    let selectedRating = 0;
                    ratingInputs.forEach(function(input, index) {
                        if (input && input.checked) {
                            selectedRating = index + 1;
                        }
                    });
                    updateRatingStars(selectedRating);
                } catch (e) {
                }
            }

            // Enhanced form submission feedback with better UX
            document.addEventListener('DOMContentLoaded', function() {
                try {
                    const postButton = document.getElementById('<%= btnPostComment.ClientID %>');
                    const originalButtonText = 'Post Comment';
                    
                    if (postButton) {
                        // Store original text
                        const originalText = postButton.innerHTML;
                        
                        postButton.addEventListener('click', function(e) {
                            try {
                                // Clear any existing messages
                                hideModalMessage();
                                
                                // Show loading state immediately
                                this.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>Posting...';
                                this.disabled = true;
                                
                                // Add loading class to form for visual feedback
                                const form = this.closest('.card-body');
                                if (form) {
                                    form.classList.add('loading-state');
                                }
                                
                                // Reset button after timeout (safety net)
                                setTimeout(function() {
                                    try {
                                        if (postButton.disabled) {
                                            resetPostButton();
                                        }
                                    } catch (e) {
                                    }
                                }, 15000);
                                
                                // CRITICAL: Allow the postback to proceed - don't return false
                                
                            } catch (e) {
                                resetPostButton();
                            }
                        });
                        
                        // Function to reset button state
                        window.resetPostButton = function() {
                            try {
                                postButton.disabled = false;
                                postButton.innerHTML = originalText;
                                
                                const form = postButton.closest('.card-body');
                                if (form) {
                                    form.classList.remove('loading-state');
                                }
                            } catch (e) {
                            }
                        };
                    }
                } catch (e) {
                }
            });
            
            // Global functions for message handling
            function showModalMessage(message, type) {
                try {
                    const messageLabel = document.getElementById('<%= lblModalMessage.ClientID %>');
                    if (messageLabel) {
                        messageLabel.textContent = message;
                        messageLabel.className = 'alert alert-' + type + ' mb-3';
                        
                        // Scroll message into view
                        messageLabel.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
                        
                        // Auto-hide success messages
                        if (type === 'success') {
                            setTimeout(function() {
                                hideModalMessage();
                            }, 5000);
                        }
                    }
                } catch (e) {
                }
            }
            
            function hideModalMessage() {
                try {
                    const messageLabel = document.getElementById('<%= lblModalMessage.ClientID %>');
                    if (messageLabel) {
                        messageLabel.classList.add('d-none');
                    }
                } catch (e) {
                }
            }
            
            // Enhanced modal behavior for better UX
            function ensureModalStaysOpen() {
                try {
                    const modal = document.getElementById('commentsModal');
                    if (modal) {
                        const bsModal = bootstrap.Modal.getInstance(modal) || new bootstrap.Modal(modal, {
                            backdrop: 'static',
                            keyboard: true
                        });
                        
                        if (!modal.classList.contains('show')) {
                            bsModal.show();
                        }
                        
                        // Reset form loading state after successful submission
                        if (window.resetPostButton) {
                            setTimeout(window.resetPostButton, 500);
                        }
                        
                        // Ensure form is properly reset after successful submission
                        resetCommentForm();
                    }
                } catch (e) {
                }
            }
            
            // Function to reset comment form completely
            function resetCommentForm() {
                try {
                    const commentTextBox = document.getElementById('<%= txtComment.ClientID %>');
                    const charCount = document.getElementById('commentCharCount');
                    const ratingInputs = document.querySelectorAll('input[name*="rblRating"]');
                    
                    // Reset text area
                    if (commentTextBox) {
                        commentTextBox.value = '';
                        if (charCount) {
                            charCount.textContent = '0';
                            charCount.classList.remove('text-warning', 'text-danger');
                        }
                    }
                    
                    // Reset rating selection
                    ratingInputs.forEach(function(input) {
                        if (input) {
                            input.checked = false;
                            const label = input.nextElementSibling;
                            if (label) {
                                label.style.color = '#dee2e6';
                            }
                        }
                    });
                    
                    // Reset form visual state
                    const form = commentTextBox ? commentTextBox.closest('.card-body') : null;
                    if (form) {
                        form.classList.remove('loading-state');
                    }
                    
                } catch (e) {
                }
            }
            
            // Listen for UpdatePanel completion to handle post-submission actions
            if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function(sender, args) {
                    try {
                        // Check if this was a comment-related postback
                        const updatePanelId = args.get_panelsUpdated();
                        if (updatePanelId && updatePanelId.length > 0) {
                            // Ensure modal stays open after UpdatePanel refresh
                            setTimeout(function() {
                                ensureModalStaysOpen();
                                
                                // Re-initialize any dynamic behaviors
                                initializeCharacterCounter();
                                initializeRatingStars();
                                
                                // CRITICAL: Force update comments count badge after UpdatePanel refresh
                                updateCommentsCountFromRepeater();
                            }, 100);
                        }
                    } catch (e) {
                    }
                });
            }
            
            // CRITICAL FIX: Function to update comments count by counting actual DOM elements
            function updateCommentsCountFromRepeater() {
                try {
                    
                    // Count actual comment items in the DOM
                    var commentItems = document.querySelectorAll('.comment-item');
                    var actualCount = commentItems.length;
                    
                    
                    // Get the badge element
                    var badgeElement = document.getElementById('commentsCount');
                    
                    if (badgeElement) {
                        var currentBadgeValue = badgeElement.textContent;
                        badgeElement.textContent = actualCount.toString();
                        
                        
                        // Visual confirmation for debugging (remove in production)
                        badgeElement.style.backgroundColor = '#28a745'; // Green to show it was updated
                        setTimeout(function() {
                            badgeElement.style.backgroundColor = ''; // Reset to default
                        }, 1000);
                    } else {
                        
                        // Last resort: try to find any badge element in the modal
                        var allBadges = document.querySelectorAll('#commentsModal .badge');
                        
                        if (allBadges.length > 0) {
                            allBadges[0].textContent = actualCount.toString();
                        }
                    }
                    
                } catch (e) {
                }
            }
        </script>

        <!-- Hidden button for AJAX-like postback -->
        <asp:Button ID="btnLoadComments" runat="server" OnClick="btnLoadComments_Click" style="display:none;" />

</asp:Content>