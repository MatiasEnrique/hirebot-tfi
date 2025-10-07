<%@ Page Title="Dashboard - Hirebot-TFI" Language="C#" MasterPageFile="~/Protected.master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Hirebot_TFI.Dashboard" %>
<%@ Register Src="~/Controls/SurveyDisplay.ascx" TagPrefix="uc" TagName="SurveyDisplay" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Dashboard - Hirebot-TFI
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .welcome-header {
            background: var(--ultra-violet);
            color: white;
            border-radius: 10px;
            padding: 1.5rem;
            margin-bottom: 2rem;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="content-card">
                    <div class="welcome-header text-center">
                        <h1><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Welcome %>" /></h1>
                        <h3><asp:Label ID="lblUserName" runat="server"></asp:Label></h3>
                        <p class="mb-0"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,DashboardWelcomeMessage %>" /></p>
                    </div>

                    <div class="row mb-4">
                        <div class="col-12">
                            <uc:SurveyDisplay ID="SurveyDisplayControl" runat="server" />
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-4 mb-4">
                            <div class="card border-0 shadow-sm">
                                <div class="card-body text-center">
                                    <div class="text-primary mb-3">
                                        <i class="fas fa-user-plus fa-3x"></i>
                                    </div>
                                    <h5 class="card-title"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Profile %>" /></h5>
                                    <p class="card-text"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ManageProfile %>" /></p>
                                    <asp:Button ID="btnProfile" runat="server" CssClass="btn btn-primary" 
                                        Text="<%$ Resources:GlobalResources,ViewProfile %>" OnClick="btnProfile_Click" />
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4 mb-4">
                            <div class="card border-0 shadow-sm">
                                <div class="card-body text-center">
                                    <div class="text-success mb-3">
                                        <i class="fas fa-briefcase fa-3x"></i>
                                    </div>
                                    <h5 class="card-title"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Jobs %>" /></h5>
                                    <p class="card-text"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,BrowseJobs %>" /></p>
                                    <asp:Button ID="btnJobs" runat="server" CssClass="btn btn-success" 
                                        Text="<%$ Resources:GlobalResources,ViewJobs %>" OnClick="btnJobs_Click" />
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4 mb-4">
                            <div class="card border-0 shadow-sm">
                                <div class="card-body text-center">
                                    <div class="text-info mb-3">
                                        <i class="fas fa-robot fa-3x"></i>
                                    </div>
                                    <h5 class="card-title"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,HirebotChat %>" /></h5>
                                    <p class="card-text"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,ChatWithBot %>" /></p>
                                    <asp:Button ID="btnChat" runat="server" CssClass="btn btn-info" 
                                        Text="<%$ Resources:GlobalResources,StartChat %>" OnClick="btnChat_Click" />
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row mt-4">
                        <div class="col-12">
                            <div class="card border-0 shadow-sm">
                                <div class="card-header bg-light">
                                    <h5 class="mb-0"><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,UserInfo %>" /></h5>
                                </div>
                                <div class="card-body">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <p><strong><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Username %>" />:</strong> <asp:Label ID="lblUsernameInfo" runat="server"></asp:Label></p>
                                            <p><strong><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,Email %>" />:</strong> <asp:Label ID="lblEmail" runat="server"></asp:Label></p>
                                        </div>
                                        <div class="col-md-6">
                                            <p><strong><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,FirstName %>" />:</strong> <asp:Label ID="lblFirstName" runat="server"></asp:Label></p>
                                            <p><strong><asp:Literal runat="server" Text="<%$ Resources:GlobalResources,LastName %>" />:</strong> <asp:Label ID="lblLastName" runat="server"></asp:Label></p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
    </div>
</asp:Content>