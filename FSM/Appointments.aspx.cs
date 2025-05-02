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

namespace FSM
{
    public partial class Appointments : System.Web.UI.Page
    {
        string CompanyID = "";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["CompanyID"] == null)
            {
                HttpContext.Current.Session["CompanyID"] = "14388";
            }
            if (!IsPostBack)
            {
                CompanyID = Session["CompanyID"].ToString();
                LoadData();
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static List<AppoinmentModel> LoadAppoinments(string searchValue,
            string fromDate,
            string toDate, string today)
        {
            var appoinments = new List<AppoinmentModel>();
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
                               cus.CustomerID, cus.Phone, cus.Mobile, cus.ZipCode, cus.State, cus.City, cus.Address1,
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
                        var appoinment = new AppoinmentModel();
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

                        appoinment.CustomerName = row.Field<string>("FirstName") + " " + row.Field<string>("LastName");

                        appoinment.AppoinmentId = row["ApptID"].ToString();
                        appoinment.AppoinmentStatus = row.Field<string>("AppStatus") ?? "";
                        appoinment.TicketStatus = row.Field<string>("AppTicketStatus") ?? "";
                        appoinment.ResourceName = row.Field<string>("ResourceName") ?? "";
                        appoinment.ServiceType = row.Field<string>("ServiceName") ?? "";
                        appoinment.RequestDate = row.Field<string>("RequestDate") ?? "";
                        appoinment.TimeSlot = row.Field<string>("TimeSlot") ?? "";
                        appoinment.AppoinmentDate = row.Field<string>("RequestDate") ?? "";

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

                DataTable _ServiceType = new DataTable();
                DataTable _Status = new DataTable();
                DataSet dataSet = db.Get_DataSet(Sql, companyid);
                _ServiceType = dataSet.Tables[0];
                _Status = dataSet.Tables[1];
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
                    ServiceTypeFilter_Edit.DataValueField = "ServiceName";
                    ServiceTypeFilter_Edit.DataBind();
                    ServiceTypeFilter_Edit.Items.Insert(0, listItem);

                    ServiceTypeFilterResource.DataSource = _ServiceType;
                    ServiceTypeFilterResource.DataBind();
                    ServiceTypeFilterResource.DataTextField = "ServiceName";
                    ServiceTypeFilterResource.DataValueField = "ServiceName";
                    ServiceTypeFilterResource.DataBind();
                    ServiceTypeFilterResource.Items.Insert(0, listItem);

                    ServiceTypeFilter_List.DataSource = _ServiceType;
                    ServiceTypeFilter_List.DataBind();
                    ServiceTypeFilter_List.DataTextField = "ServiceName";
                    ServiceTypeFilter_List.DataValueField = "ServiceName";
                    ServiceTypeFilter_List.DataBind();
                    ServiceTypeFilter_List.Items.Insert(0, listItem);
                }
                if(_Status.Rows.Count > 0)
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
                }
            }

            catch(Exception ex){}
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
                    foreach (DataRow row in dt.Rows) {
                        var timeSlot = new TimeSlot();
                        timeSlot.ID = row.Field<int?>("ID") ?? 0;
                        timeSlot.StartTime = row.Field<string>("StartTime") ?? "";
                        timeSlot.EndTime = row.Field<string>("EndTime") ?? "";
                        timeSlot.TimeBlockSchedule = row.Field<string>("TimeBlockSchedule") ?? "";
                        timeSlot.TimeBlock = row.Field<string>("TimeBlock") ?? "";
                        timeSlot.CompanyID = CompanyID;
                        timeSlot.Duration = CalculateDurationInMinutes(timeSlot.StartTime, timeSlot.EndTime);
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


        public static int CalculateDurationInMinutes(string startTime, string endTime)
        {
            startTime = startTime?.Trim();
            endTime = endTime?.Trim();

            if (DateTime.TryParse(startTime, out DateTime start) &&
                DateTime.TryParse(endTime, out DateTime end))
            {
                return (int)(end - start).TotalMinutes;
            }

            throw new ArgumentException("Invalid start or end time format.");
        }

    }
}