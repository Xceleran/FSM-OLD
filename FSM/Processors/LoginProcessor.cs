using FSM.Models;
using FSM.Models.LoginModels;
using FSM.Models.UserModels;
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
    public class LoginProcessor
    {
        public bool VerifyUser(string UserID, string CompanyID)
        {
            LoginObject _loginObject = new LoginObject();

            string sql = "";
            Database db = new Database();
            DataTable dt = new DataTable();
            if (!string.IsNullOrEmpty(UserID) && !string.IsNullOrEmpty(CompanyID))
            {
                sql = "Select c.CompanyIdInt,c.TimeZone,c.CompanyID,c.CompanyGUID,c.CompanyName,c.CompanyTag, u.UserID,u.Password,u.email,u.FirstName,u.LastName " +
                     "From [XinatorCentral].[dbo].[tbl_User] u inner join msSchedulerV3.dbo.tbl_Company c " +
                     " on u.CompanyID= c.CompanyID " +
                     " where u.CompanyID='" + CompanyID + "'" +
                     " and u.UserID='" + UserID + "'";

                sql += @"SELECT [ProductID] FROM [XinatorCentral].[dbo].[tbl_ProductsByCompany] where ProductID = '11' and ProductAccess=1 and CompanyID='" + CompanyID + "'";

                sql += @"SELECT [CompanyType] FROM [XinatorCentral].dbo.tbl_Company where  CompanyID='" + CompanyID + "'";
                DataSet dataSet = db.Get_DataSet(sql, CompanyID);
                dt = dataSet.Tables[0];

                _loginObject.IsParent = false;
                _loginObject.DealerName = "";
                _loginObject.DealerAddress = "";
                _loginObject.ParentID = CompanyID;
                _loginObject.LoginUser = UserID;
                _loginObject.UserFirstName = UserID;
                
                HttpContext.Current.Session["CompanyType"] = "Central";
                if (dataSet.Tables[2].Rows.Count > 0)
                {
                    HttpContext.Current.Session["CompanyType"] = dataSet.Tables[2].Rows[0]["CompanyType"].ToString();
                }

                if (dt.Rows.Count > 0)
                {
                    DataRow dr = dt.Rows[0];
                    HttpContext.Current.Session["LoginObj"] = _loginObject;
                    HttpContext.Current.Session["LoginUser"] = UserID;
                    HttpContext.Current.Session["UserFirstName"] = dr["FirstName"].ToString();
                    HttpContext.Current.Session["UserLastName"] = dr["LastName"].ToString();
                    HttpContext.Current.Session["CompanyID"] = dr["CompanyID"].ToString();
                    HttpContext.Current.Session["CompanyName"] = dr["CompanyName"].ToString();
                    HttpContext.Current.Session["CompanyTag"] = dr["CompanyTag"].ToString();
                    HttpContext.Current.Session["CurrentTimeZone"] = dr["TimeZone"].ToString();

                    HttpContext.Current.Session["CompanyGUID"] = dr["CompanyGUID"].ToString();
                    HttpContext.Current.Session["CompanyIdInt"] = dr["CompanyIdInt"].ToString();
                    HttpContext.Current.Session["hf_IsShowQBOMsg"] = "false";

                    SetDefaultData(CompanyID);
                    UserLogProcessor userLogProcessor = new UserLogProcessor();
                    userLogProcessor.AddLog(new UserLog
                    {
                        UserID = UserID,
                        CompanyID = CompanyID,
                        Text = "Logged Into FSM"
                    });
                    return true;
                }
            }
            return false;
        }

        public void SetDefaultData(string CompanyID)
        {
            try
            {
                DataSet _dataSet = new DataSet();
                Database db = new Database(ConfigurationManager.AppSettings["ConnString"].ToString());

                db.Init("SetDefaultValues");
                db.AddParameter("@CompanyID", CompanyID, SqlDbType.NVarChar);
                db.Execute(out _dataSet);
                HttpContext.Current.Session["Status"] = _dataSet.Tables[0];
            }
            catch(Exception ex) {

            }

        }

        public void LoadPrivilege(string userId)
        {
            Database db = new Database();
            string Sql = @"SELECT  tbl_Privelege.id,tbl_Privelege.Name,tbl_User_Privileage.UserID FROM tbl_Privelege INNER JOIN
                        tbl_User_Privileage ON tbl_Privelege.id = tbl_User_Privileage.PreviliageID" +
                         " Where tbl_User_Privileage.UserID = '" + userId + "'";
            DataTable dt = new DataTable();
            db.Execute(Sql, out dt);
            db.Close();
            UserPrivilege userPrivilege = new UserPrivilege();
            List<Privelege> Priveleges = new List<Privelege>();
            if (dt.Rows.Count > 0)
            {
                foreach (DataRow row in dt.Rows)
                {
                    Priveleges.Add(new Privelege
                    {
                        id = row["id"].ToString(),
                        text = row["Name"].ToString()

                    });
                }
            }
            userPrivilege.CanAccessSetting = Priveleges.Where(x => x.text == "CanAccessSetting").ToList().Count() > 0 ? true : false;
            userPrivilege.CanAccessVtPayment = Priveleges.Where(x => x.text == "CanAccessVtPayment").ToList().Count() > 0 ? true : false;
            userPrivilege.CanAddCustomerBooking = Priveleges.Where(x => x.text == "CanAddCustomerBooking").ToList().Count() > 0 ? true : false;
            userPrivilege.CanDeleteCustomer = Priveleges.Where(x => x.text == "CanDeleteCustomer").ToList().Count() > 0 ? true : false;
            userPrivilege.CanEditBooking = Priveleges.Where(x => x.text == "CanEditBooking").ToList().Count() > 0 ? true : false;
            userPrivilege.CanEditCustomer = Priveleges.Where(x => x.text == "CanEditCustomer").ToList().Count() > 0 ? true : false;
            userPrivilege.CanEditPayment = Priveleges.Where(x => x.text == "CanEditPayment").ToList().Count() > 0 ? true : false;
            userPrivilege.CanAccessQuickBooks = Priveleges.Where(x => x.text == "CanAccessQuickBooks").ToList().Count() > 0 ? true : false;
            userPrivilege.CanAccessUserInfo = Priveleges.Where(x => x.text == "CanAccessUserInfo").ToList().Count() > 0 ? true : false;
            userPrivilege.CanAccessInvoice = Priveleges.Where(x => x.text == "CanAccessInvoice").ToList().Count() > 0 ? true : false;

            HttpContext.Current.Session["userPrivilege"] = userPrivilege;
            //HttpContext.Current.Session["CanAccessQuickBooks"] = userPrivilege.CanAccessQuickBooks;
            //HttpContext.Current.Session["CanAccessUserInfo"] = userPrivilege.CanAccessUserInfo;
            HttpContext.Current.Session["CanAccessInvoice"] = userPrivilege.CanAccessInvoice;
        }
    }
}
