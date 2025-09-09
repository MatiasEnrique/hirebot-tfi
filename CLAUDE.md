# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Hirebot-TFI is an ASP.NET Web Forms application built with C# and .NET Framework 4.8.1. This is a university project (TFI - Trabajo Final Integrador) implementing a hiring/recruitment bot system.

## Architecture

The project follows a strict 5-layer architecture pattern:

- **APP**: Presentation layer (ASP.NET Web Forms) - Currently empty/planned
- **Security**: Authentication and authorization layer - Currently empty/planned  
- **BLL**: Business Logic Layer - Currently empty/planned
- **DAL**: Data Access Layer using raw SQL queries to stored procedures - Currently empty/planned
- **Abstractions**: Entity definitions and shared classes - Currently empty/planned
- **Services**: Additional application services (e.g., EncryptionService)

**Critical Rule**: All application logic must follow this flow: `UI -> Security -> BLL -> DAL`. This path must be strictly followed for every method, even if a layer doesn't add value and acts as a pass-through.

## Development Commands

### Build and Run
- **Build solution**: `msbuild Hirebot-TFI.sln` or use Visual Studio Build > Build Solution (Ctrl+Shift+B)
- **Restore packages**: `nuget restore Hirebot-TFI.sln` or right-click solution in Visual Studio
- **Run application**: Use Visual Studio F5 or Debug > Start Debugging
- **Development URL**: https://localhost:44383/ (configured in project properties)

### Project Structure
- Main project located in `Hirebot-TFI/Hirebot-TFI/` subdirectory
- Solution file: `Hirebot-TFI.sln` at root level
- Entry point: `Default.aspx` with basic welcome page

## Technology Stack

- **Framework**: ASP.NET Web Forms (.NET Framework 4.8.1)
- **Language**: C# 
- **UI Library**: Bootstrap 5.3.7
- **Database**: SQL Server (configuration pending)
- **Security**: SHA256 password encryption via EncryptionService
- **IDE**: Visual Studio with IIS Express

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
- Application supports Spanish (default) and English
- All text resources are stored in `App_GlobalResources/GlobalResources.resx` (Spanish) and `GlobalResources.en.resx` (English)
- Use resource expressions in ASPX: `<%$ Resources:GlobalResources,KeyName %>`
- BasePage class handles culture initialization based on Session["Language"]
- Language selector available in navigation with flag icons
- Code-behind files should use `HttpContext.GetGlobalResourceObject("GlobalResources", key)` for localization

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
- **All Agents**: Maintain consistent localization keys across database, backend, and UI

## ASP.NET Web Forms Best Practices

### Critical Technical Guidelines

#### **UpdatePanel & JavaScript Coordination**
- Always account for UpdatePanel timing issues with delayed JavaScript execution
- Use multiple update strategies: immediate + delayed (500ms) + fallback selectors
- Verify DOM elements exist before manipulation with comprehensive logging
- Ensure JavaScript doesn't prevent PostBack mechanisms

#### **Character Encoding & Localization**
- Use Unicode escape sequences for special characters (`\u2605` instead of `★`)
- All user-facing text must use resource files: `<%$ Resources:GlobalResources,Key %>`
- Test functionality with both Spanish and English language switching
- Implement proper HTML entity encoding in server controls and JavaScript

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

The project has the following implemented features:
- Complete 5-layer architecture with authentication system
- User registration and sign-in functionality with SHA256 encryption
- Multilanguage support (Spanish/English) with resource files
- Fully responsive Bootstrap UI for authentication pages
- Forms authentication with session management
- Database integration using stored procedures
- BasePage class for culture initialization
- **Complete product comment system** with rating functionality, moderation workflow, and real-time updates
- **Multi-agent coordination patterns** proven through comment system implementation
- GEMINI.md contains detailed architecture documentation
- Always check the csproj after making any changes to keep references updated