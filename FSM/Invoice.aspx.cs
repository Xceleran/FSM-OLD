using FSM.Models.Customer;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel.Design;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace FSM
{
    public partial class Invoice : System.Web.UI.Page
    {
        string CompanyID = "";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["CompanyID"] == null)
            {
                //Response.Redirect("Logout.aspx");
            }
            if (!IsPostBack)
            {
                CompanyID = Session["CompanyID"].ToString();
            }

        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string GetCustomerInvoices(int draw, int start, int length, string searchValue, string sortColumn, string sortDirection, 
            string invoiceStatus, string fromDate, string toDate)
        {
            var invoices = new List<CustomerInvoice>();
            string companyid = HttpContext.Current.Session["CompanyID"].ToString();
            int totalRecords = 0;
            Database db = new Database();
            try
            {
                string whereCondition = "WHERE CompnyID = '" + companyid + "' ";
                if (!string.IsNullOrEmpty(searchValue))
                {
                    whereCondition += "AND (FirstName LIKE '%" + searchValue + "%' OR InvoiceDate LIKE '%" + searchValue + "%' OR Number LIKE '%" + searchValue + "%' OR Type LIKE '%" + searchValue + "%' OR LastName LIKE '%" + searchValue + "%') ";
                }

                if (!string.IsNullOrEmpty(invoiceStatus))
                {
                    if (invoiceStatus == "Paid")
                        whereCondition += " AND (Total - ISNULL(AmountCollect, 0)) <= 0 ";
                    else if (invoiceStatus == "Due")
                        whereCondition += " AND (Total - ISNULL(AmountCollect, 0)) > 0 ";
                }

                if (!string.IsNullOrEmpty(fromDate) && !string.IsNullOrEmpty(toDate))
                {
                    whereCondition += $" AND CONVERT(DATE, InvoiceDate) BETWEEN CONVERT(DATE, '{fromDate}') AND CONVERT(DATE, '{toDate}') ";
                }

                string countSql = @"SELECT COUNT(*) FROM [msSchedulerV3].[dbo].[tbl_Invoice] as inv left join [msSchedulerV3].[dbo].[tbl_Customer] 
                                    as cus on inv.CustomerId = cus.CustomerID and inv.CompnyID = cus.CompanyID " + whereCondition;
                db.Open();
                object result = db.ExecuteScalar(countSql);
                if (result != null)
                {
                    totalRecords = Convert.ToInt32(result);
                }
                db.Close();

                DataTable dt = new DataTable();
                string sql = $@"select ID, cus.FirstName, cus.LastName, inv.CustomerId, Number, Subtotal, isnull([AmountCollect],0.00) as AmountCollect,
                            isnull([DepositAmount],0.00) as DepositAmount, Discount, Tax, (Total- (isnull(AmountCollect,0.00))) as Due, 
                            Type, CONVERT(VARCHAR(10), InvoiceDate, 101) as InvoiceDate, Total from [msSchedulerV3].[dbo].[tbl_Invoice] as inv 
                            left join [msSchedulerV3].[dbo].[tbl_Customer] as cus on inv.CustomerId = cus.CustomerID and inv.CompnyID = cus.CompanyID
                            {whereCondition} ORDER BY {sortColumn} {sortDirection} OFFSET {start} ROWS FETCH NEXT {length} ROWS ONLY;";

                db.Open();
                db.Execute(sql, out dt);
                db.Close();
                if (dt.Rows.Count > 0)
                {
                    foreach (DataRow row in dt.Rows)
                    {
                        var invoice = new CustomerInvoice();
                        invoice.CustomerID = row.Field<string>("CustomerId") ?? ""; 
                        invoice.CustomerName = $"{row.Field<string>("FirstName") ?? ""} {row.Field<string>("LastName") ?? ""}".Trim();
                        invoice.CompanyID = companyid;
                        invoice.InvoiceNumber = row.Field<string>("Number") ?? "";
                        invoice.InvoiceDate = row.Field<string>("InvoiceDate") ?? "";
                        invoice.InvoiceType = row.Field<string>("Type") ?? "";
                        invoice.Subtotal = row["Subtotal"].ToString() ?? "0.0";
                        invoice.Total = row["Total"].ToString() ?? "0.0";
                        invoice.Due = row["Due"].ToString() ?? "0.0";
                        invoice.Discount = row["Discount"].ToString() ?? "0.0";
                        invoice.Tax = row["Tax"].ToString() ?? "0.0";
                        invoice.DepositAmount = row["DepositAmount"].ToString() ?? "0.0";
                        invoice.ID = row["ID"].ToString() ?? "";
                        if ((Convert.ToDouble(row["Total"].ToString()) - Convert.ToDouble(row["AmountCollect"].ToString())) <= 0)
                        {
                            invoice.InvoiceStatus = "Paid";
                        }
                        else
                        {
                            invoice.InvoiceStatus = "Due";
                        }

                        invoices.Add(invoice);
                    }
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new { error = ex.Message });
            }
            finally
            {
                db.Close();
            }
            var response = new
            {
                draw = draw,
                recordsTotal = totalRecords,
                recordsFiltered = totalRecords,
                data = invoices
            };

            return JsonConvert.SerializeObject(response);
        }
    }
}