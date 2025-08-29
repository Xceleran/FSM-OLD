﻿using FSM;
using FSM.Entity.Appoinments;
using FSM.SMSService;
using Intuit.Ipp.Data;
using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel.Design;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Web;
using Twilio;
using Twilio.Rest.Api.V2010.Account;
using Twilio.Rest.Api.V2010.Account.Message;
using Twilio.Types;

namespace FSM.SMSService
{
    public class TwilioSMSService
    {
        private static string connstr = ConfigurationManager.AppSettings["ConnString"].ToString();
         

        public string SendSMS(string recipientNumber, string message)
        {
            try
            {
                ServicePointManager.SecurityProtocol |= SecurityProtocolType.Tls12;

                string accountSid = ConfigurationManager.AppSettings["TwilioAccountSid"];
                string authToken = ConfigurationManager.AppSettings["TwilioAccountAuthToken"];
                string twilioPhoneNumber = ConfigurationManager.AppSettings["TwilioPhoneNumber"];

                TwilioClient.Init(accountSid, authToken);

                var to = new PhoneNumber(recipientNumber);
                var msg = MessageResource.Create(
                    to,
                    from: new PhoneNumber(twilioPhoneNumber),
                    body: message);

                return msg.Sid;
            }
            catch (Twilio.Exceptions.ApiException ex)
            {
                throw new ApplicationException($"Failed to send SMS: {ex.Message}", ex);
            }
            catch (Twilio.Exceptions.AuthenticationException ex)
            {
                return $"Authentication Error: {ex.Message}";
            }
            catch (Twilio.Exceptions.RestException ex)
            {
                return $"Twilio REST Error: {ex.Message}";
            }
            catch (Exception ex)
            {
                return $"Unexpected Error: {ex.Message}";
            }
        }


        public string SendMMS(string recipientNumber, string message, string fileUrl)
        {
            ServicePointManager.SecurityProtocol |= SecurityProtocolType.Tls12;

            string accountSid = ConfigurationManager.AppSettings["TwilioAccountSid"];
            string authToken = ConfigurationManager.AppSettings["TwilioAccountAuthToken"];
            string twilioPhoneNumber = ConfigurationManager.AppSettings["TwilioPhoneNumber"];
            TwilioClient.Init(accountSid, authToken);

            var to = new PhoneNumber(recipientNumber);
            var msg = MessageResource.Create(
                to,
                from: new PhoneNumber(twilioPhoneNumber),
                body: message,
                mediaUrl: new List<Uri> {
                new Uri(fileUrl) });
            return msg.Sid;
        }

