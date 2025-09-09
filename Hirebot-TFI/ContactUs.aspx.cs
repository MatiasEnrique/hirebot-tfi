using System;

namespace Hirebot_TFI
{
    public partial class ContactUs : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Authentication and language logic is now handled by Public.master
        }

        protected void btnSendMessage_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                // Here you would typically send the email or save to database
                // For this demo, we'll just show a success message
                
                // Clear form fields
                txtFirstName.Text = "";
                txtLastName.Text = "";
                txtEmail.Text = "";
                txtPhone.Text = "";
                txtCompany.Text = "";
                txtSubject.Text = "";
                txtMessage.Text = "";
                
                // Show success message
                pnlSuccess.Visible = true;
            }
        }
    }
}