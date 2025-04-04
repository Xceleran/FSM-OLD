﻿using FSM.Models.Customer;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Reflection;
using System.Security.Policy;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

namespace FSM
{
    public partial class Customers : System.Web.UI.Page
    {
        string CompanyID = "";
        protected void Page_Load(object sender, EventArgs e)
        {
            HttpContext.Current.Session["CompanyID"] = "13185";
            if (!IsPostBack)
            {
                LoadCustomers();
            }
        }

        public List<CustomerEntity> LoadCustomers()
        {
            string companyid = Session["CompanyID"].ToString();
            Database db = new Database();
            DataTable dt = new DataTable();
            var customers = new List<CustomerEntity>();
            try
            {
                string Sql = @"Select * From [msSchedulerV3].[dbo].[tbl_Customer] where CompanyID = '"+ companyid + "' order by FirstName asc;";
                db.Open();
                db.Execute(Sql, out dt);
                db.Close();
                if (dt.Rows.Count > 0)
                {
                    foreach (DataRow dr in dt.Rows)
                    {
                        customers.Add(new CustomerEntity
                        {
                            CompanyID = dr["CompanyID"].ToString(),
                            CustomerID = dr["CustomerID"].ToString(),
                            BusinessID = Convert.ToInt32(dr["BusinessID"]),
                            CustomerGuid = dr["CustomerGuid"].ToString(),
                           // Address1 = dr["Address1"].ToString(),
                            //Address2 = dr["Address2"].ToString(),
                            FirstName = dr["FirstName"].ToString(),
                            //FirstName2 = dr["FirstName2"].ToString(),
                            LastName = dr["LastName"].ToString(),
                            //LastName2 = dr["LastName2"].ToString(),
                            //Title = dr["Title"].ToString(),
                            //Title2 = dr["Title2"].ToString(),
                            //JobTitle = dr["JobTitle"].ToString(),
                            //JobTitle2 = dr["JobTitle2"].ToString(),
                           // City = dr["City"].ToString(),
                            //State = dr["State"].ToString(),
                            //ZipCode = dr["ZipCode"].ToString(),
                           // Phone = dr["Phone"].ToString(),
                            //Mobile = dr["Mobile"].ToString(),
                            Email = dr["Email"].ToString(),
                           // Notes = dr["Notes"].ToString(),
                            CompanyName = dr["CompanyName"].ToString(),
                            //CompanyName2 = dr["CompanyName2"].ToString(),
                            //BusinessName = dr["BusinessName"].ToString(),
                            IsBusinessContact = Convert.ToBoolean(dr["IsBusinessContact"]),
                            IsPrimaryContact = Convert.ToBoolean(dr["IsPrimaryContact"]),
                            IsDealer = Convert.ToBoolean(dr["IsDealer"]),
                            DealerID = dr["DealerID"].ToString(),
                            CreatedDateTime = Convert.ToDateTime(dr["CreatedDateTime"]),
                            CallPopAppId = dr["CallPopAppId"].ToString(),
                            QboId = dr["QboId"].ToString(),
                            CreatedCompanyID = dr["CreatedCompanyID"].ToString()
                        });
                    }
                }
            }

            catch (Exception ex)
            {
                throw ex;
            }
            return customers;
        }


