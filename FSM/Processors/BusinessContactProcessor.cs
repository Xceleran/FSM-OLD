using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FSM.Processors
{
    public class BusinessContactProcessor
    {
        string connStr = ConfigurationManager.AppSettings["ConnString"].ToString();
        public BusinessContacts GetBusinessContactById(string CompanyId, string Businessid)
        {
            BusinessContacts businessContact = new BusinessContacts();

            Database db = new Database(connStr);
            DataTable dt = new DataTable();
            string Sql = @"SELECT [CompanyID]
                                  ,[CustomerID]
                                  ,[CustomerGuid]
                                  ,[BusinessName]
                                  ,[Title]
                                  ,[FirstName]
                                  ,[LastName]
                                  ,[Address1]
                                  ,[Address2]
                                  ,[City]
                                  ,[State]
                                  ,[ZipCode]
                                  ,[Phone]
                                  ,[Mobile]
                                  ,[Email]
                                  ,Notes
                                  ,[CreatedDateTime]
                                  ,[CallPopAppId]
                                  ,[QboId],[AMCustomerID],[CustomerCode]
                              FROM [msSchedulerV3].[dbo].[tbl_Customer] where CompanyID=@CompanyID and CustomerID=@CustomerID";

            db.Command.CommandText = Sql;
            db.Command.Parameters.Clear();
            db.Command.Parameters.AddWithValue("@CompanyID", CompanyId);
            db.Command.Parameters.AddWithValue("@CustomerID", Businessid);

            db.Execute(out dt);

            db.Close();

            if (dt.Rows.Count > 0)
            {
                foreach (DataRow dr in dt.Rows)
                {
                    businessContact.BusinessName = dr["BusinessName"].ToString();
                    businessContact.Title = dr["Title"].ToString();
                    businessContact.FirstName = dr["FirstName"].ToString();
                    businessContact.LastName = dr["LastName"].ToString();
                    businessContact.Address1 = dr["Address1"].ToString();
                    businessContact.Address2 = dr["Address2"].ToString();
                    businessContact.CustomerGuid = dr["CustomerGuid"].ToString();
                    businessContact.CustomerID = dr["CustomerID"].ToString();
                    businessContact.CallPopAppId = dr["CallPopAppId"].ToString();
                    businessContact.City = dr["City"].ToString();
                    businessContact.CompanyID = dr["CompanyID"].ToString();
                    businessContact.CreatedDateTime = Convert.ToDateTime(dr["CreatedDateTime"].ToString());
                    businessContact.Email = dr["Email"].ToString();
                    businessContact.BusinessName = dr["BusinessName"].ToString();
                    businessContact.Mobile = dr["Mobile"].ToString();
                    businessContact.Phone = dr["Phone"].ToString();
                    businessContact.State = dr["State"].ToString();
                    businessContact.ZipCode = dr["ZipCode"].ToString();
                    businessContact.Notes = dr["Notes"].ToString();
                    businessContact.AMCustomerId = dr["AMCustomerID"].ToString();
                    businessContact.CustomerCode = dr["CustomerCode"].ToString();

                }
            }

            return businessContact;
        }
    }

    public class BusinessContacts
    {
        public string CompanyID { get; set; }
        public string BusinessID { get; set; }
        public string CustomerID { get; set; }
        public string Notes { get; set; }
        public string CustomerGuid { get; set; }
        public string BusinessName { get; set; }
        public string Address1 { get; set; }
        public string Address2 { get; set; } = "";
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Title { get; set; }
        public string JobTitle { get; set; }
        public string City { get; set; }
        public string State { get; set; }
        public string ZipCode { get; set; }
        public string Phone { get; set; }
        public string Mobile { get; set; }
        public string Email { get; set; }
        public DateTime CreatedDateTime { get; set; }
        public string CallPopAppId { get; set; }
        public string QboId { get; set; }
        public bool IsPrimaryContact { get; set; }

        public bool IsBusinessContact { get; set; }

        //Nizam
        public string AMCustomerId { get; set; } = "0";
        public string CustomerCode { get; set; } = "";
    }
}
