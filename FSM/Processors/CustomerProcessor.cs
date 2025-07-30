using FSM.Entity.Customer;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace FSM.Processors
{
    public class CustomerProcessor
    {
        public Boolean CheckIfValidCustomer(CustomerEntity customers)
        {
            Database db = new Database();
            DataTable dt = new DataTable();
            string Sql = @"Select CustomerID From [msSchedulerV3].[dbo].[tbl_Customer]
                                    where CompanyID =@CompanyID and CustomerGuid=@CustomerGuid";
            db.Command.CommandText = Sql;
            db.Command.Parameters.Clear();
            db.Command.Parameters.AddWithValue("@CompanyID", customers.CompanyID);
            db.Command.Parameters.AddWithValue("@CustomerGuid", customers.CustomerGuid);

            if (db.ExecuteExecuteScalar() == 0)
            {
                return false;
            }
            else
            {
                return true;
            }
        }

        public CustomerEntity GetCustomerByGuid(string Guid, string CompanyId)
        {
            CustomerEntity customerEntity = new CustomerEntity();

            Database db = new Database();
            DataTable dt = new DataTable();
            string Sql = @"Select * From [msSchedulerV3].[dbo].[tbl_Customer] Where CompanyID=@CompanyID And CustomerGuid=@CustomerGuid";

            db.Command.CommandText = Sql;
            db.Command.Parameters.AddWithValue("@CompanyID", CompanyId);
            db.Command.Parameters.AddWithValue("@CustomerGuid", Guid);

            db.Execute(out dt);

            if (dt.Rows.Count > 0)
            {
                foreach (DataRow dr in dt.Rows)
                {
                    customerEntity.FirstName = dr["FirstName"].ToString();
                    customerEntity.LastName = dr["LastName"].ToString();
                    customerEntity.Title = dr["Title"].ToString();
                    customerEntity.JobTitle = dr["JobTitle"].ToString();
                    customerEntity.Address1 = dr["Address1"].ToString();
                    customerEntity.CustomerGuid = dr["CustomerGuid"].ToString();
                    customerEntity.CustomerID = dr["CustomerID"].ToString();
                    customerEntity.BusinessID = Convert.ToInt32(dr["BusinessID"]);
                    customerEntity.CallPopAppId = dr["CallPopAppId"].ToString();
                    customerEntity.City = dr["City"].ToString();
                    customerEntity.CompanyID = dr["CompanyID"].ToString();
                    customerEntity.CreatedDateTime = Convert.ToDateTime(dr["CreatedDateTime"].ToString());
                    customerEntity.Email = dr["Email"].ToString();
                    customerEntity.Mobile = dr["Mobile"].ToString();
                    customerEntity.Phone = dr["Phone"].ToString();
                    customerEntity.Notes = dr["Notes"].ToString();
                    customerEntity.State = dr["State"].ToString();
                    customerEntity.CompanyName = dr["CompanyName"].ToString();
                    customerEntity.BusinessName = dr["BusinessName"].ToString();
                    customerEntity.IsBusinessContact = Convert.ToBoolean(dr["IsBusinessContact"].ToString());
                    customerEntity.IsPrimaryContact = Convert.ToBoolean(dr["IsPrimaryContact"]);
                }
            }

            return customerEntity;
        }

        public CustomerEntity GetCustomerDetails(string customerId, string companyId)
        {
            var customer = new CustomerEntity();
            string connectionString = System.Configuration.ConfigurationManager.AppSettings["ConnStrJobs"].ToString();
            Database db = new Database(connectionString);
            try
            {
                db.Open();
                DataTable dt = new DataTable();
                string sql = @"SELECT * FROM [msSchedulerV3].[dbo].[tbl_Customer] WHERE CustomerID = @CustomerID AND CompanyID = @CompanyID;";
                db.AddParameter("@CompanyID", companyId, System.Data.SqlDbType.NVarChar);
                db.AddParameter("@CustomerID", customerId, System.Data.SqlDbType.NVarChar);
                db.ExecuteParam(sql, out dt);
                db.Close();
                
                if (dt.Rows.Count > 0)
                {
                    DataRow dataRow = dt.Rows[0];
                    customer.CustomerID = customerId;
                    customer.CompanyID = companyId;
                    customer.CustomerGuid = dataRow.Field<string>("CustomerGuid") ?? "";
                    customer.FirstName = dataRow.Field<string>("FirstName") ?? "";
                    customer.LastName = dataRow.Field<string>("LastName") ?? "";
                    customer.Phone = dataRow.Field<string>("Phone") ?? "";
                    customer.Mobile = dataRow.Field<string>("Mobile") ?? "";
                    customer.Email = dataRow.Field<string>("Email") ?? "";
                    customer.Address1 = dataRow.Field<string>("Address1") ?? "";
                    customer.Address2 = dataRow.Field<string>("Address2") ?? "";
                    customer.City = dataRow.Field<string>("City") ?? "";
                    customer.State = dataRow.Field<string>("State") ?? "";
                    customer.ZipCode = dataRow.Field<string>("ZipCode") ?? "";
                    customer.CompanyName = dataRow.Field<string>("CompanyName") ?? "";
                    customer.BusinessName = dataRow.Field<string>("BusinessName") ?? "";
                    customer.Title = dataRow.Field<string>("Title") ?? "";
                    customer.JobTitle = dataRow.Field<string>("JobTitle") ?? "";
                    customer.Notes = dataRow.Field<string>("Notes") ?? "";
                    customer.BusinessID = dataRow.Field<int?>("BusinessID") ?? 0;
                    customer.IsBusinessContact = dataRow.Field<bool?>("IsBusinessContact") ?? false;
                    customer.IsPrimaryContact = dataRow.Field<bool?>("IsPrimaryContact") ?? false;
                    customer.CreatedDateTime = dataRow.Field<DateTime?>("CreatedDateTime") ?? DateTime.Now;
                }
            }
            catch (Exception ex)
            {
                db.Close();
                // Return empty customer object on error
                return customer;
            }
            return customer;
        }
    }
}
