using FSM.Models.Customer;
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
    }
}
