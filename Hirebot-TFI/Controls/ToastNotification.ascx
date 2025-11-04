<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ToastNotification.ascx.cs" Inherits="Hirebot_TFI.Controls.ToastNotification" %>

<!-- Toast Container -->
<div id="toastContainer" class="toast-container position-fixed top-0 end-0 p-3" style="z-index: 9999;"></div>

<style>
    /* Toast Container Styles */
    .toast-container {
        z-index: 9999 !important;
        max-width: 400px;
    }

    /* Base Toast Styles */
    .toast {
        border: none;
        box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
        margin-bottom: 0.75rem;
        opacity: 0;
        transform: translateX(100%);
        transition: all 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
        border-radius: 0.75rem;
        overflow: hidden;
        min-width: 320px;
    }

    /* Toast Animation States */
    .toast.showing {
        opacity: 1;
        transform: translateX(0);
    }

    .toast.hiding {
        opacity: 0;
        transform: translateX(100%);
        margin-bottom: 0;
        max-height: 0;
    }

    /* Success Toast */
    .toast.success {
        background: linear-gradient(135deg, rgba(132, 220, 198, 0.95), rgba(132, 220, 198, 0.9));
        border-left: 4px solid var(--tiffany-blue, #84dcc6);
    }

    .toast.success .toast-header {
        background: rgba(132, 220, 198, 0.2);
        border-bottom: 1px solid rgba(132, 220, 198, 0.3);
        color: var(--eerie-black, #222222);
    }

    .toast.success .toast-body {
        color: var(--eerie-black, #222222);
        font-weight: 500;
        background: rgba(255, 255, 255, 0.1);
    }

    .toast.success .btn-close {
        color: var(--eerie-black, #222222);
    }

    /* Error Toast */
    .toast.error {
        background: linear-gradient(135deg, rgba(220, 53, 69, 0.95), rgba(220, 53, 69, 0.9));
        border-left: 4px solid #dc3545;
    }

    .toast.error .toast-header {
        background: rgba(220, 53, 69, 0.2);
        border-bottom: 1px solid rgba(220, 53, 69, 0.3);
        color: white;
    }

    .toast.error .toast-body {
        color: white;
        font-weight: 500;
        background: rgba(0, 0, 0, 0.1);
    }

    .toast.error .btn-close {
        color: white;
    }

    /* Info Toast */
    .toast.info {
        background: linear-gradient(135deg, rgba(75, 78, 109, 0.95), rgba(75, 78, 109, 0.9));
        border-left: 4px solid var(--ultra-violet, #4b4e6d);
    }

    .toast.info .toast-header {
        background: rgba(75, 78, 109, 0.2);
        border-bottom: 1px solid rgba(75, 78, 109, 0.3);
        color: white;
    }

    .toast.info .toast-body {
        color: white;
        font-weight: 500;
        background: rgba(0, 0, 0, 0.1);
    }

    .toast.info .btn-close {
        color: white;
    }

    /* Warning Toast */
    .toast.warning {
        background: linear-gradient(135deg, rgba(255, 193, 7, 0.95), rgba(255, 193, 7, 0.9));
        border-left: 4px solid #ffc107;
    }

    .toast.warning .toast-header {
        background: rgba(255, 193, 7, 0.2);
        border-bottom: 1px solid rgba(255, 193, 7, 0.3);
        color: var(--eerie-black, #222222);
    }

    .toast.warning .toast-body {
        color: var(--eerie-black, #222222);
        font-weight: 500;
        background: rgba(0, 0, 0, 0.05);
    }

    .toast.warning .btn-close {
        color: var(--eerie-black, #222222);
    }

    /* Toast Header */
    .toast-header {
        padding: 0.75rem 1rem;
        border-radius: 0.75rem 0.75rem 0 0;
    }

    .toast-header .toast-icon {
        font-size: 1.1rem;
        margin-right: 0.5rem;
        font-weight: bold;
    }

    .toast-header strong {
        font-size: 0.95rem;
        font-weight: 600;
    }

    .toast-header small {
        font-size: 0.75rem;
        opacity: 0.8;
    }

    /* Toast Body */
    .toast-body {
        padding: 0.75rem 1rem;
        font-size: 0.9rem;
        line-height: 1.4;
        border-radius: 0 0 0.75rem 0.75rem;
    }

    /* Close Button */
    .toast .btn-close {
        filter: none;
        opacity: 0.7;
        background: none;
        border: none;
        font-size: 1.1rem;
        transition: opacity 0.2s ease;
        padding: 0.375rem;
        margin: -0.125rem 0;
    }

    .toast .btn-close:hover {
        opacity: 1;
        transform: scale(1.1);
    }

    /* Mobile Responsive */
    @media (max-width: 576px) {
        .toast-container {
            position: fixed !important;
            top: 1rem !important;
            left: 1rem !important;
            right: 1rem !important;
            width: auto !important;
            max-width: none !important;
            padding: 0 !important;
        }

        .toast {
            min-width: auto;
            max-width: none;
            width: 100%;
            transform: translateY(-100%);
        }

        .toast.showing {
            transform: translateY(0);
        }

        .toast.hiding {
            transform: translateY(-100%);
        }
    }

    /* High contrast mode support */
    @media (prefers-contrast: high) {
        .toast {
            border: 2px solid;
            backdrop-filter: none;
            -webkit-backdrop-filter: none;
        }
        
        .toast.success {
            background: #d4edda;
            border-color: #28a745;
        }
        
        .toast.error {
            background: #f8d7da;
            border-color: #dc3545;
        }
        
        .toast.info {
            background: #d1ecf1;
            border-color: #17a2b8;
        }
        
        .toast.warning {
            background: #fff3cd;
            border-color: #ffc107;
        }
    }

    /* Reduced motion support */
    @media (prefers-reduced-motion: reduce) {
        .toast {
            transition: opacity 0.2s ease;
            transform: none;
        }
        
        .toast.showing,
        .toast.hiding {
            transform: none;
        }
    }
</style>

<script>
    // Toast Notification System
    (function() {
        'use strict';
        
        // Toast counter for unique IDs
        let toastCounter = 0;
        
        // Configuration
        const CONFIG = {
            DEFAULT_DURATION: 5000,
            ANIMATION_DURATION: 400,
            MAX_TOASTS: 5,
            MOBILE_BREAKPOINT: 576
        };
        
        // Toast type configurations
        const TOAST_TYPES = {
            success: {
                icon: '✓',
                title: '<%= GetSuccessText() %>',
                bgClass: 'success'
            },
            error: {
                icon: '⚠',
                title: '<%= GetErrorText() %>',
                bgClass: 'error'
            },
            info: {
                icon: 'ℹ',
                title: '<%= GetInformationText() %>',
                bgClass: 'info'
            },
            warning: {
                icon: '⚠',
                title: '<%= GetWarningText() %>',
                bgClass: 'warning'
            }
        };
        
        // Get toast container
        function getToastContainer() {
            let container = document.getElementById('toastContainer');
            if (!container) {
                console.warn('⚠ Toast container not found, creating one...');
                container = document.createElement('div');
                container.id = 'toastContainer';
                container.className = 'toast-container position-fixed top-0 end-0 p-3';
                container.style.zIndex = '9999';
                document.body.appendChild(container);
            }
            return container;
        }
        
        // Clean up old toasts if limit exceeded
        function cleanupOldToasts(container) {
            const existingToasts = container.querySelectorAll('.toast:not(.hiding)');
            if (existingToasts.length >= CONFIG.MAX_TOASTS) {
                const oldestToast = existingToasts[0];
                hideToast(oldestToast);
            }
        }
        
        // Hide toast with animation
        function hideToast(toastElement) {
            if (!toastElement || toastElement.classList.contains('hiding')) return;
            
            console.log('🔄 Hiding toast:', toastElement.id);
            
            toastElement.classList.add('hiding');
            toastElement.classList.remove('showing');
            
            setTimeout(() => {
                if (toastElement.parentNode) {
                    toastElement.parentNode.removeChild(toastElement);
                    console.log('🗑️ Toast removed:', toastElement.id);
                }
            }, CONFIG.ANIMATION_DURATION);
        }
        
        // Show toast notification
        function showToast(message, type = 'info', duration = CONFIG.DEFAULT_DURATION) {
            try {
                console.log('🔔 showToast called:', { message, type, duration });
                
                // Validate parameters
                if (!message || typeof message !== 'string') {
                    console.error('❌ Invalid message:', message);
                    return null;
                }
                
                // Normalize type
                type = type.toLowerCase();
                if (type === 'danger') type = 'error';
                
                // Get type configuration
                const typeConfig = TOAST_TYPES[type] || TOAST_TYPES.info;
                
                // Get container and clean up if needed
                const container = getToastContainer();
                cleanupOldToasts(container);
                
                // Create unique toast ID
                toastCounter++;
                const toastId = 'toast-' + Date.now() + '-' + toastCounter;
                
                // Escape HTML in message
                const escapedMessage = message
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;')
                    .replace(/"/g, '&quot;')
                    .replace(/'/g, '&#39;');
                
                // Create toast HTML
                const toastHtml = `
                    <div id="${toastId}" class="toast ${typeConfig.bgClass}" role="alert" aria-live="assertive" aria-atomic="true">
                        <div class="toast-header">
                            <span class="toast-icon">${typeConfig.icon}</span>
                            <strong class="me-auto">${typeConfig.title}</strong>
                            <small class="text-muted"><%= GetNowText() %></small>
                            <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="<%= GetCloseText() %>"></button>
                        </div>
                        <div class="toast-body">
                            ${escapedMessage}
                        </div>
                    </div>
                `;
                
                // Add toast to container
                container.insertAdjacentHTML('beforeend', toastHtml);
                
                // Get the created element
                const toastElement = document.getElementById(toastId);
                if (!toastElement) {
                    console.error('❌ Failed to create toast element');
                    return null;
                }
                
                // Set up close button event
                const closeBtn = toastElement.querySelector('.btn-close');
                if (closeBtn) {
                    closeBtn.addEventListener('click', () => hideToast(toastElement));
                }
                
                // Show toast with animation
                requestAnimationFrame(() => {
                    toastElement.classList.add('showing');
                });
                
                // Auto-hide if duration specified
                if (duration > 0) {
                    setTimeout(() => {
                        hideToast(toastElement);
                    }, duration);
                }
                
                console.log('✅ Toast created successfully:', toastId);
                return toastElement;
                
            } catch (error) {
                console.error('❌ Error in showToast:', error);
                return null;
            }
        }
        
        // Global function for external access
        window.HirebotToast = {
            show: showToast,
            success: (message, duration) => showToast(message, 'success', duration),
            error: (message, duration) => showToast(message, 'error', duration),
            info: (message, duration) => showToast(message, 'info', duration),
            warning: (message, duration) => showToast(message, 'warning', duration)
        };
        
        // Legacy compatibility
        window.showToast = showToast;
        window.showToastNotification = function(message, type, title) {
            // Map old parameters to new system
            return showToast(message, type, CONFIG.DEFAULT_DURATION);
        };
        
        console.log('✅ HirebotToast system initialized');
        
    })();
</script>