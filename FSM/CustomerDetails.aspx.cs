using FSM.Models.Customer;
using FSM.Models.Enums;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
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
            if (!IsPostBack)
            {
                var customerData = GetCustomerSummery(customerId);
                lblpendingAppts.Text = customerData?.PendingAppointments.ToString();
                lblscheduledAppts.Text = customerData?.ScheduledAppointments.ToString();
                lblcompletedAppts.Text = customerData?.CompletedAppointments.ToString();
                lblcustomTags.Text = "0";
                lblestimates.Text = customerData?.Estimates.ToString();
                lblopenInvoices.Text = customerData?.OpenInvoices.ToString();
                lblunpaidInvoices.Text = customerData?.UnpaidInvoices.ToString();
                lblpaidInvoices.Text = customerData?.PaidInvoices.ToString();

                var customer = GetCustomerDetails(customerId);
                lblCustomerName.Text = customer?.FirstName + " " + customer?.LastName;
                lblAddress1.Text = customer?.Address1;
                lblPhone.Text = customer?.Phone;
                lblCustomerId.Text = customerId;
            }
        }


        public static CustomerSummeryCount GetCustomerSummery(string customerId)
        {
            string companyid = HttpContext.Current.Session["CompanyID"].ToString();
            Database db = new Database();
            //customerId = "302"; //static value for testing
            string sql = "";
            var customerData = new CustomerSummeryCount();
            customerData.CompanyID = companyid;
            customerData.CustomerID = customerId;
            try
            {
                db.Open();
                DataTable dt1 = new DataTable();
                string invoiceQuery = @"select Total, AmountCollect FROM [msSchedulerV3].[dbo].[tbl_Invoice] WHERE Type = 'Invoice' AND CustomerID = @CustomerID and CompnyID=@CompanyID";
                db.AddParameter("@CompanyID", companyid, SqlDbType.NVarChar);
                db.AddParameter("@CustomerID", customerId, SqlDbType.NVarChar);
                db.ExecuteParam(invoiceQuery, out dt1);

                if (dt1.Rows.Count > 0)
                {
                    foreach(DataRow row in dt1.Rows)
                    {
                        if ((Convert.ToDouble(row["Total"].ToString()) - Convert.ToDouble(row["AmountCollect"].ToString())) <= 0)
                        {
                            customerData.PaidInvoices++;
                        }
                        else
                        {
                            customerData.UnpaidInvoices++;
                        }
                    }
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

        public static CustomerEntity GetCustomerDetails(string customerId)
        {
            string companyid = HttpContext.Current.Session["CompanyID"].ToString();
            Database db = new Database();
            var customer = new CustomerEntity();
            try
            {
                db.Open();
                DataTable dt = new DataTable();
                string sql = $@"SELECT * FROM [msSchedulerV3].[dbo].[tbl_Customer] where CustomerID = @CustomerID and CompanyID=@CompanyID;";
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
                db.Close();
            }

            return customer;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static List<CustomerAppoinment> GetCustomerAppoinmets(string customerId)
        {
            var appoinments = new List<CustomerAppoinment>();
            string companyid = HttpContext.Current.Session["CompanyID"].ToString();
            Database db = new Database();
            //customerId = "302"; // for testing purpose
            try
            {
                db.Open();
                DataTable dt = new DataTable();
                string sql = @"SELECT CONVERT(VARCHAR(10), apt.ApptDateTime, 101) AS ApptDateTimeConverted,  
                            apt.*, rsc.Name AS ResourceName, srv.ServiceName, 
                            CASE WHEN apt.Status = 'Deleted' THEN 'N/A' ELSE sts.StatusName END AS AppStatus, tkt.StatusName AS AppTicketStatus
                            FROM tbl_Appointment AS apt LEFT JOIN tbl_Resources AS rsc  ON apt.ResourceID = rsc.Id AND apt.CompanyID = rsc.CompanyID
                            LEFT JOIN tbl_ServiceType AS srv ON apt.ServiceType = srv.ServiceTypeID AND apt.CompanyID = srv.CompanyID
                            LEFT JOIN tbl_Status AS sts ON TRY_CAST(apt.Status AS INT) = sts.StatusID AND apt.CompanyID = sts.CompanyID
                            LEFT JOIN tbl_TicketStatus AS tkt ON apt.TicketStatus = tkt.StatusID AND apt.CompanyID = tkt.CompanyID
                            WHERE  apt.CustomerID='" + customerId +"' and apt.CompanyID ='"+ companyid +"';";
                db.ExecuteParam(sql, out dt);
                db.Close();
                if (dt.Rows.Count > 0)
                {
                    foreach (DataRow row in dt.Rows)
                    {
                        var appoinment = new CustomerAppoinment();
                        appoinment.CustomerID = customerId;
                        appoinment.CustomerID = companyid;
                        appoinment.AppoinmentStatus = row.Field<string>("AppStatus") ?? "";
                        appoinment.TicketStatus = row.Field<string>("AppTicketStatus") ?? "";
                        appoinment.ResourceName = row.Field<string>("ResourceName") ?? "";
                        appoinment.ServiceType = row.Field<string>("ServiceName") ?? "";
                        appoinment.RequestDate = row.Field<string>("ApptDateTimeConverted") ?? "";
                        appoinment.TimeSlot = row.Field<string>("TimeSlot") ?? "";
                        appoinment.AppoinmentDate = row.Field<string>("ApptDateTimeConverted") ?? "";

                        appoinments.Add(appoinment);
                    }
                }
            }
            catch(Exception ex)
            {
                return appoinments;
            }
            finally
            {
                db.Close();
            }
            return appoinments;
        }
    }
}