        public CustomerEntity GetCustomerDetails(string CustomerGuid, string customerId)
        {
            string companyid = Session["CompanyID"].ToString();
            Database db = new Database();
            DataTable dt = new DataTable();
            var customer = new CustomerEntity();

            string TotalDueForInvoice = "0";
            string TotalDueForEstimate = "0";
            string TotalEstimate = "0";
            string TotalInvoice = "0";
            string TotalAppoinment = "0";

            try
            {
                string Sql = "SELECT CompanyID,CustomerID,FirstName,LastName,CustomerGuid,Title,CompanyName,JobTitle,IsPrimaryContact,Notes," +
              "Address1,City,State,ZipCode,Phone,Mobile,Email,BusinessID, " +
              "FORMAT( (select ISNULL(Sum(Total-AmountCollect),0) from msSchedulerV3.dbo.tbl_invoice where Type='Invoice' and CompnyID='" + companyid + "' and CustomerID='" + customerId + "'), 'N2') as TotalDueForInvoice," +
              "FORMAT((select ISNULL(Sum(Total-AmountCollect),0) from msSchedulerV3.dbo.tbl_invoice where Type='Proposal' and IsConverted = 0 and CompnyID='" + companyid + "' and CustomerID='" + customerId + "'), 'N2') as TotalDueForEstimate," +
              "(select count(Type) from msSchedulerV3.dbo.tbl_invoice where Type='Proposal' and IsConverted = 0 and CompnyID='" + companyid + "' and CustomerID='" + customerId + "') as TotalEstimate," +
              "(select count(Type) from msSchedulerV3.dbo.tbl_invoice where Type='Invoice' and CompnyID='" + companyid + "' and CustomerID='" + customerId + "') as TotalInvoice," +
              "(select count(CompanyID) from msSchedulerV3.dbo.tbl_Appointment where CompanyID='" + companyid + "' and CustomerID='" + customerId + "') as TotalAppoinment " +
              " FROM msSchedulerV3.dbo.tbl_Customer ";

                if (string.IsNullOrEmpty(CustomerGuid))
                {
                    Sql += " where CompanyID='" + companyid + "' and CustomerID = '" + customerId + "'";
                }
                else
                {
                    Sql += " where CompanyID='" + companyid + "' and CustomerGuid = '" + CustomerGuid + "'";
                }

                db.Open();
                db.Execute(Sql, out dt);
                db.Close();
                string busnessID = "0";

                if (dt.Rows.Count > 0)
                {
                    busnessID = dt.Rows[0]["BusinessID"].ToString();
                    customer.FirstName = dt.Rows[0]["FirstName"].ToString();
                    customer.LastName = dt.Rows[0]["LastName"].ToString();
                    customer.Title = dt.Rows[0]["title"].ToString();
                    customer.JobTitle = dt.Rows[0]["JobTitle"].ToString();
                    customer.Address1 = dt.Rows[0]["Address1"].ToString();
                    customer.City = dt.Rows[0]["City"].ToString();
                    customer.State = dt.Rows[0]["State"].ToString();
                    customer.ZipCode = dt.Rows[0]["ZipCode"].ToString();
                    customer.Phone = dt.Rows[0]["Phone"].ToString();
                    customer.Mobile = dt.Rows[0]["Mobile"].ToString();
                    customer.Email = dt.Rows[0]["Email"].ToString();
                    TotalDueForInvoice = dt.Rows[0]["TotalDueForInvoice"].ToString();
                    TotalDueForEstimate = dt.Rows[0]["TotalDueForEstimate"].ToString();
                    TotalEstimate = dt.Rows[0]["TotalEstimate"].ToString();
                    TotalInvoice = dt.Rows[0]["TotalInvoice"].ToString();
                    TotalAppoinment = dt.Rows[0]["TotalAppoinment"].ToString();
                    customer.Notes = dt.Rows[0]["Notes"].ToString();
                    customer.CompanyName = dt.Rows[0]["CompanyName"].ToString();
                    customer.CustomerID = dt.Rows[0]["CustomerID"].ToString();
                    customer.CustomerGuid = dt.Rows[0]["CustomerGuid"].ToString();
                }

                customer.CustomFields = new Dictionary<string, string>();
                customer.CustomFields.Add("TotalDueForInvoice", TotalDueForInvoice.ToString());
                customer.CustomFields.Add("TotalDueForEstimate", TotalDueForEstimate.ToString());
                customer.CustomFields.Add("TotalEstimate", TotalEstimate.ToString());
                customer.CustomFields.Add("TotalInvoice", TotalInvoice.ToString());
                customer.CustomFields.Add("TotalAppoinment", TotalAppoinment.ToString());
            }
            catch(Exception ex)
            {
                throw ex;
            }

            return customer;
        }
    }
}