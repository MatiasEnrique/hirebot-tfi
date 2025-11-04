# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Hirebot-TFI is an ASP.NET Web Forms application built with C# and .NET Framework 4.8.1. This is a university project (TFI - Trabajo Final Integrador) implementing a hiring/recruitment bot system.

## Architecture

The project follows a strict 5-layer architecture pattern:

- **UI** (`Hirebot-TFI/`): Presentation layer (ASP.NET Web Forms pages, master pages, user controls)
- **Security** (`security/`): Authentication and authorization layer with role-based access control
- **BLL** (`BLL/`): Business Logic Layer implementing business rules and validation
- **DAL** (`DAL/`): Data Access Layer using raw SQL queries to stored procedures
- **Abstractions** (`ABSTRACTIONS/`): Entity definitions, DTOs, and shared classes
- **Services** (`SERVICES/`): Cross-cutting services (EncryptionService, EmailService, LogService, RecaptchaService)

**Critical Rule**: All application logic must follow this flow: `UI -> Security -> BLL -> DAL`. This path must be strictly followed for every method, even if a layer doesn't add value and acts as a pass-through.

## Development Commands

### Build and Run
- **Build solution** (from Git Bash or WSL):
  ```bash
  cmd.exe /c "\"C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe\" Hirebot-TFI.sln /p:Configuration=Debug /verbosity:minimal"
  ```
  Or use Visual Studio Build > Build Solution (Ctrl+Shift+B)
- **Restore packages**: `nuget restore Hirebot-TFI.sln` or right-click solution in Visual Studio
- **Clean rebuild**:
  ```bash
  cmd.exe /c "\"C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe\" Hirebot-TFI.sln /t:Clean,Rebuild /verbosity:minimal"
  ```
- **Run application**: Use Visual Studio F5 or Debug > Start Debugging
- **Development URL**: https://localhost:44383/ (configured in project properties)

### Database Setup
- **Create database**: Run `Database/01_CreateDatabase.sql` in SQL Server Management Studio
- **Stored procedures**: Execute SQL files in `Database/` folder in order:
  - `ProductionStoredProcedures.sql` - Product catalog operations
  - `ProductCommentStoredProcedures.sql` - Comment and rating system
  - `OrganizationStoredProcedures.sql` - Organization management
  - `ChatbotStoredProcedures.sql` - Chatbot functionality
  - `PasswordRecoveryStoredProcedures.sql` - Password reset workflow
  - `NewsAndNewsletterStoredProcedures.sql` - News and newsletter features
  - `SurveyStoredProcedures.sql` - Survey management
- **Connection string**: Update `web.config` connection string to match your SQL Server instance

### Project Structure
- Main project located in `Hirebot-TFI/` subdirectory (UI.csproj)
- Solution file: `Hirebot-TFI.sln` at root level
- Entry point: `Default.aspx` landing page
- Master pages: `Public.master` (anonymous users), `Protected.master` (authenticated users)
- Database scripts: `Database/` folder with creation and stored procedure scripts

## Technology Stack

- **Framework**: ASP.NET Web Forms (.NET Framework 4.8.1)
- **Language**: C#
- **UI Library**: Bootstrap 5.3.7
- **Database**: SQL Server (Hirebot database)
- **Security**:
  - SHA256 password encryption via EncryptionService
  - Forms authentication with 30-minute timeout
  - Google reCAPTCHA v2 for bot protection
- **Email**: SMTP integration via EmailService (configurable in web.config)
- **IDE**: Visual Studio 2022 Community with IIS Express
- **Web Server**: IIS Express on https://localhost:44383/

## Key Conventions

### Database Access
- All database operations must go through DAL layer
- Use raw SQL queries calling stored procedures only
- No ORM frameworks allowed

### UI Development  
- Use Bootstrap 5.3.7 for styling
- Follow Web Forms patterns with server controls
- All pages must be fully responsive for mobile, tablet, and desktop
- Custom color palette defined in `colors.txt`:
  - Eerie Black: #222222ff
  - Ultra Violet: #4b4e6dff  
  - Tiffany Blue: #84dcc6ff
  - Cadet Gray: #95a3b3ff
  - White: #ffffffff

### Code Organization
- Place code in appropriate architectural layer
- Follow existing namespace pattern: `Hirebot_TFI.[LayerName]`
- Use descriptive class and method names
- Password encryption should use EncryptionService.EncryptPassword()

### Multilanguage Support
- **Translation Method**: Google Translate client-side translation (NO resource files)
- **Default Language**: Spanish (all text must be written in Spanish)
- **Supported Languages**: 20 languages via Google Translate widget:
  - Spanish (es), English (en), French (fr), Portuguese (pt), German (de)
  - Italian (it), Japanese (ja), Chinese (zh-CN), Arabic (ar), Russian (ru)
  - Hindi (hi), Korean (ko), Turkish (tr), Swedish (sv), Dutch (nl)
  - Polish (pl), Thai (th), Vietnamese (vi), Finnish (fi), Danish (da)
- **Implementation**:
  - All UI text written in plain Spanish (no resource expressions)
  - Google Translate widget integrated in all master pages
  - LanguageService manages language cookies (googtrans, googtransopt)
  - BasePage.InitializeCulture() sets thread culture from cookies
  - Select2 language selector with flag emojis in navigation
