using FSM.Processors;
using System;
using System.Web;

namespace FSM
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string userID = "";
            string companyID = "";

            if (Request.QueryString["companyID"] != null)
            {
                companyID = Request.QueryString["companyID"].ToString();
                HttpContext.Current.Session["CompanyID"] = companyID;
            }
            if (Request.QueryString["userID"] != null)
            {
                userID = Request.QueryString["userID"].ToString();
            }
            else
            {
                HttpContext.Current.Session["CompanyID"] = "14388";
                companyID = HttpContext.Current.Session["CompanyID"].ToString();
                userID = "location1@airmaster.com";
            }

            LoginProcessor loginProcessor = new LoginProcessor();
            if (!string.IsNullOrEmpty(companyID) && !string.IsNullOrEmpty(userID))
            {
                var isVarified = loginProcessor.VerifyUser(userID, companyID);
                if (isVarified)
                {
                    loginProcessor.LoadPrivilege(userID);
                }
            }
        }
    }
}