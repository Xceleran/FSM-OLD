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

            else
            {
                HttpContext.Current.Session["CompanyID"] = "7369";
            }
        }
    }
}