- **DEPRECATED**: Resource files (GlobalResources.resx) are no longer used
  - DO NOT use `<%$ Resources:GlobalResources,KeyName %>` in ASPX
  - DO NOT use `GetGlobalResourceObject()` in code-behind
  - Write all text in Spanish; Google Translate handles conversion

## Multi-Agent Development Strategy

This project uses specialized Claude Code agents for optimal development efficiency. **Always use the appropriate agent for each task type:**

### Agent Selection Guidelines

#### 🗄️ **sql-stored-procedure-expert**
**Use for:** Database operations, stored procedures, SQL queries, data modeling
- Creating/modifying stored procedures with proper error handling
- Database schema changes and optimization
- SQL performance tuning and indexing
- Parameter validation and data integrity

#### 🏗️ **csharp-backend-architect** 
**Use for:** Backend logic, architectural compliance, layer communication
- Implementing business logic following UI → Security → BLL → DAL flow
- Creating/updating methods across architectural layers
- Ensuring SOLID principles and proper error handling
- Managing authentication, authorization, and security features
- Data access method implementation and validation

#### 🎨 **webforms-frontend-expert**
**Use for:** UI/UX development, client-side functionality, responsive design
- Creating/modifying ASP.NET Web Forms pages and controls
- Bootstrap 5.3.7 styling and responsive layouts
- JavaScript functionality and UpdatePanel coordination
- User experience optimization and accessibility
- Localization implementation in UI components

#### 🔍 **general-purpose**
**Use for:** Research, multi-step coordination, complex analysis
- Investigating complex issues requiring multiple approaches
- Coordinating between multiple agents
- File system operations and project structure analysis
- Documentation and comprehensive analysis tasks

### Agent Coordination Best Practices

#### **Proactive Agent Usage**
- Use specialized agents immediately when encountering their domain
- Don't attempt to do specialized work manually - delegate to experts
- Coordinate between agents for complex features (e.g., full-stack implementations)

#### **Implementation Synchronization**
- When using multiple agents, ensure signature consistency across layers
- Validate architectural flow compliance: UI → Security → BLL → DAL
- Test integration points between agent implementations
- Coordinate error handling and messaging across all layers

#### **ASP.NET Web Forms Specific Coordination**
- **Database + Backend**: Ensure stored procedure parameters match C# method signatures
- **Backend + Frontend**: Coordinate UpdatePanel timing and JavaScript integration
- **All Agents**: All text must be in Spanish; Google Translate handles multilanguage support

## ASP.NET Web Forms Best Practices

### Critical Technical Guidelines

#### **UpdatePanel & JavaScript Coordination**
- Always account for UpdatePanel timing issues with delayed JavaScript execution
- Use multiple update strategies: immediate + delayed (500ms) + fallback selectors
- Verify DOM elements exist before manipulation with comprehensive logging
- Ensure JavaScript doesn't prevent PostBack mechanisms

#### **Character Encoding & Localization**
- Use Unicode escape sequences for special characters (`\u2605` instead of `★`)
- All user-facing text must be written in Spanish (hardcoded, not in resource files)
- Google Translate handles client-side translation to all supported languages
- Test functionality with language switching via the Google Translate widget
- Implement proper HTML entity encoding in server controls and JavaScript
- Never use resource expressions - always use plain Spanish text

#### **Architectural Compliance**
- **Never bypass layers** - always follow UI → Security → BLL → DAL flow
- Each layer must be called in sequence even for simple operations
- Validate method signatures match between Security and BLL layers
- Handle type conversions explicitly (decimal? to double, int? to byte?)

#### **Debugging & Error Handling**
- Implement comprehensive browser console logging with visual indicators (✅, ❌, 🔄)
- Provide detailed error context for troubleshooting
- Use visual confirmation techniques during development
- Create multiple fallback strategies for critical operations

## Current State

### Implemented Features
- **Authentication**: Complete user registration, sign-in, password recovery with email verification
- **Organizations**: Multi-tenant organization management with role-based access (Owner/Admin/Member)
- **Product Catalog**: Product management with comment/rating system and moderation workflow
- **Chatbot**: AI-powered recruitment chatbot with conversation management
- **News System**: Article publishing and newsletter subscription management
- **Surveys**: Survey creation and response collection
- **Admin Dashboard**: System administration, user management, and audit logging
- **Multilanguage**: 20 languages via Google Translate (Spanish default)
- **Responsive UI**: Bootstrap 5.3.7 with mobile, tablet, and desktop layouts

### Key Pages
- **Public**: Default.aspx, SignIn.aspx, SignUp.aspx, ForgotPassword.aspx, ResetPassword.aspx
- **Protected**: Dashboard.aspx, Catalog.aspx, MyOrganizations.aspx, OrganizationView.aspx, News.aspx
- **Admin**: AdminDashboard.aspx, AdminCatalog.aspx, AdminLogs.aspx, AdminNews.aspx, AdminSurveys.aspx, ChatbotAdmin.aspx

### Configuration Notes
- **Email**: Configure SMTP settings in web.config (currently set for Gmail)
- **reCAPTCHA**: Test keys configured (replace with production keys before deployment)
- **Database**: Connection string in web.config must match your SQL Server instance
- **Culture**: Default culture is es-ES (Spanish), switchable via language selector
- **Always check .csproj files** after adding references to keep project structure consistent