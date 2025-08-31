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
using FSM.SMSService;
using System.Data.SqlClient;

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


                lblCustomerName.Text = customer?.FirstName + " " + customer?.LastName;
                lblCustomerGuid.Text = customer?.CustomerGuid;
                lblAddress.Text = site?.Address;
                lblContact.Text = site?.Contact;
                lblCustomerId.Text = customerId;
                lblSiteId.Text = siteId;
                lblActive.Text = site?.IsActive == true ? "Active" : "Disabled";
                lblNote.Text = site?.Note;
                lblCreatedOn.Text = site?.CreatedDateTime?.ToString("MM/dd/yyyy");

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
        public static object GetActiveCustomFields(int apptId)
        {

            string connStrJobs = ConfigurationManager.AppSettings["ConnStrJobs"];
            var fields = new List<object>();

            string sql = @"
        SELECT 
            cf.FieldID, 
            cf.FieldName, 
            cf.FieldType, 
            cf.FieldOptions,
            acf.FieldValue
        FROM 
            [msSchedulerV3].[dbo].[CustomFields] cf
        LEFT JOIN 
            [msSchedulerV3].[dbo].[AppointmentCustomFields] acf 
            ON cf.FieldID = acf.FieldID AND acf.AppointmentID = @AppointmentID
        WHERE 
            cf.IsActive = 1
        ORDER BY 
            cf.FieldName";

            try
            {
                using (var con = new System.Data.SqlClient.SqlConnection(connStrJobs))
                using (var cmd = new System.Data.SqlClient.SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@AppointmentID", apptId);
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            fields.Add(new
                            {
                                FieldId = dr["FieldID"],
                                FieldName = dr["FieldName"].ToString(),
                                FieldType = dr["FieldType"].ToString(),
                                Options = dr["FieldOptions"] == DBNull.Value ? "[]" : dr["FieldOptions"].ToString(),
                                Value = dr["FieldValue"] == DBNull.Value ? null : dr["FieldValue"].ToString()
                            });
                        }
                    }
                }

                return fields;
            }
            catch (Exception ex)
            {

                System.Diagnostics.Debug.WriteLine("FATAL ERROR in GetActiveCustomFields: " + ex.ToString());



                throw new Exception("Server-side error in GetActiveCustomFields. Check debug output for details.");
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static List<AppointmentModel> LoadAppoinments(string searchValue, string fromDate, string toDate, string today)
        {
            var appoinments = new List<AppointmentModel>();
            string companyid = HttpContext.Current.Session["CompanyID"].ToString();
            Database db = new Database();
            try
            {
                string whereCondition = "WHERE apt.CompanyID = @CompanyID ";
                if (!string.IsNullOrEmpty(searchValue))
                {
                    whereCondition += @"AND (
                cus.BusinessName LIKE @SearchValue OR 
                cus.FirstName LIKE @SearchValue OR 
                cus.LastName LIKE @SearchValue OR 
                srv.ServiceName LIKE @SearchValue OR 
                rs.Name LIKE @SearchValue OR 
                cus.Mobile LIKE @SearchValue OR 
                cus.Phone LIKE @SearchValue OR 
                cs.Address LIKE @SearchValue OR 
                cus.Address1 LIKE @SearchValue
            ) ";
                }
                if (!string.IsNullOrEmpty(today))
                {
                    whereCondition += "AND CONVERT(DATE, apt.ApptDateTime) = @DateFilter ";
                }
                else if (!string.IsNullOrEmpty(fromDate) && !string.IsNullOrEmpty(toDate))
                {
                    whereCondition += "AND CONVERT(DATE, apt.ApptDateTime) BETWEEN @FromDate AND @ToDate ";
                }

                db.Open();
                DataTable dt = new DataTable();


                string sql = $@"
            SELECT  
                cus.FirstName, cus.LastName, cus.CustomerGuid, cus.BusinessID, cus.BusinessName, cus.IsBusinessContact, 
                cus.CustomerID, cus.Email, cus.Phone, cus.Mobile, cus.ZipCode, cus.State, cus.City, cus.Address1,
                apt.CompanyID, apt.ApptID, apt.ResourceID, apt.ServiceType AS StoredServiceType, apt.CreatedDateTime, 
                CONVERT(VARCHAR(10), apt.ApptDateTime, 120) as RequestDate, apt.Note, apt.TimeSlot,
                apt.StartDateTime, apt.EndDateTime, apt.Hour, apt.Minute, rs.Name as ResourceName, 
                srv.ServiceTypeID,
                srv.ServiceName,
                srv.CalenderColor as ServiceColor,
                sts.StatusID AS AppointmentStatusID,
                COALESCE(sts.StatusName, apt.Status, 'Unknown') AS AppoinmentStatus,
                tkt.StatusID AS TicketStatusID,
                COALESCE(tkt.StatusName, apt.TicketStatus, 'Unknown') AS TicketStatus,
                cs.Id as SiteId, cs.SiteName, cs.Address as SiteAddress, cs.Contact as SiteContact, 
                cs.Email as SiteEmail, cs.PhoneNumber as SitePhoneNumber, cs.Note as SiteNote, cs.IsActive as SiteIsActive
            FROM 
                tbl_Appointment apt
            INNER JOIN 
                tbl_Customer cus ON apt.CustomerID = cus.CustomerID AND apt.CompanyID = cus.CompanyID
            LEFT JOIN 
                tbl_CustomerSite cs ON apt.SiteId = cs.Id AND apt.CustomerID = cs.CustomerID
            LEFT JOIN 
                tbl_Resources as rs ON apt.ResourceID = rs.Id AND apt.CompanyID = rs.CompanyID
            LEFT JOIN 
                tbl_ServiceType AS srv ON apt.CompanyID = srv.CompanyID AND 
                    (TRY_CAST(apt.ServiceType AS INT) = srv.ServiceTypeID OR apt.ServiceType = srv.ServiceName)
            LEFT JOIN 
                tbl_Status AS sts ON apt.CompanyID = sts.CompanyID AND 
                    (TRY_CAST(apt.Status AS INT) = sts.StatusID OR apt.Status = sts.StatusName)
            LEFT JOIN 
                tbl_TicketStatus AS tkt ON apt.CompanyID = tkt.CompanyID AND 
                    (TRY_CAST(apt.TicketStatus AS INT) = tkt.StatusID OR apt.TicketStatus = tkt.StatusName)
            {whereCondition}
            ORDER BY 
                apt.ApptDateTime DESC";

                db.Command.Parameters.AddWithValue("@CompanyID", companyid);
                if (!string.IsNullOrEmpty(searchValue)) db.Command.Parameters.AddWithValue("@SearchValue", "%" + searchValue + "%");
                if (!string.IsNullOrEmpty(today)) db.Command.Parameters.AddWithValue("@DateFilter", today);
                if (!string.IsNullOrEmpty(fromDate) && !string.IsNullOrEmpty(toDate))
                {
                    db.Command.Parameters.AddWithValue("@FromDate", fromDate);
                    db.Command.Parameters.AddWithValue("@ToDate", toDate);
                }

                db.ExecuteParam(sql, out dt);
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
                        appoinment.Note = row.Field<string>("Note") ?? "";
                        appoinment.ResourceName = row.Field<string>("ResourceName") ?? "";
                        appoinment.RequestDate = row.Field<string>("RequestDate") ?? "";
                        appoinment.TimeSlot = row.Field<string>("TimeSlot") ?? "";
                        appoinment.AppoinmentDate = row.Field<string>("RequestDate") ?? "";

                        appoinment.ServiceType = row.Field<string>("ServiceName") ?? row.Field<string>("StoredServiceType") ?? "N/A";
                        appoinment.ServiceTypeID = row.Field<int?>("ServiceTypeID") ?? 0;
                        appoinment.AppoinmentStatus = row.Field<string>("AppoinmentStatus") ?? "N/A";
                        appoinment.AppoinmentStatusID = row.Field<int?>("AppointmentStatusID") ?? 0;
                        appoinment.TicketStatus = row.Field<string>("TicketStatus") ?? "N/A";
                        appoinment.TicketStatusID = row.Field<int?>("TicketStatusID") ?? 0;

                        appoinment.ServiceColor = row.Field<string>("ServiceColor") ?? "#3b82f6";
                        if (row["StartDateTime"] != DBNull.Value) appoinment.StartDateTime = Convert.ToDateTime(row["StartDateTime"]).ToString("MM/dd/yyyy hh:mm tt");
                        if (row["EndDateTime"] != DBNull.Value) appoinment.EndDateTime = Convert.ToDateTime(row["EndDateTime"]).ToString("MM/dd/yyyy hh:mm tt");

                        appoinment.SiteId = row["SiteId"] != DBNull.Value ? row["SiteId"].ToString() : "0";
                        appoinment.SiteName = row.Field<string>("SiteName") ?? "";
                        appoinment.SiteAddress = row.Field<string>("SiteAddress") ?? "";
                        appoinment.SiteContact = row.Field<string>("SiteContact") ?? "";
                        appoinment.SiteEmail = row.Field<string>("SiteEmail") ?? "";
                        appoinment.SitePhoneNumber = row.Field<string>("SitePhoneNumber") ?? "";
                        appoinment.SiteNote = row.Field<string>("SiteNote") ?? "";
                        appoinment.SiteIsActive = row.Field<bool?>("SiteIsActive") ?? false;


                        if (row["Hour"] != DBNull.Value && row["Hour"] != null)
                        {
                            int hr = row.Field<int?>("Hour") ?? 0;
                            int min = row.Field<int?>("Minute") ?? 0;
                            appoinment.Duration = $"{hr} Hr : {min} Min";
                        }

                        else if (appoinment.ServiceTypeID > 0)
                        {
                            appoinment.Duration = CalculateDuration(appoinment.ServiceTypeID);
                        }

                        else
                        {
                            appoinment.Duration = "1 Hr : 0 Min";
                        }



                        appoinments.Add(appoinment);
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error in LoadAppoinments: " + ex.Message);
            }
            finally
            {
                db.Close();
            }
            return appoinments;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static bool UpdateAppointmentDuration(int AppoinmentId, string StartDateTime, string EndDateTime, int Hour, int Minute)
        {
            string companyId = HttpContext.Current.Session["CompanyID"].ToString();
            Database db = new Database();
            try
            {
                string sql = @"UPDATE [msSchedulerV3].[dbo].[tbl_Appointment] SET
                            [StartDateTime] = @StartDateTime,
                            [EndDateTime] = @EndDateTime,
                            [Hour] = @Hour,
                            [Minute] = @Minute
                       WHERE [ApptID] = @ApptID AND [CompanyID] = @CompanyID;";

                db.Command.Parameters.Clear();
                db.AddParameter("@StartDateTime", Convert.ToDateTime(StartDateTime), SqlDbType.DateTime);
                db.AddParameter("@EndDateTime", Convert.ToDateTime(EndDateTime), SqlDbType.DateTime);
                db.AddParameter("@Hour", Hour, SqlDbType.Int);
                db.AddParameter("@Minute", Minute, SqlDbType.Int);
                db.AddParameter("@ApptID", AppoinmentId, SqlDbType.Int);
                db.AddParameter("@CompanyID", companyId, SqlDbType.VarChar);

                return db.UpdateSql(sql);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"UpdateAppointmentDuration Error: {ex.Message}");
                return false;
            }
            finally
            {
                db.Close();
            }
        }


        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static List<ServiceType> GetServiceTypesWithColors()
        {
            var serviceTypes = new List<ServiceType>();
            string companyId = HttpContext.Current.Session["CompanyID"].ToString();
            Database db = new Database();

            try
            {
                db.Open();
                DataTable dt = new DataTable();
                string sql = @"SELECT ServiceTypeID, ServiceName, CalenderColor 
                       FROM tbl_ServiceType 
                       WHERE CompanyID = @CompanyID 
                       ORDER BY ServiceName";

                db.AddParameter("@CompanyID", companyId, SqlDbType.NVarChar);
                db.ExecuteParam(sql, out dt);

                if (dt.Rows.Count > 0)
                {
                    foreach (DataRow row in dt.Rows)
                    {
                        var serviceType = new ServiceType();
                        serviceType.ServiceTypeID = row.Field<int>("ServiceTypeID");
                        serviceType.ServiceName = row.Field<string>("ServiceName") ?? "";
                        serviceType.CalendarColor = row.Field<string>("CalenderColor") ?? "#3b82f6"; // Default blue
                        serviceTypes.Add(serviceType);
                    }
                }
            }
            catch (Exception ex)
            {

            }
            finally
            {
                db.Close();
            }

            return serviceTypes;
        }

        public class ServiceType
        {
            public int ServiceTypeID { get; set; }
            public string ServiceName { get; set; }
            public string CalendarColor { get; set; }
        }
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static int GetServiceTypeIDByName(string serviceName, string companyId)
        {
            Database db = new Database();
            try
            {
                db.Open();
                DataTable dt = new DataTable();
                string sql = "SELECT ServiceTypeID FROM tbl_ServiceType WHERE ServiceName = @ServiceName AND CompanyID = @CompanyID";

                db.AddParameter("@ServiceName", serviceName, SqlDbType.NVarChar);
                db.AddParameter("@CompanyID", companyId, SqlDbType.NVarChar);

                db.ExecuteParam(sql, out dt);
                db.Close();

                if (dt.Rows.Count > 0)
                {
                    return Convert.ToInt32(dt.Rows[0]["ServiceTypeID"]);
                }
            }
            catch (Exception ex)
            {

            }
            finally
            {
                db.Close();
            }
            return 0;
        }
        public void LoadData()
        {
            string companyid = HttpContext.Current.Session["CompanyID"].ToString();
            Database db = new Database();
            try
            {
                string Sql = "SELECT ServiceTypeID, ServiceName, CalenderColor From msSchedulerV3.dbo.tbl_ServiceType where CompanyID = '" + companyid + "' order by ServiceName asc;";
                Sql += @"SELECT [StatusID], [StatusName] FROM [msSchedulerV3].[dbo].[tbl_Status] where CompanyID='" + companyid + "';";
                Sql += @"SELECT [StatusID], [StatusName] FROM [msSchedulerV3].[dbo].[tbl_TicketStatus] where CompanyID= '" + companyid + "';";

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
                    ServiceTypeFilter.DataTextField = "ServiceName";
                    ServiceTypeFilter.DataValueField = "ServiceTypeID";
                    ServiceTypeFilter.DataBind();
                    ListItem listItem = new ListItem("All Services", "");
                    ServiceTypeFilter.Items.Insert(0, listItem);

                    ServiceTypeFilter_2.DataSource = _ServiceType;
                    ServiceTypeFilter_2.DataTextField = "ServiceName";
                    ServiceTypeFilter_2.DataValueField = "ServiceTypeID";
                    ServiceTypeFilter_2.DataBind();
                    ServiceTypeFilter_2.Items.Insert(0, listItem);

                    ServiceTypeFilter_Edit.DataSource = _ServiceType;
                    ServiceTypeFilter_Edit.DataTextField = "ServiceName";
                    ServiceTypeFilter_Edit.DataValueField = "ServiceTypeID";
                    ServiceTypeFilter_Edit.DataBind();
                    ServiceTypeFilter_Edit.Items.Insert(0, listItem);

                    ServiceTypeFilter_List.DataSource = _ServiceType;
                    ServiceTypeFilter_List.DataTextField = "ServiceName";
                    ServiceTypeFilter_List.DataValueField = "ServiceTypeID";
                    ServiceTypeFilter_List.DataBind();
                    ServiceTypeFilter_List.Items.Insert(0, listItem);

                    ServiceTypeFilter_Resource.DataSource = _ServiceType;
                    ServiceTypeFilter_Resource.DataTextField = "ServiceName";
                    ServiceTypeFilter_Resource.DataValueField = "ServiceTypeID";
                    ServiceTypeFilter_Resource.DataBind();
                    ServiceTypeFilter_Resource.Items.Insert(0, listItem);
                }

                if (_Status.Rows.Count > 0)
                {
                    StatusTypeFilter.DataSource = _Status;
                    StatusTypeFilter.DataTextField = "StatusName";
                    StatusTypeFilter.DataValueField = "StatusID";
                    StatusTypeFilter.DataBind();
                    StatusTypeFilter.Items.Insert(0, new ListItem("All Statuses", ""));

                    StatusTypeFilter_List.DataSource = _Status;
                    StatusTypeFilter_List.DataTextField = "StatusName";
                    StatusTypeFilter_List.DataValueField = "StatusID";
                    StatusTypeFilter_List.DataBind();
                    StatusTypeFilter_List.Items.Insert(0, new ListItem("All Statuses", ""));

                    StatusTypeFilter_Resource.DataSource = _Status;
                    StatusTypeFilter_Resource.DataTextField = "StatusName";
                    StatusTypeFilter_Resource.DataValueField = "StatusID";
                    StatusTypeFilter_Resource.DataBind();
                    StatusTypeFilter_Resource.Items.Insert(0, new ListItem("All Statuses", ""));

                    StatusTypeFilter_Edit.DataSource = _Status;
                    StatusTypeFilter_Edit.DataTextField = "StatusName";
                    StatusTypeFilter_Edit.DataValueField = "StatusID";
                    StatusTypeFilter_Edit.DataBind();
                    StatusTypeFilter_Edit.Items.Insert(0, new ListItem("All Statuses", ""));
                }

                if (_ticketStatus.Rows.Count > 0)
                {
                    TicketStatusFilter_List.DataSource = _ticketStatus;
                    TicketStatusFilter_List.DataTextField = "StatusName";
                    TicketStatusFilter_List.DataValueField = "StatusID";
                    TicketStatusFilter_List.DataBind();
                    TicketStatusFilter_List.Items.Insert(0, new ListItem("All Ticket Statuses", ""));

                    TicketStatusFilter_Edit.DataSource = _ticketStatus;
                    TicketStatusFilter_Edit.DataTextField = "StatusName";
                    TicketStatusFilter_Edit.DataValueField = "StatusID";
                    TicketStatusFilter_Edit.DataBind();
                    TicketStatusFilter_Edit.Items.Insert(0, new ListItem("All Ticket Statuses", ""));
                }
            }
            catch (Exception ex)
            {

            }
            finally
            {
                db.Close();
            }
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
            string companyName = HttpContext.Current.Session["CompanyName"].ToString();
            Database db = new Database();

            try
            {
                var setClauses = new List<string>();

                db.Command.Parameters.Clear();
                db.Command.Parameters.AddWithValue("@CompanyID", CompanyID);
                db.Command.Parameters.AddWithValue("@ApptID", appointment.AppoinmentId);

                if (!string.IsNullOrEmpty(appointment.ServiceType))
                {
                    setClauses.Add("[ServiceType] = @ServiceType");
                    db.Command.Parameters.AddWithValue("@ServiceType", appointment.ServiceType);
                }
                if (!string.IsNullOrEmpty(appointment.TimeSlot))
                {
                    setClauses.Add("[TimeSlot] = @TimeSlot");
                    db.Command.Parameters.AddWithValue("@TimeSlot", appointment.TimeSlot);
                }
                if (!string.IsNullOrEmpty(appointment.RequestDate))
                {
                    setClauses.Add("[ApptDateTime] = @ApptDateTime");
                    db.Command.Parameters.AddWithValue("@ApptDateTime", Convert.ToDateTime(appointment.RequestDate));
                }
                if (!string.IsNullOrEmpty(appointment.Status))
                {
                    setClauses.Add("[Status] = @Status");
                    db.Command.Parameters.AddWithValue("@Status", appointment.Status);
                }
                if (appointment.ResourceID > 0)
                {
                    setClauses.Add("[ResourceID] = @ResourceID");
                    db.Command.Parameters.AddWithValue("@ResourceID", appointment.ResourceID);
                }
                if (!string.IsNullOrEmpty(appointment.TicketStatus))
                {
                    setClauses.Add("[TicketStatus] = @TicketStatus");
                    db.Command.Parameters.AddWithValue("@TicketStatus", appointment.TicketStatus);
                }
                if (appointment.Note != null)
                {
                    setClauses.Add("[Note] = @Note");
                    db.Command.Parameters.AddWithValue("@Note", appointment.Note);
                }
                if (appointment.SiteId > 0)
                {
                    setClauses.Add("[SiteId] = @SiteId");
                    db.Command.Parameters.AddWithValue("@SiteId", appointment.SiteId);
                }
                else
                {
  
                    setClauses.Add("[SiteId] = NULL");
                }
                if (!string.IsNullOrEmpty(appointment.StartDateTime))
                {
                    setClauses.Add("[StartDateTime] = @StartDateTime");
                    db.Command.Parameters.AddWithValue("@StartDateTime", Convert.ToDateTime(appointment.StartDateTime));
                }
                if (!string.IsNullOrEmpty(appointment.EndDateTime))
                {
                    setClauses.Add("[EndDateTime] = @EndDateTime");
                    db.Command.Parameters.AddWithValue("@EndDateTime", Convert.ToDateTime(appointment.EndDateTime));
                }

                if (setClauses.Count == 0)
                {
                    return true;
                }

                string strSQL = $@"UPDATE [msSchedulerV3].[dbo].[tbl_Appointment]
                           SET {string.Join(", ", setClauses)}
                           WHERE [ApptID] = @ApptID AND [CompanyID] = @CompanyID;";

                success = db.UpdateSql(strSQL);

                if (success == true)
                {
                    TwilioSMSService twilioSMS = new TwilioSMSService();
                    twilioSMS.SendAppointmentSMS(appointment.AppoinmentId, appointment.CustomerID, appointment.Status, CompanyID, companyName, appointment.RequestDate, appointment.TimeSlot, appointment.ResourceID);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"UpdateAppointment Error: {ex.Message}");
                return false;
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
                if (customer == null)
                {
                    return new { Success = false, Error = "Customer not found." };
                }
                return new
                {
                    Success = true,
                    CustomerName = $"{customer.FirstName} {customer.LastName}",
                    Address = site?.Address ?? customer.Address1 ?? "N/A",
                    Contact = site?.Contact ?? $"{customer.FirstName} {customer.LastName}",
                    Status = site?.IsActive == true ? "Active" : "Disabled",
                    Note = site?.Note ?? "No special instructions.",
                    CreatedOn = site?.CreatedDateTime?.ToString("yyyy-MM-dd") ?? "N/A",
                    Phone = customer.Phone ?? "N/A",
                    PhoneLink = $"tel:{customer.Phone}",
                    Mobile = customer.Mobile ?? "N/A",
                    MobileLink = $"tel:{customer.Mobile}",
                    Email = customer.Email ?? "N/A",
                    EmailLink = $"mailto:{customer.Email}"
                };
            }
            catch (Exception ex)
            {

                System.Diagnostics.Debug.WriteLine($"Error in GetCustomerDetailsForModal: {ex.ToString()}");
                return new { Success = false, Error = "An error occurred while fetching customer details." };
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
                duration = CalculateDuration(serviceTypeID);
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
        public static bool UpdateAttachedForms(string appointmentId, int customerId, List<int> formIds)
        {
            try
            {
                string companyId = System.Web.HttpContext.Current.Session["CompanyID"]?.ToString();
                string userId = System.Web.HttpContext.Current.Session["UserID"]?.ToString();


                if (string.IsNullOrEmpty(companyId))
                    return false;


                string connectionString = ConfigurationManager.AppSettings["ConnStrJobs"].ToString();
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();
                    using (SqlTransaction transaction = connection.BeginTransaction())
                    {
                        try
                        {
                            string deleteQuery = @"
                                DELETE FROM myServiceJobs.dbo.FormInstances 
                                WHERE AppointmentId = @AppointmentId 
                                  AND CustomerID = @CustomerId 
                                  AND CompanyID = @CompanyID";
                            using (SqlCommand deleteCommand = new SqlCommand(deleteQuery, connection, transaction))
                            {
                                deleteCommand.Parameters.AddWithValue("@AppointmentId", appointmentId);
                                deleteCommand.Parameters.AddWithValue("@CustomerId", customerId);
                                deleteCommand.Parameters.AddWithValue("@CompanyID", companyId);
                                deleteCommand.ExecuteNonQuery();
                            }
                            // Handle form attachment - can be empty list (remove all forms) or list with form IDs
                            if (formIds != null)
                            {
                                // Only validate and insert if there are form IDs to process
                                if (formIds.Count > 0)
                                {
                                    // First, validate that all form templates exist
                                    string validateQuery = @"
                                        SELECT Id FROM myServiceJobs.dbo.FormTemplates 
                                        WHERE Id = @TemplateId AND CompanyID = @CompanyID AND IsActive = 1";
                                    List<int> validFormIds = new List<int>();
                                    List<int> invalidFormIds = new List<int>();
                                    foreach (int formId in formIds)
                                    {
                                        using (SqlCommand validateCommand = new SqlCommand(validateQuery, connection, transaction))
                                        {
                                            validateCommand.Parameters.AddWithValue("@TemplateId", formId);
                                            validateCommand.Parameters.AddWithValue("@CompanyID", companyId);
                                            object result = validateCommand.ExecuteScalar();
                                            if (result != null && result != DBNull.Value)
                                            {
                                                validFormIds.Add(formId);
                                            }
                                            else
                                            {
                                                invalidFormIds.Add(formId);
                                                // Log invalid form ID for debugging
                                                System.Diagnostics.Debug.WriteLine($"Invalid form template ID: {formId}");
                                            }
                                        }
                                    }
                                    // If there are invalid form IDs, log them but continue with valid ones
                                    if (invalidFormIds.Count > 0)
                                    {
                                        System.Diagnostics.Debug.WriteLine($"Invalid form template IDs: {string.Join(", ", invalidFormIds)}");
                                    }
                                    // Insert only valid form instances
                                    foreach (int formId in validFormIds)
                                    {
                                        string insertQuery = @"
                                            INSERT INTO myServiceJobs.dbo.FormInstances (
                                                CompanyID, TemplateId, AppointmentId, CustomerId,
                                                Status, StartedDateTime
                                            ) VALUES (
                                                @CompanyID, @TemplateId, @AppointmentId, @CustomerId,
                                                'Pending', GETDATE()
                                            )";
                                        using (SqlCommand insertCommand = new SqlCommand(insertQuery, connection, transaction))
                                        {
                                            insertCommand.Parameters.AddWithValue("@CompanyID", companyId);
                                            insertCommand.Parameters.AddWithValue("@TemplateId", formId);
                                            insertCommand.Parameters.AddWithValue("@AppointmentId", appointmentId);
                                            insertCommand.Parameters.AddWithValue("@CustomerId", customerId);
                                            insertCommand.ExecuteNonQuery();
                                        }
                                    }
                                }
                                else
                                {
                                    // No form IDs provided - this means remove all forms (DELETE already handled above)
                                    System.Diagnostics.Debug.WriteLine("No form IDs provided - removing all attached forms");
                                }
                            }
                            transaction.Commit();
                            return true;
                        }
                        catch (Exception ex)
                        {
                            transaction.Rollback();
                            throw new Exception("Error updating attached forms: " + ex.Message);
                        }
                    }
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
                var forObj = new FormTemplate();
                string companyId = System.Web.HttpContext.Current.Session["CompanyID"]?.ToString();
                if (string.IsNullOrEmpty(companyId))
                    return forObj;

                var processor = new FormProcessor();
                var template = processor.GetTemplate(templateId, companyId);
                if (template != null)
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

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static bool UpdateAppointmentWithCustomFields(Appointment appointment, List<CustomFieldData> customFieldValues)
        {
           
            if (customFieldValues != null)
            {          
                SaveCustomFieldData(Convert.ToInt32(appointment.AppoinmentId), customFieldValues);
            }

            return UpdateAppointment(appointment);
        }


        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static bool SaveCustomFieldData(int appointmentId, List<CustomFieldData> customFieldValues)
        {
            string connStrJobs = ConfigurationManager.AppSettings["ConnStrJobs"];
            using (var con = new SqlConnection(connStrJobs))
            {
                con.Open();
            
                SqlTransaction transaction = con.BeginTransaction();
                try
                {
                
                    string deleteSql = "DELETE FROM [msSchedulerV3].[dbo].[AppointmentCustomFields] WHERE AppointmentID = @AppointmentID";
                    using (var deleteCmd = new SqlCommand(deleteSql, con, transaction))
                    {
                        deleteCmd.Parameters.AddWithValue("@AppointmentID", appointmentId);
                        deleteCmd.ExecuteNonQuery();
                    }

             
                    if (customFieldValues != null)
                    {
                        foreach (var fieldData in customFieldValues)
                        {
                            if (string.IsNullOrEmpty(fieldData.Value) || fieldData.Value == "[]") continue;

                            string insertSql = @"
                        INSERT INTO [msSchedulerV3].[dbo].[AppointmentCustomFields] (AppointmentID, FieldID, FieldValue, LastUpdated)
                        VALUES (@AppointmentID, @FieldID, @FieldValue, GETDATE())";

                            using (var cmd = new SqlCommand(insertSql, con, transaction))
                            {
                                cmd.Parameters.AddWithValue("@AppointmentID", appointmentId);
                                cmd.Parameters.AddWithValue("@FieldID", fieldData.FieldId);
                                cmd.Parameters.AddWithValue("@FieldValue", fieldData.Value);
                                cmd.ExecuteNonQuery();
                            }
                        }
                    }

                    transaction.Commit(); 
                    return true;
                }
                catch (Exception ex)
                {
                    transaction.Rollback(); 
                    System.Diagnostics.Debug.WriteLine("Error in SaveCustomFieldData: " + ex.Message);
                    return false;
                }
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static List<CustomerSite> GetSitesForCustomer(string customerId)
        {
            var sites = new List<CustomerSite>();
            // Ensure we have a valid customerId to query
            if (string.IsNullOrEmpty(customerId))
            {
                return sites;
            }

            string companyid = HttpContext.Current.Session["CompanyID"].ToString();
            Database db = new Database();
            DataTable dt = new DataTable();
            try
            {
                db.Open();
                string strSQL = @"SELECT Id, SiteName, Address 
                          FROM [msSchedulerV3].dbo.tbl_CustomerSite 
                          WHERE CompanyID = @CompanyID AND CustomerID = @CustomerID 
                          ORDER BY SiteName";

                // Using the existing pattern in your project for parameterized queries
                db.Command.Parameters.Clear();
                db.AddParameter("@CompanyID", companyid, SqlDbType.NVarChar);
                db.AddParameter("@CustomerID", customerId, SqlDbType.NVarChar);
                db.ExecuteParam(strSQL, out dt);
                db.Close();

                if (dt.Rows.Count > 0)
                {
                    foreach (DataRow dr in dt.Rows)
                    {
                        sites.Add(new CustomerSite
                        {
                            Id = Convert.ToInt32(dr["Id"]),
                            SiteName = dr["SiteName"].ToString() ?? "",
                            Address = dr["Address"].ToString() ?? ""
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                // It's good practice to log the exception
                System.Diagnostics.Debug.WriteLine("Error in GetSitesForCustomer: " + ex.Message);
                if (db != null) db.Close();
            }
            return sites;
        }

        public class CustomFieldData
        {
            public int FieldId { get; set; }
            public string Value { get; set; }
        }

        [WebMethod]
        public static string GetCustomerResponseOnForms(int templateId, int appointmentId, int customerId)
        {
            try
            {
                string formStructure = "";
                string companyId = System.Web.HttpContext.Current.Session["CompanyID"]?.ToString();
                if (string.IsNullOrEmpty(companyId))
                    return formStructure;

                var processor = new FormProcessor();
                var template = processor.GetFormStructureFromResponse(templateId, companyId, appointmentId, customerId);
                if (template != null)
                {
                    formStructure = template;
                }
                return formStructure;
            }
            catch (Exception ex)
            {
                throw new Exception("Error retrieving form structure: " + ex.Message);
            }
        }
    }
}