using FSM.Models.FormResponseModel;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace FSM
{
    public partial class FormResponse : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            
        }

        [WebMethod]
        public static string SaveFormResponse(string responses)
        {
            try
            {
                string companyId = System.Web.HttpContext.Current.Session["CompanyID"]?.ToString();
                if (string.IsNullOrEmpty(companyId))
                    return "Company ID missing";
    
                int templateId = 1; 
                string formStructure = responses; 
                int? appointmentId = 0; 
                int customerId = 2 ;
                string connectionString = ConfigurationManager.AppSettings["ConnStrJobs"].ToString();
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
                INSERT INTO [myServiceJobs].[dbo].[FormResponse]
                (CompanyID, TemplateId, FormStructure, AppointmentID, CustomerID)
                VALUES (@CompanyID, @TemplateId, @FormStructure, @AppointmentID, @CustomerID)";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CompanyID", companyId);
                        cmd.Parameters.AddWithValue("@TemplateId", templateId);
                        cmd.Parameters.AddWithValue("@FormStructure", formStructure);
                        cmd.Parameters.AddWithValue("@AppointmentID", (object)appointmentId ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@CustomerID", customerId);

                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }

                return "Success";
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }
    }
}