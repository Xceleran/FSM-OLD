using FSM.Entity.Appoinments;
using FSM.Entity.Customer;
using FSM.Entity.Enums;
using FSM.Models.AppoinmentModel;
using System;
using System.Collections.Generic;
using System.ComponentModel.Design;
using System.Data;
using System.Security.Policy;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace FSM
{
    public partial class CustomerDetails : System.Web.UI.Page
    {
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
                lblCreatedOn.Text = site?.CreatedDateTime?.ToString("yyyy-MM-dd");
                lblSiteName.Text = site?.SiteName;

                hlPhone.Text = customer?.Phone;
                hlPhone.NavigateUrl = "tel:" + customer?.Phone;
                hlMobile.Text = customer?.Mobile;
                hlMobile.NavigateUrl = "tel:" + customer?.Mobile;
                hlEmail.Text = customer?.Email;
                hlEmail.NavigateUrl = "mailto:" + customer?.Email;

                LoadData();
            }
        }

        public void LoadData()
        {
            string companyid = HttpContext.Current.Session["CompanyID"].ToString();
            Database db = new Database();
            try
            {
                string Sql = @"SELECT  [StatusID],[StatusName] FROM [msSchedulerV3].[dbo].[tbl_TicketStatus] where CompanyID= '" + companyid + "';";
                Sql += @"SELECT  [StatusID],[StatusName] FROM [msSchedulerV3].[dbo].[tbl_Status] where CompanyID='" + companyid + "';";

                DataTable _ticketStatus = new DataTable();
                DataTable _appStatus = new DataTable();
                DataSet dataSet = db.Get_DataSet(Sql, companyid);

                _ticketStatus = dataSet.Tables[0];
                _appStatus = dataSet.Tables[1];
                if (_ticketStatus.Rows.Count > 0)
                {
                    ticketStatus.DataSource = _ticketStatus;
                    ticketStatus.DataBind();
                    ticketStatus.DataTextField = "StatusName";
                    ticketStatus.DataValueField = "StatusName";
                    ticketStatus.DataBind();
                    ticketStatus.Items.Insert(0, new ListItem("All Ticket Status", ""));
                }
                if (_appStatus.Rows.Count > 0)
                {
                    apptFilter.DataSource = _appStatus;
                    apptFilter.DataBind();
                    apptFilter.DataTextField = "StatusName";
                    apptFilter.DataValueField = "StatusName";
                    apptFilter.DataBind();
                    apptFilter.Items.Insert(0, new ListItem("All Status", ""));
                }
            }

            catch (Exception ex) { }
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
                string sql = @"SELECT * FROM [msSchedulerV3].[dbo].[tbl_Customer] WHERE CustomerID = @CustomerID AND CompanyID = @CompanyID;";
                db.AddParameter("@CompanyID", companyid, SqlDbType.NVarChar);
                db.AddParameter("@CustomerID", customerId, SqlDbType.NVarChar);
                db.ExecuteParam(sql, out dt);
                db.Close();
                if (dt.Rows.Count > 0)
                {
                    DataRow dataRow = dt.Rows[0];
                    //customer.BusinessID = dataRow.Field<int?>("BusinessID") ?? 0;
                    customer.CustomerGuid = dataRow.Field<string>("CustomerGuid") ?? "";
                    //customer.Address1 = dataRow.Field<string>("Address1") ?? "";
                    //customer.Address2 = dataRow.Field<string>("Address2") ?? "";
                    customer.FirstName = dataRow.Field<string>("FirstName") ?? "";
                    customer.LastName = dataRow.Field<string>("LastName") ?? "";
                    customer.Phone = dataRow.Field<string>("Phone") ?? "";
                    customer.Mobile = dataRow.Field<string>("Mobile") ?? "";
                    //customer.CompanyName = dataRow.Field<string>("CompanyName") ?? "";
                    customer.Email = dataRow.Field<string>("Email") ?? "";
                }
            }
            catch (Exception ex)
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
                string strSQL = @"SELECT * FROM [msSchedulerV3].dbo.tbl_CustomerSite WHERE Id ='" + siteId + "' AND CustomerID='" + customerId + "';";
                db.Open();
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
            catch (Exception ex)
            {
                return site;
            }
            finally
            {
                db.Close();
            }
            return site;
        }

        public static CustomerSummeryCount GetCustomerSummery(string customerId)
        {
            string companyid = HttpContext.Current.Session["CompanyID"].ToString();
            Database db = new Database();
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
                    foreach (DataRow row in dt1.Rows)
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
                string estimateQuery = @"select count(*) as EstimateCount FROM [msSchedulerV3].[dbo].[tbl_Invoice] where Type='Proposal' AND CustomerID = @CustomerID AND CompnyID = @CompanyID;";
                db.AddParameter("@CompanyID", companyid, SqlDbType.NVarChar);
                db.AddParameter("@CustomerID", customerId, SqlDbType.NVarChar);
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
                return customerData;
            }

            return customerData;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static List<AppointmentModel> GetCustomerAppoinmets(string customerId)
        {
            var appoinments = new List<AppointmentModel>();
            string companyid = HttpContext.Current.Session["CompanyID"].ToString();
            Database db = new Database();
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
                            WHERE  apt.CustomerID='" + customerId + "' and apt.CompanyID ='" + companyid + "';";
                db.ExecuteParam(sql, out dt);
                db.Close();
                if (dt.Rows.Count > 0)
                {
                    foreach (DataRow row in dt.Rows)
                    {
                        var appoinment = new AppointmentModel();
                        appoinment.CustomerID = customerId;
                        appoinment.CompanyID = companyid;
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

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static List<CustomerInvoice> GetCustomerInvoices(string customerId)
        {
            var invoices = new List<CustomerInvoice>();
            string companyid = HttpContext.Current.Session["CompanyID"].ToString();
            Database db = new Database();
            //customerId = "302"; // for testing purpose
            try
            {
                db.Open();
                DataTable dt = new DataTable();
                string sql = @"select ID, Number,Subtotal,isnull([AmountCollect],0.00) as AmountCollect,
                            isnull([DepositAmount],0.00) as DepositAmount, Discount, Tax, (Total- (isnull(AmountCollect,0.00))) as Due, 
                            Type, CONVERT(VARCHAR(10), InvoiceDate, 101) as InvoiceDate, Total, AppointmentId
                            from tbl_Invoice as inv WHERE inv.CustomerID='" + customerId + "' and inv.CompnyID ='" + companyid + "';";
                db.ExecuteParam(sql, out dt);
                db.Close();
                if (dt.Rows.Count > 0)
                {
                    foreach (DataRow row in dt.Rows)
                    {
                        var invoice = new CustomerInvoice();
                        invoice.CustomerID = customerId;
                        invoice.CompanyID = companyid;
                        invoice.ID = row.Field<string>("ID") ?? "";
                        invoice.AppointmentId = row.Field<string>("AppointmentId") ?? "";
                        invoice.InvoiceNumber = row.Field<string>("Number") ?? "";
                        invoice.InvoiceDate = row.Field<string>("InvoiceDate") ?? "";
                        invoice.InvoiceType = row.Field<string>("Type") ?? "";
                        invoice.Subtotal = row["Subtotal"].ToString() ?? "0.0";
                        invoice.Total = row["Total"].ToString() ?? "0.0";
                        invoice.Due = row["Due"].ToString() ?? "0.0";
                        invoice.Discount = row["Discount"].ToString() ?? "0.0";
                        invoice.Tax = row["Tax"].ToString() ?? "0.0";
                        invoice.DepositAmount = row["DepositAmount"].ToString() ?? "0.0";

                        if ((Convert.ToDouble(row["Total"].ToString()) - Convert.ToDouble(row["AmountCollect"].ToString())) <= 0)
                        {
                            invoice.InvoiceStatus = "Paid";
                        }
                        else
                        {
                            invoice.InvoiceStatus = "Unpaid";
                        }

                        invoices.Add(invoice);
                    }
                }
            }
            catch (Exception ex)
            {
                return invoices;
            }
            finally
            {
                db.Close();
            }
            return invoices;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static List<Equipment> GetSiteEquipmentData(int siteId, string customerGuid)
        {
            string companyid = HttpContext.Current.Session["CompanyID"].ToString();
            var equipments = new List<Equipment>();
            Database db = new Database();
            DataTable dt = new DataTable();
            try
            {
                db.Open();
                string strSQL = @"SELECT eqp.*, cus.CustomerID, cus.FirstName, cus.LastName FROM [msSchedulerV3].dbo.tbl_Equipment eqp left join [msSchedulerV3].dbo.tbl_Customer cus 
                                on eqp.CustomerGuid = cus.CustomerGuid WHERE eqp.CustomerGuid='" + customerGuid + "' AND eqp.CompanyID = '" + companyid + "' AND eqp.SiteId='" + siteId + "';";
                db.Open();
                db.Execute(strSQL, out dt);
                db.Close();
                if (dt.Rows.Count > 0)
                {
                    foreach (DataRow dr in dt.Rows)
                    {
                        equipments.Add(new Equipment
                        {
                            Id = Convert.ToInt32(dr["Id"]),
                            SiteId = siteId,
                            CustomerGuid = customerGuid,
                            CustomerName = dr.Field<string>("FirstName") + " " + dr.Field<string>("LastName"),
                            CustomerID = dr["CustomerID"].ToString() ?? "",
                            Make = dr["Make"].ToString() ?? "",
                            Barcode = dr["Barcode"].ToString() ?? "",
                            SerialNumber = dr["SerialNumber"].ToString() ?? "",
                            Model = dr["Model"].ToString() ?? "",
                            Notes = dr["Notes"].ToString() ?? "",
                            EquipmentType = dr["EquipmentType"].ToString() ?? "",
                            CreatedDateTime = Convert.ToDateTime(dr["CreatedDateTime"]),
                            WarrantyStart = dr["WarrantyStart"] != DBNull.Value && !string.IsNullOrEmpty(dr["WarrantyStart"].ToString())
                                   ? Convert.ToDateTime(dr["WarrantyStart"]).ToString("yyyy-MM-dd") : string.Empty,
                            WarrantyEnd = dr["WarrantyEnd"] != DBNull.Value && !string.IsNullOrEmpty(dr["WarrantyEnd"].ToString())
                                   ? Convert.ToDateTime(dr["WarrantyEnd"]).ToString("yyyy-MM-dd") : string.Empty,
                            LaborWarrantyStart = dr["LaborWarrantyStart"] != DBNull.Value && !string.IsNullOrEmpty(dr["LaborWarrantyStart"].ToString())
                                   ? Convert.ToDateTime(dr["LaborWarrantyStart"]).ToString("yyyy-MM-dd") : string.Empty,
                            LaborWarrantyEnd = dr["LaborWarrantyEnd"] != DBNull.Value && !string.IsNullOrEmpty(dr["LaborWarrantyEnd"].ToString())
                                   ? Convert.ToDateTime(dr["LaborWarrantyEnd"]).ToString("yyyy-MM-dd") : string.Empty,
                            InstallDate = dr["InstallDate"] != DBNull.Value && !string.IsNullOrEmpty(dr["InstallDate"].ToString())
                                   ? Convert.ToDateTime(dr["InstallDate"]).ToString("yyyy-MM-dd") : string.Empty,
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                return equipments;
            }
            finally
            {
                db.Close();
            }
            return equipments;
        }


        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static bool SaveEquipmentData(Equipment equipment)
        {
            if (equipment.Id > 0)
            {
                return UpdateEquipment(equipment);
            }
            else
            {
                return InsertEquipment(equipment);
            }
        }

        public static bool InsertEquipment(Equipment equipment)
        {
            bool success = false;
            string companyid = HttpContext.Current.Session["CompanyID"].ToString();
            Database db = new Database();
            try
            {
                db.Open();
                string strSQL = @"INSERT INTO [msSchedulerV3].dbo.tbl_Equipment
                        (CompanyID, CustomerID, CustomerGuid, SiteId, Make, Model, Notes, EquipmentType, Barcode, SerialNumber, WarrantyStart, WarrantyEnd, LaborWarrantyStart, LaborWarrantyEnd, InstallDate) output INSERTED.ID
                        VALUES (@CompanyID, @CustomerID, @CustomerGuid, @SiteId, @Make, @Model, @Notes, @EquipmentType, @Barcode, @SerialNumber, @WarrantyStart, @WarrantyEnd, @LaborWarrantyStart, @LaborWarrantyEnd, @InstallDate)";
                db.AddParameter("@CompanyID", companyid, SqlDbType.NVarChar);
                db.AddParameter("@CustomerID", equipment.CustomerID, SqlDbType.NVarChar);
                db.AddParameter("@CustomerGuid", equipment.CustomerGuid, SqlDbType.NVarChar);
                db.AddParameter("@Make", equipment.Make, SqlDbType.NVarChar);
                db.AddParameter("@Model", equipment.Model, SqlDbType.NVarChar);
                db.AddParameter("@Notes", equipment.Notes, SqlDbType.NVarChar);
                db.AddParameter("@SiteId", equipment.SiteId, SqlDbType.Int);
                db.AddParameter("@EquipmentType", equipment.EquipmentType, SqlDbType.NVarChar);
                db.AddParameter("@Barcode", equipment.Barcode, SqlDbType.NVarChar);
                db.AddParameter("@SerialNumber", equipment.SerialNumber, SqlDbType.NVarChar);
                db.AddParameter("@WarrantyStart", string.IsNullOrEmpty(equipment.WarrantyStart) ? DBNull.Value : (object)equipment.WarrantyStart, SqlDbType.DateTime);
                db.AddParameter("@WarrantyEnd", string.IsNullOrEmpty(equipment.WarrantyEnd) ? DBNull.Value : (object)equipment.WarrantyEnd, SqlDbType.DateTime);
                db.AddParameter("@LaborWarrantyStart", string.IsNullOrEmpty(equipment.LaborWarrantyStart) ? DBNull.Value : (object)equipment.LaborWarrantyStart, SqlDbType.DateTime);
                db.AddParameter("@LaborWarrantyEnd", string.IsNullOrEmpty(equipment.LaborWarrantyEnd) ? DBNull.Value : (object)equipment.LaborWarrantyEnd, SqlDbType.DateTime);
                db.AddParameter("@InstallDate", string.IsNullOrEmpty(equipment.InstallDate) ? DBNull.Value : (object)equipment.InstallDate, SqlDbType.DateTime);
                object result = db.ExecuteScalarData(strSQL);
                if (result != null)
                {
                    success = true;
                }
            }
            catch (Exception ex)
            {
                success = false;
            }
            finally
            {
                db.Close();
            }
            return success;
        }

        public static bool UpdateEquipment(Equipment equipment)
        {
            bool success = false;
            Database db = new Database();
            try
            {
                db.Open();
                string strSQL = @"UPDATE [msSchedulerV3].dbo.tbl_Equipment SET 
                                    Make = @Make,
                                    EquipmentType = @EquipmentType,
                                    Barcode = @Barcode,
                                    SerialNumber = @SerialNumber,
                                    Model = @Model,
                                    Notes = @Notes,
                                    InstallDate = @InstallDate,
                                    WarrantyStart = @WarrantyStart, 
                                    WarrantyEnd = @WarrantyEnd,
                                    LaborWarrantyStart = @LaborWarrantyStart,
                                    LaborWarrantyEnd = @LaborWarrantyEnd 
                                    WHERE Id=@Id and SiteId = @SiteId";
                db.AddParameter("@Make", equipment.Make, SqlDbType.NVarChar);
                db.AddParameter("@EquipmentType", equipment.EquipmentType, SqlDbType.NVarChar);
                db.AddParameter("@Barcode", equipment.Barcode, SqlDbType.NVarChar);
                db.AddParameter("@SerialNumber", equipment.SerialNumber, SqlDbType.NVarChar);
                db.AddParameter("@Model", equipment.Model, SqlDbType.NVarChar);
                db.AddParameter("@Notes", equipment.Notes, SqlDbType.NVarChar);
                db.AddParameter("@InstallDate", string.IsNullOrEmpty(equipment.InstallDate) ? DBNull.Value : (object)equipment.InstallDate, SqlDbType.NVarChar);
                db.AddParameter("@WarrantyStart", string.IsNullOrEmpty(equipment.WarrantyStart) ? DBNull.Value : (object)equipment.WarrantyStart, SqlDbType.NVarChar);
                db.AddParameter("@WarrantyEnd", string.IsNullOrEmpty(equipment.WarrantyEnd) ? DBNull.Value : (object)equipment.WarrantyEnd, SqlDbType.NVarChar);
                db.AddParameter("@LaborWarrantyStart", string.IsNullOrEmpty(equipment.LaborWarrantyStart) ? DBNull.Value : (object)equipment.LaborWarrantyStart, SqlDbType.NVarChar);
                db.AddParameter("@LaborWarrantyEnd", string.IsNullOrEmpty(equipment.LaborWarrantyEnd) ? DBNull.Value : (object)equipment.LaborWarrantyEnd, SqlDbType.NVarChar);
                db.AddParameter("@SiteId", equipment.SiteId, SqlDbType.Int);
                db.AddParameter("@Id", equipment.Id, SqlDbType.Int);
                success = db.UpdateSql(strSQL);
            }
            catch (Exception ex)
            {
                success = false;
            }
            finally
            {
                db.Close();
            }
            return success;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static bool DeleteEquipment(int equipmentId)
        {
            bool success = false;
            Database db = new Database();
            try
            {
                db.Open();
                string strSQL = @"DELETE FROM [msSchedulerV3].dbo.tbl_Equipment WHERE Id=@Id";
                db.AddParameter("@Id", equipmentId, SqlDbType.Int);
                success = db.UpdateSql(strSQL);
            }
            catch (Exception ex)
            {
                success = false;
            }
            finally
            {
                db.Close();
            }
            return success;
        }


        //protected void invoiceCreate_Click(object sender, EventArgs e)
        //{
        //    string cid = lblCustomerGuid.Text.ToString();
        //    string InType = "Invoice";
        //    Response.Redirect($"InvoiceCreate.aspx?InvNum=0&cId={cid}&InType={InType}");
        //}

        //protected void estimateCreate_Click(object sender, EventArgs e)
        //{
        //    string cid = lblCustomerGuid.Text.ToString();
        //    string InType = "Proposal";
        //    Response.Redirect($"InvoiceCreate.aspx?InvNum=0&cId={cid}&InType={InType}");
        //}
    }
}