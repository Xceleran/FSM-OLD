using FSM.Processors;
using System;
using System.ComponentModel.Design;
using System.Configuration;
using System.Security.Policy;
using System.Web;

namespace FSM
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string AccountsUrl = ConfigurationManager.AppSettings["Accounts_Xinator_Url"].ToString();
            string sUrl = "UnAuthorize.aspx";

            if (Session["CompanyID"] == null)
            {
                Response.Redirect(sUrl);
            }
        }
    }
}