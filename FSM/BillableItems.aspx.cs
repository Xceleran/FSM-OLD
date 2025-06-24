using FSM.Entity.Customer;
using FSM.Helper;
using FSM.Processors;
using Intuit.Ipp.Core;
using Intuit.Ipp.Data;
using Intuit.Ipp.DataService;
using Intuit.Ipp.QueryFilter;
using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel.Design;
using System.Configuration;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Serialization;

namespace FSM
{
    public partial class BillableItems : System.Web.UI.Page
    {
        static string connStr = ConfigurationManager.AppSettings["ConnString"].ToString();
        static string connStrJobs = ConfigurationManager.AppSettings["ConnStrJobs"].ToString();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["CompanyID"] == null)
            {
                Response.Redirect("Dashboard.aspx");
            }

            string companyid = HttpContext.Current.Session["CompanyID"].ToString();
            companyId.Attributes.Add("value", companyid);
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static List<ItemTypes> GetItemTypes()
        {
            var items = new List<ItemTypes>();
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
                string sql = @"select Id,Name as ItemName, ItemTypeId, Description, Location, Sku, Quantity, QboId,(case when IsTaxable = 'FALSE' then 'NO' else 'YES' end )as IsTaxable, Price 
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
                        item.QboId = row.Field<decimal>("QboId").ToString();
                        item.Description = row.Field<string>("Description") ?? "";
                        item.Taxable = row.Field<string>("IsTaxable") ?? "";
                        item.Location = row.Field<string>("Location") ?? "";
                        item.Sku = row.Field<string>("Sku") ?? "";
                        item.Price = row.Field<decimal>("Price");
                        var quantityValue = row["Quantity"];
                        item.Quantity = quantityValue != DBNull.Value ? Convert.ToDecimal(quantityValue) : 0;
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
                        item.QboId = dItem.Field<decimal>("QboId").ToString();
                        item.ItemName = dItem.Field<string>("Name") ?? "";
                        item.Description = dItem.Field<string>("Description") ?? "";
                        item.IsTaxable = bool.Parse(dItem["IsTaxable"].ToString());
                        item.Location = dItem.Field<string>("Location") ?? "";
                        item.Price = dItem.Field<decimal>("Price");
                        item.Sku = dItem.Field<string>("Sku") ?? "";
                        var quantityValue = dItem["Quantity"];
                        item.Quantity = quantityValue != DBNull.Value ? Convert.ToDecimal(quantityValue) : 0;
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
        public static bool SaveItem(Item itemData)
        {
            if (!string.IsNullOrWhiteSpace(itemData.Id))
            {
                return UpdateItemData(itemData);
            }
            else
            {
                return InsertItemData(itemData);
            }
        }

        public static bool InsertItemData(Item itemData)
        {
            bool success = false;
            Database db = new Database(connStr);
            try
            {
                int QboItemId = 0;
                string query = "select count(*) from Items where Name='" + Common.CleanInput(itemData.ItemName) + "' and CompanyID='" + itemData.CompanyID + "' and IsDeleted=0 ";
                DataTable dt;
                db.Execute(query, out dt);

                if (dt.Rows[0][0].ToString() == "0")
                {
                    try
                    {
                        QBSaveItem(ref QboItemId, itemData);
                        itemData.QboId = QboItemId.ToString();
                    }
                    catch (Exception ex) {
                        throw new ApplicationException(ex.Message.ToString());
                    }

                    string id = Guid.NewGuid().ToString();
                    string strSQL = @"INSERT INTO [msSchedulerV3].[dbo].[Items]
                        (Id, QboId, CompanyId, Name, Description, Sku, Location, Price, Quantity, ItemTypeId, IsTaxable, IsDeleted, CreatedDate) output INSERTED.ID
                        VALUES (@Id, @QboId, @CompanyId, @Name, @Description, @Sku, @Location, @Price, @Quantity, @ItemTypeId, @IsTaxable, @IsDeleted, GETDATE())";
                    db.AddParameter("@Name", itemData.ItemName ?? (object)DBNull.Value, SqlDbType.NVarChar);
                    db.AddParameter("@Description", itemData.Description ?? (object)DBNull.Value, SqlDbType.NVarChar);
                    db.AddParameter("@Sku", itemData.Sku ?? (object)DBNull.Value, SqlDbType.NVarChar);
                    db.AddParameter("@Location", itemData.Location ?? (object)DBNull.Value, SqlDbType.NVarChar);
                    db.AddParameter("@Price", itemData.Price, SqlDbType.Decimal);
                    db.AddParameter("@Quantity", itemData.Quantity, SqlDbType.Decimal);
                    db.AddParameter("@ItemTypeId", itemData.ItemTypeId, SqlDbType.Int);
                    db.AddParameter("@Id", id, SqlDbType.NVarChar);
                    db.AddParameter("@QboId", itemData.QboId, SqlDbType.Decimal);
                    db.AddParameter("@IsTaxable", itemData.IsTaxable, SqlDbType.Bit);
                    db.AddParameter("@IsDeleted", 0, SqlDbType.Bit);
                    db.AddParameter("@CompanyId", itemData.CompanyID ?? (object)DBNull.Value, SqlDbType.NVarChar);
                    object result = db.ExecuteScalarData(strSQL);
                    if (result != null)
                    {
                        db.Close();
                        success = SaveItemJobsDb(itemData);
                    }
                }
                else
                    throw new ApplicationException("Item Name Exist !!");
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

        private static bool SaveItemJobsDb(Item itemData)
        {
            bool success = false;
            Database db = new Database(connStrJobs);
            try
            {
                string id = Guid.NewGuid().ToString();
                if (itemData.CompanyID.All(char.IsNumber))
                {
                    string strSQL = @"INSERT INTO [myServiceJobs].[dbo].[Items]
                        (Id, QboId, CompanyId, Name, Description, Sku, Price, Quantity, ItemTypeId, IsTaxable, IsDeleted, CreatedDate) output INSERTED.ID
                        VALUES (@Id, @QboId, @CompanyId, @Name, @Description, @Sku, @Price, @Quantity, @ItemTypeId, @IsTaxable, @IsDeleted, GETDATE())";
                    db.AddParameter("@Name", itemData.ItemName ?? (object)DBNull.Value, SqlDbType.NVarChar);
                    db.AddParameter("@Description", itemData.Description ?? (object)DBNull.Value, SqlDbType.NVarChar);
                    db.AddParameter("@Sku", itemData.Sku ?? (object)DBNull.Value, SqlDbType.NVarChar);
                    db.AddParameter("@Price", itemData.Price, SqlDbType.Decimal);
                    db.AddParameter("@Quantity", itemData.Quantity, SqlDbType.Decimal);
                    db.AddParameter("@ItemTypeId", itemData.ItemTypeId, SqlDbType.Int);
                    db.AddParameter("@Id", id, SqlDbType.NVarChar);
                    db.AddParameter("@QboId", itemData.QboId, SqlDbType.Decimal);
                    db.AddParameter("@IsTaxable", itemData.IsTaxable, SqlDbType.Bit);
                    db.AddParameter("@IsDeleted", 0, SqlDbType.Bit);
                    db.AddParameter("@CompanyId", itemData.CompanyID ?? (object)DBNull.Value, SqlDbType.NVarChar);
                    object result = db.ExecuteScalarData(strSQL);
                    if (result != null)
                    {
                        success = true;
                    }
                }
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

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static bool UpdateItemData(Item itemData)
        {
            bool success = false;
            Database db = new Database(connStr);
            try
            {
                db.Open();
                string Sql = "select Id,Name from Items where Id='" + Common.CleanInput(itemData.Id) + "' and CompanyID='" + itemData.CompanyID + "' ";
                DataTable dtItems;
                db.Execute(Sql, out dtItems);
                string strSQL = @"UPDATE [msSchedulerV3].[dbo].[Items] SET 
                                    Name = @Name,
                                    Description = @Description,
                                    Sku = @Sku,
                                    Quantity = @Quantity,
                                    Location = @Location,
                                    Price = @Price,
                                    ItemTypeId = @ItemTypeId,
                                    IsTaxable = @IsTaxable,
                                    ModifiedDate = GetDate()
                                    WHERE Id = @Id and CompanyId = @CompanyId";
                db.AddParameter("@Name", itemData.ItemName ?? (object)DBNull.Value, SqlDbType.NVarChar);
                db.AddParameter("@Description", itemData.Description ?? (object)DBNull.Value, SqlDbType.NVarChar);
                db.AddParameter("@Sku", itemData.Sku ?? (object)DBNull.Value, SqlDbType.NVarChar);
                db.AddParameter("@Location", itemData.Location ?? (object)DBNull.Value, SqlDbType.NVarChar);
                db.AddParameter("@Price", itemData.Price, SqlDbType.Decimal);
                db.AddParameter("@Quantity", itemData.Quantity, SqlDbType.Decimal);
                db.AddParameter("@ItemTypeId", itemData.ItemTypeId, SqlDbType.Int);
                db.AddParameter("@Id", itemData.Id ?? (object)DBNull.Value, SqlDbType.NVarChar);
                db.AddParameter("@IsTaxable", itemData.IsTaxable, SqlDbType.Bit);
                db.AddParameter("@CompanyId", itemData.CompanyID ?? (object)DBNull.Value, SqlDbType.NVarChar);
                success = db.UpdateSql(strSQL);
                db.Close();
                if (success)
                {
                    UpdateItemJobsDb(dtItems, itemData);
                    QBUpdateItem(itemData);
                }
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

        private static bool UpdateItemJobsDb(DataTable dtItems, Item itemData)
        {
            bool success = false;
            Database db = new Database(connStrJobs);
            try
            {
                string Sql = "select Id from Items where Name='" + dtItems.Rows[0]["Name"].ToString() + "' and CompanyID='" + itemData.CompanyID + "' ";
                DataTable dt;
                db.Execute(Sql, out dt);
                if (dt.Rows.Count > 0)
                {
                    string jId = dt.Rows[0]["Id"].ToString();
                    string strSQL = @"UPDATE [myServiceJobs].[dbo].[Items] SET 
                                    Name = @Name,
                                    Description = @Description,
                                    Sku = @Sku,
                                    Quantity = @Quantity,
                                    Price = @Price,
                                    ItemTypeId = @ItemTypeId,
                                    IsTaxable = @IsTaxable,
                                    ModifiedDate = GetDate()
                                    WHERE Id = @Id";
                    db.AddParameter("@Name", itemData.ItemName ?? (object)DBNull.Value, SqlDbType.NVarChar);
                    db.AddParameter("@Description", itemData.Description ?? (object)DBNull.Value, SqlDbType.NVarChar);
                    db.AddParameter("@Sku", itemData.Sku ?? (object)DBNull.Value, SqlDbType.NVarChar);
                    db.AddParameter("@Price", itemData.Price, SqlDbType.Decimal);
                    db.AddParameter("@Quantity", itemData.Quantity, SqlDbType.Decimal);
                    db.AddParameter("@ItemTypeId", itemData.ItemTypeId, SqlDbType.Int);
                    db.AddParameter("@Id", jId ?? (object)DBNull.Value, SqlDbType.NVarChar);
                    db.AddParameter("@IsTaxable", itemData.IsTaxable, SqlDbType.Bit);
                    success = db.UpdateSql(strSQL);
                }
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

        private static bool QBUpdateItem(Item itemData)
        {
            string ItemId = itemData.Id;
            Database db = new Database(connStr);
            string CompanyID = HttpContext.Current.Session["CompanyID"].ToString();
            //  db.Open();
            string query = "select QboId from Items where Id='" + ItemId + "' and CompanyID='" + CompanyID + "' ";
            DataTable dt;
            db.Execute(query, out dt);

            string QId = dt.Rows[0]["QboId"].ToString();

            if (!string.IsNullOrEmpty(QId) && QId != "0")
            {
                QBOSettins qBoStng = new QBOSettins();
                QBOManager qBOManager = new QBOManager();
                if (qBOManager.VerifyCompanySetting(CompanyID, ref qBoStng))
                {
                    try
                    {
                        ServiceContext serviceContext = qBOManager.GetServiceContext(qBoStng, CompanyID);
                        Intuit.Ipp.Data.Item objItemFound = null;
                        if (serviceContext != null)
                        {
                            QueryService<Intuit.Ipp.Data.Item> qsItem = new QueryService<Intuit.Ipp.Data.Item>(serviceContext);
                            string qboQuery = string.Format("select * from Item where Id = '" + QId + "'");
                            objItemFound = qsItem.ExecuteIdsQuery(qboQuery).FirstOrDefault<Intuit.Ipp.Data.Item>();
                        }

                        if (objItemFound != null)
                        {
                            string itemName = qBOManager.GetItemTypeNameById(itemData.ItemTypeId);
                            Intuit.Ipp.Data.Item Itm = new Intuit.Ipp.Data.Item();
                            Itm.Id = objItemFound.Id;
                            Itm.SyncToken = objItemFound.SyncToken;
                            Itm.Name = itemData.ItemName;
                            Itm.Description = itemData.Description;
                            Itm.Taxable = itemData.IsTaxable;
                            Itm.UnitPrice = itemData.Price;
                            Itm.QtyOnHand = itemData.Quantity;
                            Itm.Sku = itemData.Sku;
                            if (Enum.TryParse<ItemTypeEnum>(itemName, ignoreCase: true, out var itemType))
                            {
                                Itm.Type = itemType;
                            }
                            else Itm.Type = objItemFound.Type;

                            Itm.TypeSpecified = objItemFound.TypeSpecified;
                            Itm.TrackQtyOnHand = objItemFound.TrackQtyOnHand;
                            Itm.TrackQtyOnHandSpecified = objItemFound.TrackQtyOnHandSpecified;
                            Itm.QtyOnHandSpecified = objItemFound.QtyOnHandSpecified;
                           
                            Itm.InvStartDateSpecified = objItemFound.InvStartDateSpecified;
                            Itm.InvStartDate = objItemFound.InvStartDate;

                            Itm.UnitPriceSpecified = objItemFound.UnitPriceSpecified;
                            Itm.PurchaseDesc = objItemFound.PurchaseDesc;

                            Itm.PurchaseCostSpecified = objItemFound.PurchaseCostSpecified;
                            Itm.PurchaseCost = objItemFound.PurchaseCost;

                            Itm.AssetAccountRef = objItemFound.AssetAccountRef;
                            Itm.IncomeAccountRef = objItemFound.IncomeAccountRef;
                            Itm.ExpenseAccountRef = objItemFound.ExpenseAccountRef;

                            //Itm.IncomeAccountRef = new ReferenceType();
                            //Itm.IncomeAccountRef.Value = "1";

                            DataService dataService = new DataService(serviceContext);
                            //Intuit.Ipp.Data.Item Item = dataService.Add(Itm);
                            //ItemId = Convert.ToInt16(Item.Id);
                            Intuit.Ipp.Data.Item UpdateEntity = dataService.Update<Intuit.Ipp.Data.Item>(Itm);

                        }
                        return true;
                    }
                    catch (Intuit.Ipp.Exception.IdsException ex)
                    {
                        string errDetail = "";
                        var innerException = ((Intuit.Ipp.Exception.ValidationException)(ex.InnerException)).InnerExceptions.FirstOrDefault();
                        if (innerException != null)
                        {
                            errDetail = innerException.Detail;
                            //throw new ApplicationException(innerException.Detail);
                        }
                        return false;
                    }
                }
                else
                    return false;
            }
            else return false;
        }

        // Sync With QBO -- Yuvi
        [WebMethod(EnableSession = false)]
        public static string SyncQBOItems()
        {
            bool saveStat = false;
            try
            {
                string QboLastUpdatedTime = string.Empty;

                string Sql = @"SELECT QboLastUpdatedTime FROM [msSchedulerV3].[dbo].[tbl_Company]  Where [CompanyID] = '" + HttpContext.Current.Session["CompanyID"].ToString() + "'";

                Database db = new Database(ConfigurationManager.AppSettings["ConnString"].ToString());

                DataTable dt = new DataTable();

                QboLastUpdatedTime = db.ExecuteScalarString(Sql);
                if (string.IsNullOrEmpty(QboLastUpdatedTime))
                {
                    QboLastUpdatedTime = "1990-01-01T00:00:00";
                }

                QboLastUpdatedTime = Convert.ToDateTime(QboLastUpdatedTime).ToString("yyyy-MM-ddTHH:mm:ss");

                QBOSettins qBoStngPost = new QBOSettins();
                QBOManager qBOManager = new QBOManager();
                if (qBOManager.VerifyCompanySetting(HttpContext.Current.Session["CompanyID"].ToString(), ref qBoStngPost))
                {
                    ServiceContext context = qBOManager.GetServiceContext(qBoStngPost, HttpContext.Current.Session["CompanyID"].ToString());
                    saveStat = qBOManager.ItemSynchronization(qBoStngPost, HttpContext.Current.Session["CompanyID"].ToString(), context, QboLastUpdatedTime);
                }
                if (saveStat)
                    return "Items have been synchronized.";
                else
                    return "Item Synchronization failed.";
            }
            catch
            {
                return "Item Synchronization failed.";
            }
        }

        private static bool QBSaveItem(ref int ItemId, Item itemData)
        {

            string cId = itemData.CompanyID;
            QBOSettins qBoStng = new QBOSettins();
            QBOManager qBOManager = new QBOManager();
            if (qBOManager.VerifyCompanySetting(cId, ref qBoStng))
            {
                try
                {
                    ServiceContext serviceContext = qBOManager.GetServiceContext(qBoStng, cId);

                    string qboQuery = "select * from Item ";
                    QueryService<Intuit.Ipp.Data.Item> qsItem = new QueryService<Intuit.Ipp.Data.Item>(serviceContext);
                    List<Intuit.Ipp.Data.Item> listItems = qsItem.ExecuteIdsQuery(qboQuery).ToList<Intuit.Ipp.Data.Item>();

                    bool isExists = false;
                    foreach (Intuit.Ipp.Data.Item ilst in listItems)
                    {
                        if (ilst.Name == itemData.ItemName)
                        {
                            ItemId = Convert.ToInt16(ilst.Id);
                            isExists = true;
                        }
                    }
                    if (!isExists)
                    {
                        Intuit.Ipp.Data.Item Itm = new Intuit.Ipp.Data.Item();
                        string itemName = qBOManager.GetItemTypeNameById(itemData.ItemTypeId);
                        Itm.Name = itemData.ItemName;
                        Itm.Description = itemData.Description;
                        Itm.Taxable = itemData.IsTaxable;
                        Itm.UnitPrice = itemData.Price;
                        Itm.TypeSpecified = true;
                        //if (Enum.TryParse<ItemTypeEnum>(itemName, ignoreCase: true, out var itemType))
                        //{
                        //    Itm.Type = itemType;
                        //}
                        //else 
                            
                        Itm.Type = ItemTypeEnum.Service;
                        Itm.Sku = itemData.Sku;

                        Itm.TrackQtyOnHand = false;
                        Itm.TrackQtyOnHandSpecified = false;
                        Itm.QtyOnHandSpecified = false;
                        Itm.QtyOnHand = itemData.Quantity;

                        Itm.InvStartDateSpecified = true;
                        Itm.InvStartDate = DateTime.Now;
                        Itm.UnitPriceSpecified = true;
                        Itm.PurchaseDesc = "";
                        Itm.PurchaseCostSpecified = true;
                        Itm.PurchaseCost = 0;

                        //Itm.TrackQtyOnHand = true;
                        //Itm.TrackQtyOnHandSpecified = true;
                        //Itm.QtyOnHandSpecified = true;
                        //
                        //Itm.InvStartDateSpecified = true;
                        //Itm.InvStartDate = DateTime.Now;
                        //Itm.UnitPriceSpecified = true;
                        //Itm.PurchaseDesc = "";
                        //Itm.PurchaseCostSpecified = true;
                        //Itm.PurchaseCost = 0;


                        //string AccTypeId = "";
                        //QBOManager.AccountTypeCheck(qBoStng, CompanyID, ItemTypeId.SelectedValue, ref AccTypeId);
                        //Itm.IncomeAccountRef = new ReferenceType();
                        //Itm.IncomeAccountRef.Value = AccTypeId;

                        Itm.IncomeAccountRef = new ReferenceType();
                        Itm.IncomeAccountRef.Value = "1";

                        //Itm.IncomeAccountRef = new ReferenceType();
                        //Itm.IncomeAccountRef.Value = "79";

                        //Itm.ExpenseAccountRef = new ReferenceType();
                        //Itm.ExpenseAccountRef.Value = "80";

                        //Itm.AssetAccountRef = new ReferenceType();
                        //Itm.AssetAccountRef.Value = "81";

                        //QueryService<Intuit.Ipp.Data.Account> querySvc = new QueryService<Intuit.Ipp.Data.Account>(serviceContext);
                        //var AccountList = querySvc.ExecuteIdsQuery("SELECT * FROM Account").ToList();
                        //var AssetAccountRef = AccountList.Where(x => x.AccountType == AccountTypeEnum.OtherCurrentAsset && x.Name == "Inventory Asset").FirstOrDefault();
                        //if (AssetAccountRef != null)
                        //{
                        //    Itm.AssetAccountRef = new ReferenceType();
                        //    Itm.AssetAccountRef.Value = AssetAccountRef.Id;
                        //}

                        //var IncomeAccountRef = AccountList.Where(x => x.AccountType == AccountTypeEnum.Income && x.Name == "Sales of Product Income").FirstOrDefault();
                        //if (IncomeAccountRef != null)
                        //{
                        //    Itm.IncomeAccountRef = new ReferenceType();
                        //    Itm.IncomeAccountRef.Value = IncomeAccountRef.Id;
                        //}

                        //var ExpenseAccountRef = AccountList.Where(x => x.AccountType == AccountTypeEnum.CostofGoodsSold && x.Name == "Cost of Goods Sold").FirstOrDefault();
                        //if (ExpenseAccountRef != null)
                        //{
                        //    Itm.ExpenseAccountRef = new ReferenceType();
                        //    Itm.ExpenseAccountRef.Value = ExpenseAccountRef.Id;
                        //}

                        DataService dataService = new DataService(serviceContext);
                        Intuit.Ipp.Data.Item Item = dataService.Add(Itm);
                        ItemId = Convert.ToInt16(Item.Id);
                    }
                    return true;
                }
                catch (Intuit.Ipp.Exception.IdsException ex)
                {
                    string errDetail = "";
                    var innerException = ((Intuit.Ipp.Exception.ValidationException)(ex.InnerException)).InnerExceptions.FirstOrDefault();
                    if (innerException != null)
                    {
                        errDetail = innerException.Detail;
                        throw new ApplicationException(innerException.Detail);
                    }
                    return false;
                }
            }
            else
                return false;
        }
    }


    public class Item
    {
        public string CompanyID { get; set; }
        public string Id { get; set; }
        public string QboId { get; set; }
        public string ItemName { get; set; }
        public string Description { get; set; }
        public string Barcode { get; set; }
        public string Sku { get; set; }
        public decimal Quantity { get; set; }
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

    public enum ItemTypeFSMEnum
    {
        Group,
        Inventory,
        NonInventory = 3,
        OtherCharge = 4,
        Payment,
        Service = 1,
        Bundle
    }
}