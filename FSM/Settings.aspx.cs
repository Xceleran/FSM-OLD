using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using FSM.Helper;

namespace FSM
{
    public partial class Settings : Page
    {
        // Connection strings for both functionalities
        string connStr = ConfigurationManager.AppSettings["ConnString"].ToString();
        string connStrJobs = ConfigurationManager.AppSettings["ConnStrJobs"];

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["CompanyID"] == null)
                {
                    Response.Redirect("~/Dashboard.aspx", true);
                }
                else
                {
                    string CompanyID = Session["CompanyID"].ToString();
                    hdCompanyID.Value = CompanyID;
                    LoadSMSSettings();
                }
            }
        }

        #region SMS Settings Methods

        private void LoadSMSSettings()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string query = "SELECT * FROM tbl_FSMSMSSettings WHERE CompanyId = @CompanyId";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@CompanyId", hdCompanyID.Value);

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        PendingYN.Checked = dr["PendingYN"] != DBNull.Value && Convert.ToBoolean(dr["PendingYN"]);
                        txtPending.Value = dr["PendingText"] != DBNull.Value ? dr["PendingText"].ToString() : "";

                        CancelledYN.Checked = dr["CancelledYN"] != DBNull.Value && Convert.ToBoolean(dr["CancelledYN"]);
                        txtCancelled.Value = dr["CancelledText"] != DBNull.Value ? dr["CancelledText"].ToString() : "";

                        ProgressYN.Checked = dr["ProgressYN"] != DBNull.Value && Convert.ToBoolean(dr["ProgressYN"]);
                        txtProgress.Value = dr["ProgressText"] != DBNull.Value ? dr["ProgressText"].ToString() : "";

                        ScheduledYN.Checked = dr["ScheduledYN"] != DBNull.Value && Convert.ToBoolean(dr["ScheduledYN"]);
                        txtScheduled.Value = dr["ScheduledText"] != DBNull.Value ? dr["ScheduledText"].ToString() : "";

                        ClosedYN.Checked = dr["ClosedYN"] != DBNull.Value && Convert.ToBoolean(dr["ClosedYN"]);
                        txtClosed.Value = dr["ClosedText"] != DBNull.Value ? dr["ClosedText"].ToString() : "";

                        CompletedYN.Checked = dr["CompletedYN"] != DBNull.Value && Convert.ToBoolean(dr["CompletedYN"]);
                        txtCompleted.Value = dr["CompletedText"] != DBNull.Value ? dr["CompletedText"].ToString() : "";
                    }
                }
            }
        }

        protected void SubmitData_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    // Delete old row
                    string deleteQuery = "DELETE FROM tbl_FSMSMSSettings WHERE CompanyId = @CompanyId";
                    SqlCommand deleteCmd = new SqlCommand(deleteQuery, conn);
                    deleteCmd.Parameters.AddWithValue("@CompanyId", hdCompanyID.Value);
                    deleteCmd.ExecuteNonQuery();

                    // Insert new row
                    string insertQuery = @"
                INSERT INTO tbl_FSMSMSSettings
                (CompanyId, PendingYN, PendingText, CancelledYN, CancelledText, ProgressYN, ProgressText, 
                 ScheduledYN, ScheduledText, ClosedYN, ClosedText, CompletedYN, CompletedText, 
                  CreateDate)
                VALUES
                (@CompanyId, @PendingYN, @PendingText, @CancelledYN, @CancelledText, @ProgressYN, @ProgressText, 
                 @ScheduledYN, @ScheduledText, @ClosedYN, @ClosedText, @CompletedYN, @CompletedText, 
                  GETDATE()) ";

                    SqlCommand cmd = new SqlCommand(insertQuery, conn);

                    cmd.Parameters.AddWithValue("@CompanyId", hdCompanyID.Value);

                    // Pending
                    cmd.Parameters.AddWithValue("@PendingYN", PendingYN.Checked);
                    cmd.Parameters.AddWithValue("@PendingText", string.IsNullOrEmpty(txtPending.Value) ? (object)DBNull.Value : txtPending.Value);

                    // Cancelled
                    cmd.Parameters.AddWithValue("@CancelledYN", CancelledYN.Checked);
                    cmd.Parameters.AddWithValue("@CancelledText", string.IsNullOrEmpty(txtCancelled.Value) ? (object)DBNull.Value : txtCancelled.Value);

                    // Progress
                    cmd.Parameters.AddWithValue("@ProgressYN", ProgressYN.Checked);
                    cmd.Parameters.AddWithValue("@ProgressText", string.IsNullOrEmpty(txtProgress.Value) ? (object)DBNull.Value : txtProgress.Value);

                    // Scheduled
                    cmd.Parameters.AddWithValue("@ScheduledYN", ScheduledYN.Checked);
                    cmd.Parameters.AddWithValue("@ScheduledText", string.IsNullOrEmpty(txtScheduled.Value) ? (object)DBNull.Value : txtScheduled.Value);

                    // Closed
                    cmd.Parameters.AddWithValue("@ClosedYN", ClosedYN.Checked);
                    cmd.Parameters.AddWithValue("@ClosedText", string.IsNullOrEmpty(txtClosed.Value) ? (object)DBNull.Value : txtClosed.Value);

                    // Completed
                    cmd.Parameters.AddWithValue("@CompletedYN", CompletedYN.Checked);
                    cmd.Parameters.AddWithValue("@CompletedText", string.IsNullOrEmpty(txtCompleted.Value) ? (object)DBNull.Value : txtCompleted.Value);

                    cmd.ExecuteNonQuery();
                }

                string success = "Swal.fire('Saved!', 'Your SMS settings have been saved successfully.', 'success')" +
                                 ".then(function(){ window.location.replace('Settings.aspx'); });";

                ScriptManager.RegisterStartupScript(this, this.GetType(), "SuccessAlertScript", success, true);
            }
            catch (Exception ex)
            {
                string error = $"Swal.fire('Error!', '{ex.Message.Replace("'", "\\'")}', 'error');";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ErrorAlertScript", error, true);
            }
        }

        #endregion

        #region Custom Fields WebMethods

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object GetFields()
        {
            try
            {
                string connStrJobs = ConfigurationManager.AppSettings["ConnStrJobs"];
                var fields = new List<object>();
                string sql = "SELECT FieldID, FieldName, FieldType, FieldOptions, IsActive FROM [msSchedulerV3].[dbo].[CustomFields] ORDER BY FieldName";

                using (var con = new SqlConnection(connStrJobs))
                using (var cmd = new SqlCommand(sql, con))
                {
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
                                Options = dr["FieldOptions"]?.ToString() ?? "[]",
                                IsActive = Convert.ToBoolean(dr["IsActive"])
                            });
                        }
                    }
                }
                return new { success = true, data = fields };
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("AJAX Error in GetFields: " + ex.Message);
                return new { success = false, message = "Server error while fetching fields: " + ex.Message };
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object SaveField(int fieldId, string fieldName, string fieldType, string fieldOptions, bool isActive)
        {
            try
            {
                string connStrJobs = ConfigurationManager.AppSettings["ConnStrJobs"];
                using (var con = new SqlConnection(connStrJobs))
                {
                    con.Open();
                    SqlCommand cmd;
                    if (fieldId == 0) // INSERT
                    {
                        cmd = new SqlCommand(
                            @"INSERT INTO [msSchedulerV3].[dbo].[CustomFields] (FieldName, FieldType, FieldOptions, AppliesTo, IsActive, CreatedDateTime) 
                              VALUES (@FieldName, @FieldType, @FieldOptions, @AppliesTo, @IsActive, GETDATE())", con);
                    }
                    else // UPDATE
                    {
                        cmd = new SqlCommand(
                            @"UPDATE [msSchedulerV3].[dbo].[CustomFields] 
                              SET FieldName=@FieldName, FieldType=@FieldType, FieldOptions=@FieldOptions, AppliesTo=@AppliesTo, IsActive=@IsActive 
                              WHERE FieldID=@FieldID", con);
                        cmd.Parameters.AddWithValue("@FieldID", fieldId);
                    }
                    cmd.Parameters.AddWithValue("@FieldName", fieldName.Trim());
                    cmd.Parameters.AddWithValue("@FieldType", fieldType);
                    cmd.Parameters.AddWithValue("@FieldOptions", string.IsNullOrWhiteSpace(fieldOptions) ? (object)DBNull.Value : fieldOptions);
                    cmd.Parameters.AddWithValue("@AppliesTo", "Job");
                    cmd.Parameters.AddWithValue("@IsActive", isActive);
                    cmd.ExecuteNonQuery();
                }
                return new { success = true, message = "Field saved successfully." };
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("AJAX Error in SaveField: " + ex.Message);
                return new { success = false, message = "An error occurred while saving the field." };
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object DeleteField(int fieldId)
        {
            try
            {
                string connStrJobs = ConfigurationManager.AppSettings["ConnStrJobs"];
                using (var con = new SqlConnection(connStrJobs))
                {
                    con.Open();
                    var cmd = new SqlCommand("DELETE FROM [msSchedulerV3].[dbo].[AppointmentCustomFields] WHERE FieldID=@FieldID; DELETE FROM [msSchedulerV3].[dbo].[CustomFields] WHERE FieldID=@FieldID;", con);
                    cmd.Parameters.AddWithValue("@FieldID", fieldId);
                    cmd.ExecuteNonQuery();
                }
                return new { success = true, message = "Field deleted successfully." };
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("AJAX Error in DeleteField: " + ex.Message);
                return new { success = false, message = "An error occurred while deleting the field." };
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object ToggleFieldActive(int fieldId)
        {
            try
            {
                string connStrJobs = ConfigurationManager.AppSettings["ConnStrJobs"];
                using (var con = new SqlConnection(connStrJobs))
                {
                    con.Open();
                    var cmd = new SqlCommand("UPDATE [msSchedulerV3].[dbo].[CustomFields] SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END WHERE FieldID=@FieldID", con);
                    cmd.Parameters.AddWithValue("@FieldID", fieldId);
                    cmd.ExecuteNonQuery();
                }
                return new { success = true, message = "Field status updated." };
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("AJAX Error in ToggleFieldActive: " + ex.Message);
                return new { success = false, message = "An error occurred while updating the field status." };
            }
        }

        #endregion
    }
}

