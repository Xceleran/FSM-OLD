using FSM.Models.Customer;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace FSM
{
    public partial class BillableItems : System.Web.UI.Page
    {
        //static string connStr = ConfigurationManager.AppSettings["ConnString"].ToString();
        static string connStrJobs = ConfigurationManager.AppSettings["ConnStrJobs"].ToString();
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static List<ItemTypes> GetItemTypes()
        {
            var items = new List<ItemTypes>();
            string companyid = HttpContext.Current.Session["CompanyID"].ToString();
            Database db = new Database(connStrJobs);
            try
            {
                db.Open();
                DataTable dt = new DataTable();
                string sql = @"Select * from [myServiceJobs].[dbo].[ItemTypes]";
                db.Execute(sql, out dt);
                db.Close();
                if (dt.Rows.Count > 0)
                {
                    foreach (DataRow row in dt.Rows)
                    {
                        var itemType = new ItemTypes();
                        itemType.Id = Convert.ToInt32(row["Id"].ToString());
                        itemType.Name = row.Field<string>("Name") ?? "";
                        items.Add(itemType);
                    }
                }
            }
            catch(Exception ex)
            {
                return items;
            }
            finally
            {
                db.Close();
            }

            return items;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static List<Item> GetBillableItems()
        {
            var items = new List<Item>();
            string companyid = HttpContext.Current.Session["CompanyID"].ToString();
            Database db = new Database();
            try
            {
                db.Open();
                DataTable dt = new DataTable();
                string sql = @"select Id,Name as ItemName, ItemTypeId, Description, Location, Barcode,(case when IsTaxable = 'FALSE' then 'NO' else 'YES' end )as IsTaxable, Price 
                from [msSchedulerV3].[dbo].[Items] where IsDeleted = 0 and CompanyId= '" + companyid + "' order by ItemName;";

                db.ExecuteParam(sql, out dt);
                db.Close();
                if (dt.Rows.Count > 0)
                {
                    foreach (DataRow row in dt.Rows)
                    {
                        var item = new Item();
                        item.CompanyID = companyid;
                        item.Id = row.Field<string>("Id") ?? "";
                        item.ItemName = row.Field<string>("ItemName") ?? "";
                        item.Barcode = row.Field<string>("Barcode") ?? "";
                        item.Description = row.Field<string>("Description") ?? "";
                        item.Taxable = row.Field<string>("IsTaxable") ?? "";
                        item.Location = row.Field<string>("Location") ?? "";
                        item.Price = row.Field<decimal>("Price");
                        item.ItemTypeId = Convert.ToInt32(row["ItemTypeId"].ToString());

                        items.Add(item);
                    }
                }
            }
            catch (Exception ex)
            {
                return items;
            }
            finally
            {
                db.Close();
            }

            return items;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static Item GetItemById(string itemId)
        {
            var item = new Item();
            string companyid = HttpContext.Current.Session["CompanyID"].ToString();
            if (!string.IsNullOrWhiteSpace(itemId))
            {
                Database db = new Database();
                try
                {
                    db.Open();
                    DataTable dt = new DataTable();
                    string sql = "select * from [msSchedulerV3].[dbo].[Items] where Id='" + itemId + "' and CompanyId= '" + companyid + "';";
                    db.Execute(sql, out dt);
                    db.Close();
                    if (dt.Rows.Count > 0)
                    {
                        DataRow dItem = dt.Rows[0];
                        item.CompanyID = companyid;
                        item.Id = dItem.Field<string>("Id") ?? "";
                        item.ItemName = dItem.Field<string>("Name") ?? "";
                        item.Barcode = dItem.Field<string>("Barcode") ?? "";
                        item.Description = dItem.Field<string>("Description") ?? "";
                        item.IsTaxable = bool.Parse(dItem["IsTaxable"].ToString());
                        item.Location = dItem.Field<string>("Location") ?? "";
                        item.Price = dItem.Field<decimal>("Price");
                        item.ItemTypeId = Convert.ToInt32(dItem["ItemTypeId"].ToString());
                    }
                }
                catch(Exception ex)
                {
                    return item;
                }
                finally
                {
                    db.Close();
                }
            }
            return item;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static bool SaveItemData(Item itemData)
        {
            if (!string.IsNullOrWhiteSpace(itemData.Id))
            {
                return UpdateItemData(itemData);
            }

            return false;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static bool UpdateItemData(Item itemData)
        {
            bool success = false;
            Database db = new Database();
            try
            {
                db.Open();
                string strSQL = @"UPDATE [msSchedulerV3].[dbo].[Items] SET 
                                    Name = @Name,
                                    Description = @Description,
                                    Barcode = @Barcode,
                                    Location = @Location,
                                    Price = @Price,
                                    ItemTypeId = @ItemTypeId,
                                    IsTaxable = @IsTaxable,
                                    ModifiedDate = GetDate()
                                    WHERE Id = @Id and CompanyId = @CompanyId";
                db.AddParameter("@Name", itemData.ItemName ?? (object)DBNull.Value, SqlDbType.NVarChar);
                db.AddParameter("@Description", itemData.Description ?? (object)DBNull.Value, SqlDbType.NVarChar);
                db.AddParameter("@Barcode", itemData.Barcode ?? (object)DBNull.Value, SqlDbType.NVarChar);
                db.AddParameter("@Location", itemData.Location ?? (object)DBNull.Value, SqlDbType.NVarChar);
                db.AddParameter("@Price", itemData.Price, SqlDbType.Decimal);
                db.AddParameter("@ItemTypeId", itemData.ItemTypeId, SqlDbType.Int);
                db.AddParameter("@Id", itemData.Id ?? (object)DBNull.Value, SqlDbType.NVarChar);
                db.AddParameter("@IsTaxable", itemData.IsTaxable, SqlDbType.Bit);
                db.AddParameter("@CompanyId", itemData.CompanyID ?? (object)DBNull.Value, SqlDbType.NVarChar);
                success = db.UpdateSql(strSQL);
            }
            catch (Exception ex)
            {
                success = false;
            }
            finally
            {
                db.Close();
            }
            return success;
        }
    }


    public class Item
    {
        public string CompanyID { get; set; }
        public string Id { get; set; }
        public string ItemName { get; set; }
        public string Description { get; set; }
        public string Barcode { get; set; }
        public string Taxable { get; set; }
        public bool IsTaxable { get; set; }
        public decimal Price { get; set; }
        public string Location { get; set; }
        public int ItemTypeId { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime ModifiedDate { get; set; }
        public string CreatedBy { get; set; }
        public string ModifiedBy { get; set; }

    }

    public class ItemTypes
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string QboId { get; set; }
    }
}