        bool LogSMS(string companyId, string customerId, string resourceId, string apptId, string mobile, string SMSType, string SMSBody, string smsSid)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.AppSettings["ConnString"].ToString()))

            {
                connection.Open();
                string sqlQuery = string.Format("INSERT INTO [dbo].[tbl_TwilioSMSLog] ([CompanyId] ,[CustomerId] ,[ResourceId] ,[AppointmentId],[ToNumber] ,[SMSType] ,[SMSBody],[SMSSid] ,[SendDateTime]) VALUES ('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}',GETDATE())", companyId, customerId, resourceId, apptId, mobile, SMSType, SMSBody, smsSid);
                SqlCommand command = new SqlCommand();
                command.CommandText = sqlQuery;
                command.CommandType = CommandType.Text;
                command.Connection = connection;

                int rowsAffected = command.ExecuteNonQuery();
                if (rowsAffected > 0)
                {
                    return true;
                }
                return false;
            }
        }


        public void SendAppointmentSMS(string appoinmentId, string customerID, string status, string companyID, string companyName, string AppointmentDate, string timeSlot, int resourceID)
        {
            string customerQuery = "select FirstName, LastName,FirstName+' ' + LastName as FullName, Title, JobTitle, Mobile,Phone from tbl_Customer where CompanyID='" + companyID + "' and CustomerID='" + customerID + "'";

            string smsQuery = "select * from tbl_FSMSMSSettings where CompanyID='" + companyID + "'";

            string ResourceQuery = "Select Name, Mobile From [msSchedulerV3].[dbo].[tbl_Resources] " +
                 " Where CompanyID ='" + companyID + "' And Id ='" + resourceID + "'";

            Database db = new Database(connstr);
            DataTable dtCustomer = new DataTable();
            DataTable dtSms = new DataTable();
            DataTable dtResource = new DataTable();

            db.Execute(customerQuery, out dtCustomer);
            db.Execute(smsQuery, out dtSms);
            db.Execute(ResourceQuery, out dtResource);

            db.Close();

            string smsBody = "";
            bool YNOption = false;
            string mobile = "";
            string phone = "";
            string resourceMobile = "";
            string resourceName = "";

            if (dtSms.Rows.Count > 0)
            {
                DataRow dr = dtSms.Rows[0];

                if (status == "1") // Pending
                {
                    if (dr["PendingYN"] != null) YNOption = Convert.ToBoolean(dr["PendingYN"]);
                    smsBody = dr["PendingText"].ToString();
                }
                else if (status == "2") //Scheduled
                {
                    if (dr["ScheduledYN"] != null) YNOption = Convert.ToBoolean(dr["ScheduledYN"]);
                    smsBody = dr["ScheduledText"].ToString();
                }
                else if (status == "3") // Cancelled
                {
                    if (dr["CancelledYN"] != null) YNOption = Convert.ToBoolean(dr["CancelledYN"]);
                    smsBody = dr["CancelledText"].ToString();
                }
                else if (status == "4") //Closed
                {
                    if (dr["ClosedYN"] != null) YNOption = Convert.ToBoolean(dr["ClosedYN"]);
                    smsBody = dr["ClosedText"].ToString();
                }
                else if (status == "5") // Installation In Progress
                {
                    if (dr["ProgressYN"] != null) YNOption = Convert.ToBoolean(dr["ProgressYN"]);
                    smsBody = dr["ProgressText"].ToString();
                }
                else if (status == "6") // Completed
                {
                    if (dr["CompletedYN"] != null) YNOption = Convert.ToBoolean(dr["CompletedYN"]);
                    smsBody = dr["CompletedText"].ToString();
                }

            }

            if (!string.IsNullOrEmpty(smsBody))
            {
                if (dtCustomer.Rows.Count > 0)
                {
                    DataRow dr = dtCustomer.Rows[0];
                    mobile = dr["Mobile"].ToString();
                    phone = dr["Phone"].ToString();

                    smsBody = smsBody.Replace("[First Name]", dr["FirstName"].ToString());
                    smsBody = smsBody.Replace("[Last Name]", dr["LastName"].ToString());
                    smsBody = smsBody.Replace("[Full Name]", dr["FullName"].ToString());
                    smsBody = smsBody.Replace("[Job Title]", dr["JobTitle"].ToString());
                    smsBody = smsBody.Replace("[Title]", dr["Title"].ToString());
                    smsBody = smsBody.Replace("[Date]", AppointmentDate);
                    smsBody = smsBody.Replace("[Time]", timeSlot);
                    smsBody = smsBody.Replace("[Company Name]", companyName);

                }

                if (YNOption == true)
                {
                    smsBody += Environment.NewLine + "Enter Y for Yes or N for No";
                }

            }

            if (!string.IsNullOrEmpty(phone))
            {
                string smsSid = SendSMS(phone, smsBody);
                LogSMS(companyID, customerID, resourceID.ToString(), appoinmentId, phone, "FSM", smsBody, smsSid);
            }

            if (status == "2")
            {
                if (dtResource.Rows.Count > 0)
                {
                    DataRow dr = dtResource.Rows[0];
                    resourceMobile = dr["Mobile"].ToString();
                    resourceName = dr["Name"].ToString();


                }

                string resourceSMS = string.Format("Hi {2}, You have a new appointment at {0} {1}. Open the app to see the details.", AppointmentDate, timeSlot, resourceName);

                if (!string.IsNullOrEmpty(resourceMobile))
                {
                    string smsId = SendSMS(resourceMobile, resourceSMS);
                    LogSMS(companyID, customerID, resourceID.ToString(), appoinmentId, resourceMobile, "FSM Assign Resource", resourceSMS, smsId);
                }

            }



        }


        public bool SendCustomerAdHocSMS(string companyId, string customerId, string SMSBody, string mobile)
        {
            bool result = false;
            string smsSid = SendSMS(mobile, SMSBody);
            result = LogSMS(companyId, customerId, "", "", mobile, "CustomerAdHoc", SMSBody, smsSid);
            return result;
        }


        public bool SendCustomerMMS(string companyId, string customerId, string MMSBody, string mobile, string filePath, string mmsUrl)
        {
            bool result = false;
            string smsSid = SendMMS(mobile, MMSBody, mmsUrl);
            result = LogMMS(companyId, customerId, "", "", mobile, "CustomerAdHocMMS", MMSBody, smsSid, filePath);
            return result;
        }

        bool LogMMS(string companyId, string customerId, string resourceId, string apptId, string mobile, string MMSType, string MMSBody, string smsSid, string filePath)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.AppSettings["ConnString"].ToString()))

            {
                connection.Open();
                string sqlQuery = string.Format("INSERT INTO [dbo].[tbl_TwilioSMSLog] ([CompanyId] ,[CustomerId] ,[ResourceId] ,[AppointmentId],[ToNumber] ,[SMSType] ,[SMSBody], [SMSSid], [FilePath] ,[SendDateTime]) VALUES ('{0}','{1}','{2}','{3}','{4}', '{5}','{6}', '{7}', '{8}', GETDATE())", companyId, customerId, resourceId, apptId, mobile, MMSType, MMSBody, smsSid, filePath);
                SqlCommand command = new SqlCommand();
                command.CommandText = sqlQuery;
                command.CommandType = CommandType.Text;
                command.Connection = connection;

                int rowsAffected = command.ExecuteNonQuery();
                if (rowsAffected > 0)
                {
                    return true;
                }
                return false;
            }
        }



        public List<Message> GetSMSHistoryForNumber(string phoneNumber)
        {
            ServicePointManager.SecurityProtocol |= SecurityProtocolType.Tls12;

            string accountSid = ConfigurationManager.AppSettings["TwilioAccountSid"];
            string authToken = ConfigurationManager.AppSettings["TwilioAccountAuthToken"];
            TwilioClient.Init(accountSid, authToken);

            var outgoingMessages = MessageResource.Read(
                to: new Twilio.Types.PhoneNumber(phoneNumber)
            );

            var incomingMessages = MessageResource.Read(
                from: new Twilio.Types.PhoneNumber(phoneNumber)
            );

            List<Message> sms = new List<Message>();

            // ✅ Outgoing - only delivered
            foreach (var msg in outgoingMessages)
            {
                if (msg.Status.ToString().Equals("delivered", StringComparison.OrdinalIgnoreCase))
                {
                    var dto = new Message
                    {
                        From = msg.From?.ToString(),
                        To = msg.To?.ToString(),
                        Type = "outgoing",
                        Status = msg.Status.ToString(),
                        Body = msg.Body,
                        SendDateTime = msg.DateSent ?? DateTime.MinValue
                    };

                    // 🔹 Check for MMS attachments
                    int numMedia = 0;
                    int.TryParse(msg.NumMedia?.ToString(), out numMedia);

                    if (numMedia > 0)
                    {
                        var mediaItems = MediaResource.Read(pathMessageSid: msg.Sid);
                        foreach (var media in mediaItems)
                        {
                            string mediaUrl = $"https://{accountSid}:{authToken}@api.twilio.com{media.Uri.Replace(".json", "")}";
                            dto.MediaUrls.Add(mediaUrl);

                        }
                    }

                    sms.Add(dto);
                }
            }

            // ✅ Incoming - only received
            foreach (var msg in incomingMessages)
            {
                if (msg.Status.ToString().Equals("received", StringComparison.OrdinalIgnoreCase))
                {
                    var dto = new Message
                    {
                        From = msg.From?.ToString(),
                        To = msg.To?.ToString(),
                        Type = "incoming",
                        Status = msg.Status.ToString(),
                        Body = msg.Body,
                        SendDateTime = msg.DateSent ?? DateTime.MinValue
                    };

                    // 🔹 Check for MMS attachments
                    int numMedia = 0;
                    int.TryParse(msg.NumMedia?.ToString(), out numMedia);

                    if (numMedia > 0)
                    {
                        var mediaItems = MediaResource.Read(pathMessageSid: msg.Sid);
                        foreach (var media in mediaItems)
                        {
                            string mediaUrl = $"https://{accountSid}:{authToken}@api.twilio.com{media.Uri.Replace(".json", "")}";
                            dto.MediaUrls.Add(mediaUrl);
                        }
                    }


                    sms.Add(dto);
                }
            }

            return sms;
        }





    }
}