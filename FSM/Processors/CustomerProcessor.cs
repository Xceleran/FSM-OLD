using FSM.Models.Customer;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FSM.Processors
{
    public class CustomerProcessor
    {
        string connStr = ConfigurationManager.AppSettings["ConnString"].ToString();
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

            return db.IsExist();
        }
    }
}
