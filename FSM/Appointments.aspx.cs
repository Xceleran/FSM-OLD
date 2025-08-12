using FSM.Helper;
using FSM.Entity.Appoinments;
using FSM.Entity.Customer;
using System;
using System.Collections.Generic;
using System.ComponentModel.Design;
using System.Data;
using System.Linq;
using System.Net.NetworkInformation;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using FSM.Models.AppoinmentModel;
using System.Configuration;
using FSM.Processors;
using FSM.Entity.Forms;

namespace FSM
{
    public partial class Appointments : System.Web.UI.Page
    {
        string CompanyID = "";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["CompanyID"] == null)
            {
                Response.Redirect("Dashboard.aspx");
            }
            string customerId = Request.QueryString["custId"];
            string siteId = Request.QueryString["siteId"];

            if (!IsPostBack)
            {
                var customer = GetCustomerDetails(customerId);
                var site = GetCustomerSitebyId(customerId, Convert.ToInt32(siteId));

                // Setting values for the Basic Information table
                lblCustomerName.Text = customer?.FirstName + " " + customer?.LastName;
                lblCustomerGuid.Text = customer?.CustomerGuid;
                lblAddress.Text = site?.Address;
                lblContact.Text = site?.Contact;
                lblCustomerId.Text = customerId;
                lblSiteId.Text = siteId;
                lblActive.Text = site?.IsActive == true ? "Active" : "Disabled";
                lblNote.Text = site?.Note;
                lblCreatedOn.Text = site?.CreatedDateTime?.ToString("yyyy-MM-dd");

                hlPhone.Text = customer?.Phone;
                hlPhone.NavigateUrl = "tel:" + customer?.Phone;

                hlMobile.Text = customer?.Mobile;
                hlMobile.NavigateUrl = "tel:" + customer?.Mobile;

                hlEmail.Text = customer?.Email;
                hlEmail.NavigateUrl = "mailto:" + customer?.Email;

                LoadData();
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static List<AppointmentModel> LoadAppoinments(string searchValue,
            string fromDate,
            string toDate, string today)
        {
            var appoinments = new List<AppointmentModel>();
            string companyid = HttpContext.Current.Session["CompanyID"].ToString();
            Database db = new Database();
            try
            {
                string whereCondition = "WHERE  apt.CompanyID = '" + companyid + "' ";
                if (!string.IsNullOrEmpty(searchValue))
                {
                    whereCondition += "AND (BusinessName LIKE '%" + searchValue + "%' OR FirstName LIKE '%" + searchValue + "%' " +
                        "OR LastName LIKE '%" + searchValue + "%'  OR ServiceName LIKE '%" + searchValue + "%' OR rs.Name LIKE '%" + searchValue + "%' " +
                        "OR cus.Mobile LIKE '%" + searchValue + "%' OR cus.Phone LIKE '%" + searchValue + "%' OR Address1 LIKE '%" + searchValue + "%') ";
                }
                if (!string.IsNullOrEmpty(today))
                {
                    whereCondition += "AND CONVERT(VARCHAR(10), apt.ApptDateTime, 120) = '" + today + "' ";
                }
                if (!string.IsNullOrEmpty(fromDate) && !string.IsNullOrEmpty(toDate))
                {
                    whereCondition += "AND CONVERT(DATE, apt.ApptDateTime) BETWEEN '" + fromDate + "' AND '" + toDate + "' ";
                }
                db.Open();
                DataTable dt = new DataTable();

                string sql = $@"SELECT  cus.FirstName, cus.LastName,cus.CustomerGuid, cus.BusinessID, cus.BusinessName, cus.IsBusinessContact, 
                               cus.CustomerID, cus.Email, cus.Phone, cus.Mobile, cus.ZipCode, cus.State, cus.City, cus.Address1,
                               apt.CompanyID, apt.ApptID, apt.ResourceID, apt.ServiceType, apt.CreatedDateTime, CONVERT(VARCHAR(10), 
                               apt.ApptDateTime, 120) as RequestDate, apt.Note, apt.TimeSlot,apt.StartDateTime, apt.EndDateTime,
                               rs.Name as ResourceName, srv.ServiceName, CASE WHEN apt.Status = 'Deleted' THEN 'N/A' ELSE sts.StatusName END AS AppStatus, 
                               tkt.StatusName AS AppTicketStatus FROM tbl_Appointment apt
                               inner JOIN tbl_Customer cus ON apt.CustomerID = cus.CustomerID and apt.CompanyID = cus.CompanyID
                               LEFT JOIN tbl_Resources as rs on apt.ResourceID = rs.Id and apt.CompanyID = rs.CompanyID
                               LEFT JOIN tbl_ServiceType AS srv ON apt.ServiceType = srv.ServiceTypeID AND apt.CompanyID = srv.CompanyID
                               LEFT JOIN tbl_Status AS sts ON TRY_CAST(apt.Status AS INT) = sts.StatusID AND apt.CompanyID = sts.CompanyID
                               LEFT JOIN tbl_TicketStatus AS tkt ON apt.TicketStatus = tkt.StatusID AND apt.CompanyID = tkt.CompanyID {whereCondition}";


                db.Execute(sql, out dt);
                db.Close();
                if (dt.Rows.Count > 0)
                {
                    foreach (DataRow row in dt.Rows)
                    {
                        var appoinment = new AppointmentModel();
                        appoinment.CompanyID = companyid;
                        appoinment.CustomerGuid = row.Field<string>("CustomerGuid") ?? "";
                        appoinment.CustomerID = row["CustomerID"].ToString();
                        appoinment.FirstName = row.Field<string>("FirstName") ?? "";
                        appoinment.LastName = row.Field<string>("LastName") ?? "";
                        appoinment.BusinessID = row.Field<int?>("BusinessID") ?? 0;
                        appoinment.BusinessName = row.Field<string>("BusinessName") ?? "";
                        appoinment.IsBusinessContact = row.Field<bool?>("IsBusinessContact") ?? false;
                        appoinment.Phone = row.Field<string>("Phone") ?? "";
                        appoinment.Mobile = row.Field<string>("Mobile") ?? "";
                        appoinment.ZipCode = row.Field<string>("ZipCode") ?? "";
                        appoinment.State = row.Field<string>("State") ?? "";
                        appoinment.City = row.Field<string>("City") ?? "";
                        appoinment.Address1 = row.Field<string>("Address1") ?? "";
                        appoinment.Email = row.Field<string>("Email") ?? "";

                        appoinment.CustomerName = row.Field<string>("FirstName") + " " + row.Field<string>("LastName");

                        appoinment.AppoinmentId = row["ApptID"].ToString();
                        appoinment.AppoinmentStatus = row.Field<string>("AppStatus") ?? "";
                        appoinment.Note = row.Field<string>("Note") ?? "";
                        appoinment.TicketStatus = row.Field<string>("AppTicketStatus") ?? "";
                        appoinment.ResourceName = row.Field<string>("ResourceName") ?? "";
                        appoinment.ServiceType = row.Field<string>("ServiceName") ?? "";
                        appoinment.RequestDate = row.Field<string>("RequestDate") ?? "";
                        appoinment.TimeSlot = row.Field<string>("TimeSlot") ?? "";
                        appoinment.AppoinmentDate = row.Field<string>("RequestDate") ?? "";
                        appoinment.StartDateTime = Convert.ToDateTime(row["StartDateTime"]).ToString("MM/dd/yyyy hh:mm tt");
                        appoinment.EndDateTime = Convert.ToDateTime(row["EndDateTime"]).ToString("MM/dd/yyyy hh:mm tt");

                        int serviceTypeID = Convert.ToInt32(row.Field<string>("ServiceType"));
                        appoinment.Duration = CalculateDuration(serviceTypeID);
                        appoinments.Add(appoinment);
                    }
                }
            }
            catch (Exception ex)
            {
                return appoinments;
            }
            finally
            {
                db.Close();
            }
            return appoinments;
        }


        public void LoadData()
        {
            string companyid = HttpContext.Current.Session["CompanyID"].ToString();
            Database db = new Database();
            try
            {
                string Sql = "SELECT ServiceTypeID,ServiceName From msSchedulerV3.dbo.tbl_ServiceType where CompanyID = '" + companyid + "' order by ServiceName asc;";
                Sql += @"SELECT  [StatusID],[StatusName] FROM [msSchedulerV3].[dbo].[tbl_Status] where CompanyID='" + companyid + "';";
                Sql += @"SELECT  [StatusID],[StatusName] FROM [msSchedulerV3].[dbo].[tbl_TicketStatus] where CompanyID= '" + companyid + "';";

                DataTable _ServiceType = new DataTable();
                DataTable _Status = new DataTable();
                DataTable _ticketStatus = new DataTable();
                DataSet dataSet = db.Get_DataSet(Sql, companyid);
                _ServiceType = dataSet.Tables[0];
                _Status = dataSet.Tables[1];
                _ticketStatus = dataSet.Tables[2];

                if (_ServiceType.Rows.Count > 0)
                {
                    ServiceTypeFilter.DataSource = _ServiceType;
                    ServiceTypeFilter.DataBind();
                    ServiceTypeFilter.DataTextField = "ServiceName";
                    ServiceTypeFilter.DataValueField = "ServiceName";
                    ServiceTypeFilter.DataBind();
                    ListItem listItem = new ListItem();
                    listItem.Text = "All Services";
                    listItem.Value = "";
                    ServiceTypeFilter.Items.Insert(0, listItem);


                    ServiceTypeFilter_2.DataSource = _ServiceType;
                    ServiceTypeFilter_2.DataBind();
                    ServiceTypeFilter_2.DataTextField = "ServiceName";
                    ServiceTypeFilter_2.DataValueField = "ServiceName";
                    ServiceTypeFilter_2.DataBind();
                    ServiceTypeFilter_2.Items.Insert(0, listItem);

                    ServiceTypeFilter_Edit.DataSource = _ServiceType;
                    ServiceTypeFilter_Edit.DataBind();
                    ServiceTypeFilter_Edit.DataTextField = "ServiceName";
                    ServiceTypeFilter_Edit.DataValueField = "ServiceTypeID";
                    ServiceTypeFilter_Edit.DataBind();
                    ServiceTypeFilter_Edit.Items.Insert(0, listItem);

                    ServiceTypeFilter_List.DataSource = _ServiceType;
                    ServiceTypeFilter_List.DataBind();
                    ServiceTypeFilter_List.DataTextField = "ServiceName";
                    ServiceTypeFilter_List.DataValueField = "ServiceName";
                    ServiceTypeFilter_List.DataBind();
                    ServiceTypeFilter_List.Items.Insert(0, listItem);

                    ServiceTypeFilter_Resource.DataSource = _ServiceType;
                    ServiceTypeFilter_Resource.DataBind();
                    ServiceTypeFilter_Resource.DataTextField = "ServiceName";
                    ServiceTypeFilter_Resource.DataValueField = "ServiceName";
                    ServiceTypeFilter_Resource.DataBind();
                    ServiceTypeFilter_Resource.Items.Insert(0, listItem);
                }
                if (_Status.Rows.Count > 0)
                {
                    StatusTypeFilter.DataSource = _Status;
                    StatusTypeFilter.DataBind();
                    StatusTypeFilter.DataTextField = "StatusName";
                    StatusTypeFilter.DataValueField = "StatusName";
                    StatusTypeFilter.DataBind();
                    StatusTypeFilter.Items.Insert(0, new ListItem("All Status", ""));

                    StatusTypeFilter_List.DataSource = _Status;
                    StatusTypeFilter_List.DataBind();
                    StatusTypeFilter_List.DataTextField = "StatusName";
                    StatusTypeFilter_List.DataValueField = "StatusName";
                    StatusTypeFilter_List.DataBind();
                    StatusTypeFilter_List.Items.Insert(0, new ListItem("All Status", ""));

                    StatusTypeFilter_Resource.DataSource = _Status;
                    StatusTypeFilter_Resource.DataBind();
                    StatusTypeFilter_Resource.DataTextField = "StatusName";
                    StatusTypeFilter_Resource.DataValueField = "StatusName";
                    StatusTypeFilter_Resource.DataBind();
                    StatusTypeFilter_Resource.Items.Insert(0, new ListItem("All Status", ""));

                    StatusTypeFilter_Edit.DataSource = _Status;
                    StatusTypeFilter_Edit.DataBind();
                    StatusTypeFilter_Edit.DataTextField = "StatusName";
                    StatusTypeFilter_Edit.DataValueField = "StatusID";
                    StatusTypeFilter_Edit.DataBind();
                    StatusTypeFilter_Edit.Items.Insert(0, new ListItem("All Status", ""));
                }

                if (_ticketStatus.Rows.Count > 0)
                {
                    TicketStatusFilter_List.DataSource = _ticketStatus;
                    TicketStatusFilter_List.DataBind();
                    TicketStatusFilter_List.DataTextField = "StatusName";
                    TicketStatusFilter_List.DataValueField = "StatusName";
                    TicketStatusFilter_List.DataBind();
                    TicketStatusFilter_List.Items.Insert(0, new ListItem("Ticket Status", ""));

                    TicketStatusFilter_Edit.DataSource = _ticketStatus;
                    TicketStatusFilter_Edit.DataBind();
                    TicketStatusFilter_Edit.DataTextField = "StatusName";
                    TicketStatusFilter_Edit.DataValueField = "StatusID";
                    TicketStatusFilter_Edit.DataBind();
                    TicketStatusFilter_Edit.Items.Insert(0, new ListItem("Ticket Status", ""));
                }
            }

            catch (Exception ex) { }
        }


        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static List<TimeSlot> GetTimeSlots()
        {
            string CompanyID = HttpContext.Current.Session["CompanyID"].ToString();
            var timeSlots = new List<TimeSlot>();
            Database db = new Database();
            try
            {
                db.Open();
                DataTable dt = new DataTable();
                string sql = @"SELECT ID, TimeBlock +  ' ( ' +   Convert(varchar(10),StartTime, 100)  + ' - ' +  Convert(varchar(10),EndTime, 100) + ' )' 
                        as TimeBlockSchedule,TimeBlock +  ' ( ' +   Convert(varchar(10),StartTime, 100)   + ' )' 
                        as TimeBlock, FORMAT(CAST(StartTime AS DATETIME),  'hh:mm tt') as StartTime,
                        FORMAT(CAST(EndTime AS DATETIME),  'hh:mm tt') as  EndTime FROM msSchedulerV3.dbo.tbl_TimeBlocks Where [IsDeleted] = 0
                        and [IsFromCalender] = 0 and  CompanyID = '" + CompanyID + "';";

                db.Execute(sql, out dt);
                db.Close();
                if (dt.Rows.Count > 0)
                {
                    foreach (DataRow row in dt.Rows)
                    {
                        var timeSlot = new TimeSlot();
                        timeSlot.ID = row.Field<int?>("ID") ?? 0;
                        timeSlot.StartTime = row.Field<string>("StartTime") ?? "";
                        timeSlot.EndTime = row.Field<string>("EndTime") ?? "";
                        timeSlot.TimeBlockSchedule = row.Field<string>("TimeBlockSchedule") ?? "";
                        timeSlot.TimeBlock = row.Field<string>("TimeBlock") ?? "";
                        timeSlot.CompanyID = CompanyID;
                        timeSlots.Add(timeSlot);
                    }
                }
            }

            catch (Exception ex)
            {
                db.Close();
                return timeSlots;
            }
            finally
            {
                db.Close();
            }
            return timeSlots;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static List<Resource> GetResourcess()
        {
            string CompanyID = HttpContext.Current.Session["CompanyID"].ToString();
            var resources = new List<Resource>();
            Database db = new Database();
            try
            {
                db.Open();
                DataTable dt = new DataTable();
                string sql = @"SELECT  [Id], [Name] FROM[msSchedulerV3].[dbo].[tbl_Resources] where companyid = '" + CompanyID + "' Order By Name;";

                db.Execute(sql, out dt);
                db.Close();
                if (dt.Rows.Count > 0)
                {
                    foreach (DataRow row in dt.Rows)
                    {
                        var resource = new Resource();
                        resource.Id = row.Field<int?>("Id") ?? 0;
                        resource.ResourceName = row.Field<string>("Name") ?? "";
                        resources.Add(resource);
                    }
                }
            }
            catch (Exception ex)
            {
                db.Close();
                return resources;
            }
            finally
            {
                db.Close();
            }
            return resources;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static Boolean UpdateAppointment(Appointment appointment)
        {
            bool success = false;
            string CompanyID = HttpContext.Current.Session["CompanyID"].ToString();
            Database db = new Database();

            try
            {
                string strSQL = @"UPDATE [msSchedulerV3].[dbo].[tbl_Appointment]
                            SET
                                [ServiceType] = @ServiceType,
                                [TimeSlot] = @TimeSlot,
                                [ApptDateTime] = @ApptDateTime,
                                [Status] = @Status,
                                [ResourceID] = @ResourceID, 
                                [TicketStatus] = @TicketStatus, 
                                [Note] = @Note,
                                [StartDateTime] = @StartDateTime,
                                [EndDateTime] = @EndDateTime


                            WHERE [ApptID] = @ApptID and
                                  [CustomerID] = @CustomerID and
                                  [CompanyID] = @CompanyID;";

                db.Command.Parameters.Clear();
                db.Command.Parameters.AddWithValue("@CompanyID", CompanyID);
                db.Command.Parameters.AddWithValue("@CustomerID", appointment.CustomerID);
                db.Command.Parameters.AddWithValue("@ApptID", appointment.AppoinmentId);
                db.Command.Parameters.AddWithValue("@ServiceType", appointment.ServiceType);
                db.Command.Parameters.AddWithValue("@ApptDateTime", appointment.RequestDate);
                db.Command.Parameters.AddWithValue("@TimeSlot", appointment.TimeSlot);
                db.Command.Parameters.AddWithValue("@Status", appointment.Status);
                db.Command.Parameters.AddWithValue("@TicketStatus", appointment.TicketStatus);
                db.Command.Parameters.AddWithValue("@Note", appointment.Note);
                db.Command.Parameters.AddWithValue("@ResourceID", appointment.ResourceID);
                db.Command.Parameters.AddWithValue("@StartDateTime", appointment.StartDateTime);
                db.Command.Parameters.AddWithValue("@EndDateTime", appointment.EndDateTime);
                success = db.UpdateSql(strSQL);
            }

            catch (Exception ex)
            {
                return success;
            }
            finally
            {
                db.Close();
            }
            return success;
        }
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object GetCustomerDetailsForModal(string customerId, string siteId)
        {
            try
            {
                var customer = GetCustomerDetails(customerId);
                var site = GetCustomerSitebyId(customerId, Convert.ToInt32(siteId));

                return new
                {
                    Success = true,
                    CustomerName = $"{customer?.FirstName} {customer?.LastName}",
                    CustomerGuid = customer?.CustomerGuid ?? "",
                    Address = site?.Address ?? "",
                    Contact = site?.Contact ?? "",
                    CustomerId = customerId,
                    SiteId = siteId,
                    Status = site?.IsActive == true ? "Active" : "Disabled",
                    Note = site?.Note ?? "",
                    CreatedOn = site?.CreatedDateTime?.ToString("yyyy-MM-dd") ?? "",
                    SiteName = site?.SiteName ?? "",
                    Phone = customer?.Phone ?? "",
                    PhoneLink = $"tel:{customer?.Phone ?? ""}",
                    Mobile = customer?.Mobile ?? "",
                    MobileLink = $"tel:{customer?.Mobile ?? ""}",
                    Email = customer?.Email ?? "",
                    EmailLink = $"mailto:{customer?.Email ?? ""}"
                };
            }
            catch (Exception ex)
            {
                return new { Success = false, Error = ex.Message };
            }
        }

        public static CustomerEntity GetCustomerDetails(string customerId)
        {
            var customer = new CustomerEntity();
            string companyid = HttpContext.Current.Session["CompanyID"].ToString();
            Database db = new Database();
            try
            {
                db.Open();
                DataTable dt = new DataTable();
                string sql = @"SELECT * FROM [msSchedulerV3].[dbo].[tbl_Customer] 
                               WHERE CustomerID = @CustomerID AND CompanyID = @CompanyID;";
                db.AddParameter("@CompanyID", companyid, SqlDbType.NVarChar);
                db.AddParameter("@CustomerID", customerId, SqlDbType.NVarChar);
                db.ExecuteParam(sql, out dt);
                db.Close();

                if (dt.Rows.Count > 0)
                {
                    DataRow dataRow = dt.Rows[0];
                    customer.CustomerGuid = dataRow.Field<string>("CustomerGuid") ?? "";
                    customer.FirstName = dataRow.Field<string>("FirstName") ?? "";
                    customer.LastName = dataRow.Field<string>("LastName") ?? "";
                    customer.Phone = dataRow.Field<string>("Phone") ?? "";
                    customer.Mobile = dataRow.Field<string>("Mobile") ?? "";
                    customer.Email = dataRow.Field<string>("Email") ?? "";
                }
            }
            catch
            {
                db.Close();
                return customer;
            }
            return customer;
        }


        public static CustomerSite GetCustomerSitebyId(string customerId, int siteId)
        {
            var site = new CustomerSite();
            Database db = new Database();
            DataTable dt = new DataTable();
            try
            {
                db.Open();
                string strSQL = @"SELECT * FROM [msSchedulerV3].dbo.tbl_CustomerSite 
                                  WHERE Id ='" + siteId + "' AND CustomerID='" + customerId + "';";
                db.Execute(strSQL, out dt);
                if (dt.Rows.Count > 0)
                {
                    DataRow dataRow = dt.Rows[0];
                    site.Id = dataRow.Field<int?>("Id") ?? 0;
                    site.SiteName = dataRow.Field<string>("SiteName") ?? "";
                    site.Address = dataRow.Field<string>("Address") ?? "";
                    site.Contact = dataRow.Field<string>("Contact") ?? "";
                    site.Note = dataRow.Field<string>("Note") ?? "";
                    site.IsActive = dataRow.Field<bool?>("IsActive") ?? false;
                    site.CreatedDateTime = Convert.ToDateTime(dataRow["CreatedDateTime"]);
                }
            }
            catch
            {
                return site;
            }
            finally
            {
                db.Close();
            }
            return site;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string GetDuration(int serviceTypeID)
        {
            var duration = "0";
            if (serviceTypeID > 0)
            {
                duration =  CalculateDuration(serviceTypeID);
            }
            return duration;
        }


        public static string CalculateDuration(int serviceTypeID)
        {
            string CompanyID = HttpContext.Current.Session["CompanyID"].ToString();
            var duration = "0";
            Database db = new Database();
            try
            {
                db.Open();
                DataTable dt = new DataTable();
                string sql = @"select Hour, Minute from [msSchedulerV3].[dbo].[tbl_ServiceType] where CompanyID = '" + CompanyID + "' and  ServiceTypeID ='" + serviceTypeID + "';";

                db.Execute(sql, out dt);
                db.Close();
                if (dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];
                    int hr = row.Field<int?>("Hour") ?? 0;
                    int min = row.Field<int?>("Minute") ?? 0;
                    duration = $"{hr} Hr : {min} Min";
                }
            }

            catch (Exception ex)
            {
                db.Close();
                return duration;
            }
            finally
            {
                db.Close();
            }
            return duration;
        }

        [WebMethod]
        public static bool UpdateAttachedForms(string appointmentId, List<int> formIds)
        {
            try
            {
                string companyId = System.Web.HttpContext.Current.Session["CompanyID"]?.ToString();
                string userId = System.Web.HttpContext.Current.Session["UserID"]?.ToString();
          
                
                if (string.IsNullOrEmpty(companyId))
                    return false;
           
                // Update appointment with attached forms
                Database db = new Database();
                string connectionString = ConfigurationManager.AppSettings["ConnStrJobs"].ToString();
                db = new Database(connectionString);
                try
                {
                    db.Init("sp_Appointments_UpdateAttachedForms");
                    db.AddParameter("@AppointmentId", appointmentId, System.Data.SqlDbType.VarChar);
                    db.AddParameter("@CompanyID", companyId, System.Data.SqlDbType.VarChar);
                    db.AddParameter("@FormIds", string.Join(",", formIds), System.Data.SqlDbType.VarChar);
                    db.AddParameter("@UpdatedBy", userId, System.Data.SqlDbType.VarChar);

                    return db.ExecuteCommand();
                }
                finally
                {
                    db.Close();
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error updating attached forms: " + ex.Message);
            }
        }

        [WebMethod]
        public static bool SendFormsViaEmail(string appointmentId, string customerEmail)
        {
            try
            {
                string companyId = System.Web.HttpContext.Current.Session["CompanyID"]?.ToString();
                if (string.IsNullOrEmpty(companyId))
                    return false;

                // Get appointment and customer details
                var appointment = GetAppointmentDetails(appointmentId, companyId);
                if (appointment == null)
                    return false;

                // Get attached forms
                var formProcessor = new FSM.Processors.FormProcessor();
                var forms = formProcessor.GetAppointmentForms(appointmentId, companyId);

                if (forms.Count == 0)
                {
                    throw new Exception("No forms attached to this appointment");
                }

                // Generate email content
                string subject = $"Forms for Appointment #{appointmentId}";
                string body = GenerateFormsEmailBody(appointment, forms);

                // Send email (you'll need to implement your email service)
                return SendEmail(customerEmail, subject, body, appointmentId);
            }
            catch (Exception ex)
            {
                throw new Exception("Error sending forms via email: " + ex.Message);
            }
        }

        [WebMethod]
        public static bool SendFormsViaSMS(string appointmentId, string customerPhone)
        {
            try
            {
                string companyId = System.Web.HttpContext.Current.Session["CompanyID"]?.ToString();
                if (string.IsNullOrEmpty(companyId))
                    return false;

                // Get appointment details
                var appointment = GetAppointmentDetails(appointmentId, companyId);
                if (appointment == null)
                    return false;

                // Generate SMS content
                string message = GenerateFormsSMSMessage(appointment, appointmentId);

                // Send SMS (you'll need to implement your SMS service)
                return SendSMS(customerPhone, message, appointmentId);
            }
            catch (Exception ex)
            {
                throw new Exception("Error sending forms via SMS: " + ex.Message);
            }
        }

        private static dynamic GetAppointmentDetails(string appointmentId, string companyId)
        {
            Database db = new Database();

            string connectionString = ConfigurationManager.AppSettings["ConnStrJobs"].ToString();
            db = new Database(connectionString);
            try
            {
                db.Init("sp_Appointments_GetDetails");
                db.AddParameter("@AppointmentId", appointmentId, System.Data.SqlDbType.VarChar);
                db.AddParameter("@CompanyID", companyId, System.Data.SqlDbType.VarChar);
                
                if (db.Execute() && db.Reader.Read())
                {
                    return new
                    {
                        AppointmentId = db.GetString("AppointmentId"),
                        CustomerName = db.GetString("CustomerName"),
                        CustomerEmail = db.GetString("CustomerEmail"),
                        CustomerPhone = db.GetString("CustomerPhone"),
                        ServiceType = db.GetString("ServiceType"),
                        RequestDate = db.GetString("RequestDate"),
                        TimeSlot = db.GetString("TimeSlot")
                    };
                }
            }
            finally
            {
                db.Close();
            }
            return null;
        }

        private static string GenerateFormsEmailBody(dynamic appointment, List<FSM.Entity.Forms.FormInstance> forms)
        {
            var body = $@"
                <html>
                <body>
                    <h2>Forms for Your Appointment</h2>
                    <p>Dear {appointment.CustomerName},</p>
                    <p>Please find the forms for your upcoming appointment:</p>
                    <ul>
                        <li><strong>Service:</strong> {appointment.ServiceType}</li>
                        <li><strong>Date:</strong> {appointment.RequestDate}</li>
                        <li><strong>Time:</strong> {appointment.TimeSlot}</li>
                    </ul>
                    <h3>Forms to Complete:</h3>
                    <ul>";

            foreach (var form in forms)
            {
                string templateName = form.TemplateName ?? $"Form #{form.TemplateId}";
                string templateId = HttpUtility.UrlEncode(form.TemplateId.ToString());
                string customerId = HttpUtility.UrlEncode(form.CustomerID ?? "");
                string apptID = HttpUtility.UrlEncode(appointment.AppointmentId);
                string companyId = System.Web.HttpContext.Current.Session["CompanyID"]?.ToString();
                // Build URL with encoded parameters
                string link = $"http://localhost:62934/FormResponse.aspx?templateId={templateId}&companyId={companyId}&cId={customerId}&apptId={apptID}";
                body += $"<li>{templateName} - Status: {form.Status} -> " +
                $"<a href='{link}' target='_blank'>Click here to submit response</a></li>";
            }

            body += @"
                    </ul>
                    <p>Please complete these forms before your appointment.</p>
                    <p>Thank you!</p>
                </body>
                </html>";

            return body;
        }

        private static string GenerateFormsSMSMessage(dynamic appointment, string appointmentId)
        {
            return $"Forms available for your appointment on {appointment.RequestDate} at {appointment.TimeSlot}. " +
                   $"Service: {appointment.ServiceType}. Please check your email or contact us for details. Ref: {appointmentId}";
        }

        private static bool SendEmail(string toEmail, string subject, string body, string appointmentId)
        {
            try
            {
                // Implement your email sending logic here
                // This is a placeholder - you'll need to integrate with your email service
                // Examples: SendGrid, SMTP, etc.
                
                System.Net.Mail.SmtpClient smtp = new System.Net.Mail.SmtpClient();
                System.Net.Mail.MailMessage mail = new System.Net.Mail.MailMessage();
                
                // Configure SMTP settings from web.config
                string smtpServer = System.Configuration.ConfigurationManager.AppSettings["SMTP"];
                string smtpPort = System.Configuration.ConfigurationManager.AppSettings["Port"];
                string smtpUser = System.Configuration.ConfigurationManager.AppSettings["SmtpUser"];
                string smtpPass = System.Configuration.ConfigurationManager.AppSettings["SMTPPassword"];
                
                if (!string.IsNullOrEmpty(smtpServer))
                {
                    smtp.Host = smtpServer;
                    smtp.Port = int.Parse(smtpPort ?? "587");
                    smtp.EnableSsl = true;
                    smtp.Credentials = new System.Net.NetworkCredential(smtpUser, smtpPass);
                    
                    mail.From = new System.Net.Mail.MailAddress(smtpUser);
                    mail.To.Add(toEmail);
                    mail.Subject = subject;
                    mail.Body = body;
                    mail.IsBodyHtml = true;
                    
                    smtp.Send(mail);
                    return true;
                }
                
                // If no SMTP configured, log the attempt
                System.Diagnostics.Debug.WriteLine($"Email would be sent to: {toEmail}, Subject: {subject}");
                return true; // Return true for demo purposes
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Email send error: {ex.Message}");
                return false;
            }
        }

        private static bool SendSMS(string phoneNumber, string message, string appointmentId)
        {
            try
            {
                // Implement your SMS sending logic here
                // This is a placeholder - you'll need to integrate with your SMS service
                // Examples: Twilio, AWS SNS, etc.
                
                // Log the SMS attempt
                System.Diagnostics.Debug.WriteLine($"SMS would be sent to: {phoneNumber}, Message: {message}");
                return true; // Return true for demo purposes
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"SMS send error: {ex.Message}");
                return false;
            }
        }
        [WebMethod]
        public static FormTemplate GetFormStructure(int templateId)
        {
            try
            {
                var forObj= new FormTemplate();
                string companyId = System.Web.HttpContext.Current.Session["CompanyID"]?.ToString();
                if (string.IsNullOrEmpty(companyId))
                    return forObj;

                var processor = new FormProcessor();
                var template = processor.GetTemplate(templateId, companyId);
                if(template != null)
                {
                    forObj = template;
                }
                return forObj;
            }
            catch (Exception ex)
            {
                throw new Exception("Error retrieving form structure: " + ex.Message);
            }
        }
    }
}