using FSM.Models.Customer;
using System;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace FSM
{
    public partial class CustomerDetails : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string customerId = Request.QueryString["custId"];
            string customerGuid = Request.QueryString["custGuid"];
            if (!IsPostBack)
            {
                var customer = GetCustomerDetails(customerId);
                lblCustomerName.Text = customer?.FirstName + " " + customer?.LastName;
                lblAddress1.Text = customer?.Address1;
                lblPhone.Text = customer?.Phone;
            }
        }

        public static CustomerEntity GetCustomerDetails(string customerId)
        {
            // Check if session and CompanyID exist
            if (HttpContext.Current?.Session == null || HttpContext.Current.Session["CompanyID"] == null)
            {
                // Log the issue or handle it (e.g., return empty customer)
                return new CustomerEntity();
            }

            string companyid = HttpContext.Current.Session["CompanyID"].ToString();
            Database db = new Database();
            var customer = new CustomerEntity();
            try
            {
                db.Open();
                DataTable dt = new DataTable();
                string sql = @"SELECT * FROM [msSchedulerV3].[dbo].[tbl_Customer] WHERE CustomerID = @CustomerID AND CompanyID = @CompanyID;";
                db.AddParameter("@CompanyID", companyid, SqlDbType.NVarChar);
                db.AddParameter("@CustomerID", customerId, SqlDbType.NVarChar);
                db.ExecuteParam(sql, out dt);
                db.Close();
                if (dt.Rows.Count > 0)
                {
                    DataRow dataRow = dt.Rows[0];
                    customer.BusinessID = dataRow.Field<int?>("BusinessID") ?? 0;
                    customer.CustomerGuid = dataRow.Field<string>("CustomerGuid") ?? "";
                    customer.Address1 = dataRow.Field<string>("Address1") ?? "";
                    customer.Address2 = dataRow.Field<string>("Address2") ?? "";
                    customer.FirstName = dataRow.Field<string>("FirstName") ?? "";
                    customer.LastName = dataRow.Field<string>("LastName") ?? "";
                    customer.Phone = dataRow.Field<string>("Phone") ?? "";
                    customer.Mobile = dataRow.Field<string>("Mobile") ?? "";
                    customer.CompanyName = dataRow.Field<string>("CompanyName") ?? "";
                    customer.Email = dataRow.Field<string>("Email") ?? "";
                }
            }
            catch (Exception ex)
            {
                // Log the exception (optional)
                System.Diagnostics.Debug.WriteLine($"Error in GetCustomerDetails: {ex.Message}");
                db.Close();
            }

            return customer;
        }
    }
}