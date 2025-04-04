using FSM.Models.Customer;
using FSM.Models.Enums;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace FSM
{
    public partial class CustomerDetails : System.Web.UI.Page  // Changed from 'Customer' to 'Customers'
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string customerId = Request.QueryString["custId"];
            string customerGuid = Request.QueryString["custGuid"];
            var customerData = GetCustomerSummery(customerId);
            lblpendingAppts.Text = customerData.PendingAppointments.ToString();
            lblscheduledAppts.Text = customerData.ScheduledAppointments.ToString();
            lblcompletedAppts.Text = customerData.CompletedAppointments.ToString();
            lblcustomTags.Text = "0";
            lblestimates.Text = customerData.Estimates.ToString();
            lblopenInvoices.Text = customerData.OpenInvoices.ToString();
            lblunpaidInvoices.Text = customerData.UnpaidInvoices.ToString();
            lblpaidInvoices.Text = customerData.PaidInvoices.ToString();
        }


        public static CustomerSummeryCount GetCustomerSummery(string customerId)
        {
            string companyid = HttpContext.Current.Session["CompanyID"].ToString();
            Database db = new Database();
            customerId = "302"; //static value for testing
            string sql = "";
            var customerData = new CustomerSummeryCount();
            customerData.CompanyID = companyid;
            customerData.CustomerID = customerId;
            try
            {
                db.Open();
                DataTable dt1 = new DataTable();
                string invoiceQuery = @"SELECT 
                        COUNT(CASE WHEN LoanStatus IN('LOAN CONFIRMED','SETTLED') THEN 1 END) AS PaidInvoiceCount,
                        COUNT(CASE WHEN LoanStatus IN('INITIATED', 'ACTIONS REQUIRED', 'AUTHORIZED') THEN 1 END) AS InProgressInvoiceCount
                            FROM tbl_Invoice WHERE Type = 'Invoice' AND CustomerID = @CustomerID and CompanyID=@CompanyID";
                db.AddParameter("@CompanyID", companyid, SqlDbType.NVarChar);
                db.AddParameter("@CustomerID", customerId, SqlDbType.NVarChar);
                db.ExecuteParam(invoiceQuery, out dt1);

                if (dt1.Rows.Count > 0)
                {
                    DataRow dataRow = dt1.Rows[0];
                    customerData.PaidInvoices = dataRow.Field<int?>("PaidInvoiceCount") ?? 0;
                    customerData.OpenInvoices = dataRow.Field<int?>("InProgressInvoiceCount") ?? 0;
                }

                db.Command.Parameters.Clear();
                DataTable dt2 = new DataTable();
                string estimateQuery = @"SELECT COUNT(ServiceTypeID) as EstimateCount FROM tbl_ServiceType WHERE ServiceName = 'Estimate' AND CompanyID = @CompanyID;";
                db.AddParameter("@CompanyID", companyid, SqlDbType.NVarChar);
                db.ExecuteParam(estimateQuery, out dt2);
                if (dt2.Rows.Count > 0)
                {
                    DataRow dataRow = dt2.Rows[0];
                    customerData.Estimates = dataRow.Field<int?>("EstimateCount") ?? 0;
                }


                db.Command.Parameters.Clear();
                DataTable dt3 = new DataTable();
                string appointmentQuery = @"SELECT Status FROM tbl_Appointment WHERE CompanyID = @CompanyID AND CustomerID = @CustomerID;";
                db.AddParameter("@CompanyID", companyid, SqlDbType.NVarChar);
                db.AddParameter("@CustomerID", customerId, SqlDbType.NVarChar);
                db.ExecuteParam(appointmentQuery, out dt3);
                if (dt3.Rows.Count > 0)
                {
                    foreach (DataRow row in dt3.Rows)
                    {
                        string statusStr = row.Field<string>("Status");
                        if (Enum.TryParse<WorkOrderStatus>(statusStr, out var status))
                        {
                            switch (status)
                            {
                                case WorkOrderStatus.Pending:
                                    customerData.PendingAppointments++;
                                    break;
                                case WorkOrderStatus.Scheduled:
                                    customerData.ScheduledAppointments++;
                                    break;
                                case WorkOrderStatus.Closed:
                                    customerData.CompletedAppointments++;
                                    break;
                                default:
                                    break;
                            }
                        }
                    }
                }

                db.Close();
            }

            catch (Exception ex)
            {
                db.Close();
            }
            return customerData;
        }
    }
}