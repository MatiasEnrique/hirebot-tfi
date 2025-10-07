<%@ Page Title="" Language="C#" MasterPageFile="~/Public.master" AutoEventWireup="true" CodeBehind="FAQ.aspx.cs" Inherits="Hirebot_TFI.FAQ" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,FAQPageTitle %>" /> - Hirebot-TFI
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .faq-hero {
            background: linear-gradient(135deg, var(--tiffany-blue), var(--ultra-violet));
            color: white;
            padding: 80px 0 60px 0;
        }

        .faq-section-title {
            color: var(--ultra-violet);
            border-bottom: 3px solid var(--tiffany-blue);
            display: inline-block;
            padding-bottom: 12px;
        }

        .faq-accordion .accordion-button {
            font-weight: 600;
            color: var(--eerie-black);
        }

        .faq-accordion .accordion-button:not(.collapsed) {
            color: var(--ultra-violet);
            background-color: rgba(132, 220, 198, 0.15);
        }

        .faq-accordion .accordion-body {
            line-height: 1.7;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
        <div class="faq-hero">
            <div class="container text-center">
                <h1 class="display-4 fw-bold mb-3">
                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,FAQHeroTitle %>" />
                </h1>
                <p class="lead mb-0">
                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,FAQHeroSubtitle %>" />
                </p>
            </div>
        </div>

        <div class="container py-5">
            <div class="row justify-content-center mb-5">
                <div class="col-lg-8 text-center">
                    <h2 class="faq-section-title mb-4">
                        <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,FAQSectionHeading %>" />
                    </h2>
                    <p class="text-muted">
                        <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,FAQSectionDescription %>" />
                    </p>
                </div>
            </div>

            <div class="row justify-content-center">
                <div class="col-lg-10">
                    <div class="accordion faq-accordion" id="faqAccordion">
                        <div class="accordion-item mb-3">
                            <h2 class="accordion-header" id="faqHeadingOne">
                                <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#faqCollapseOne" aria-expanded="true" aria-controls="faqCollapseOne">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,FAQQuestionOne %>" />
                                </button>
                            </h2>
                            <div id="faqCollapseOne" class="accordion-collapse collapse show" aria-labelledby="faqHeadingOne" data-bs-parent="#faqAccordion">
                                <div class="accordion-body">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,FAQAnswerOne %>" />
                                </div>
                            </div>
                        </div>

                        <div class="accordion-item mb-3">
                            <h2 class="accordion-header" id="faqHeadingTwo">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faqCollapseTwo" aria-expanded="false" aria-controls="faqCollapseTwo">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,FAQQuestionTwo %>" />
                                </button>
                            </h2>
                            <div id="faqCollapseTwo" class="accordion-collapse collapse" aria-labelledby="faqHeadingTwo" data-bs-parent="#faqAccordion">
                                <div class="accordion-body">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,FAQAnswerTwo %>" />
                                </div>
                            </div>
                        </div>

                        <div class="accordion-item mb-3">
                            <h2 class="accordion-header" id="faqHeadingThree">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faqCollapseThree" aria-expanded="false" aria-controls="faqCollapseThree">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,FAQQuestionThree %>" />
                                </button>
                            </h2>
                            <div id="faqCollapseThree" class="accordion-collapse collapse" aria-labelledby="faqHeadingThree" data-bs-parent="#faqAccordion">
                                <div class="accordion-body">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,FAQAnswerThree %>" />
                                </div>
                            </div>
                        </div>

                        <div class="accordion-item mb-3">
                            <h2 class="accordion-header" id="faqHeadingFour">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faqCollapseFour" aria-expanded="false" aria-controls="faqCollapseFour">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,FAQQuestionFour %>" />
                                </button>
                            </h2>
                            <div id="faqCollapseFour" class="accordion-collapse collapse" aria-labelledby="faqHeadingFour" data-bs-parent="#faqAccordion">
                                <div class="accordion-body">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,FAQAnswerFour %>" />
                                </div>
                            </div>
                        </div>

                        <div class="accordion-item mb-3">
                            <h2 class="accordion-header" id="faqHeadingFive">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faqCollapseFive" aria-expanded="false" aria-controls="faqCollapseFive">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,FAQQuestionFive %>" />
                                </button>
                            </h2>
                            <div id="faqCollapseFive" class="accordion-collapse collapse" aria-labelledby="faqHeadingFive" data-bs-parent="#faqAccordion">
                                <div class="accordion-body">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,FAQAnswerFive %>" />
                                </div>
                            </div>
                        </div>

                        <div class="accordion-item">
                            <h2 class="accordion-header" id="faqHeadingSix">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faqCollapseSix" aria-expanded="false" aria-controls="faqCollapseSix">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,FAQQuestionSix %>" />
                                </button>
                            </h2>
                            <div id="faqCollapseSix" class="accordion-collapse collapse" aria-labelledby="faqHeadingSix" data-bs-parent="#faqAccordion">
                                <div class="accordion-body">
                                    <asp:Literal runat="server" Text="<%$ Resources:GlobalResources,FAQAnswerSix %>" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
</asp:Content>
