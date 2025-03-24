﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Configuration;
using System.Data;


public class Database
{
    private String _ConnectionString;
    public String ConnectionString
    {

        get { return _ConnectionString; }
        set { _ConnectionString = value; }
    }

    private SqlConnection _Connection = new SqlConnection();
    public SqlConnection Connection
    {
        get
        {
            return _Connection;
        }
        set { _Connection = value; }
    }

    private SqlCommand _Command = new SqlCommand();
    public SqlCommand Command
    {
        get { return _Command; }
        set { _Command = value; }
    }


    private SqlParameter _Parameter;
    public SqlParameter Parameter
    {
        get { return _Parameter; }
        set { _Parameter = value; }
    }

    private Exception _Error;
    public Exception Error
    {
        get { return _Error; }
        set { _Error = value; }
    }

    public Database(String connStr)
    {
        this.ConnectionString = connStr;
    }
    public Database()
    {
        this.ConnectionString = ConfigurationManager.AppSettings["ConnString"].ToString();
    }

    public Boolean Open()
    {
        try
        {
            try
            {
                if (this.Connection.State == ConnectionState.Open)
                {
                    this.Close();
                }

            }
            catch { }
        }
        catch (Exception ex)
        {
            this.Error = ex;
            throw ex;
        }
        return true;
    }
    public Boolean Close()
    {
        try
        {
            this.Connection.Close();
        }
        catch (Exception ex)
        {
            this.Error = ex;
            return false;
        }
        return true;
    }

    public void Init(String ProcedureName)
    {
        this.Init(ProcedureName, 0);

    }

    public void Init(String ProcedureName, int CommandTimeout)
    {
        // this.CheckConnnection();
        this.Connection = new SqlConnection(this.ConnectionString);
        this.Command.CommandTimeout = 9999;
        this.Connection.Open();

        this.Command = new SqlCommand();
        this.Command.CommandText = ProcedureName;
        this.Command.CommandType = CommandType.StoredProcedure;
        this.Command.Connection = this.Connection;
        if (CommandTimeout > 0)
        {
            this.Command.CommandTimeout = CommandTimeout;
        }

    }
    public void AddParameter(String name, Object value, SqlDbType type)
    {
        if (value == null)
        {
            if (type == SqlDbType.VarChar || type == SqlDbType.NVarChar)
            {
                value = "";
            }
        }
        this.Parameter = new SqlParameter();
        this.Parameter.ParameterName = name;
        this.Parameter.Value = value;
        this.Parameter.SqlDbType = type;

        this.Parameter.Direction = ParameterDirection.Input;
        if (!this.Command.Parameters.Contains(this.Parameter))
        {
            this.Command.Parameters.Add(this.Parameter);
        }
    }
    public void AddParameter(String name, Object value, int size, SqlDbType type)
    {
        this.Parameter = new SqlParameter();
        this.Parameter.ParameterName = name;
        this.Parameter.Value = value;
        this.Parameter.SqlDbType = type;
        this.Parameter.Size = size;
        this.Parameter.Direction = ParameterDirection.Output;

        if (!this.Command.Parameters.Contains(this.Parameter))
        {
            this.Command.Parameters.Add(this.Parameter);
        }

    }

    public void AddParameter(String name, SqlDbType type, ParameterDirection Direction)
    {

        this.Parameter = new SqlParameter();
        this.Parameter.ParameterName = name;
        this.Parameter.SqlDbType = type;

        this.Parameter.Direction = Direction;
        if (!this.Command.Parameters.Contains(this.Parameter))
        {
            this.Command.Parameters.Add(this.Parameter);
        }
    }

    private SqlDataReader _Reader;
    public SqlDataReader Reader
    {
        //set { _Reader = value; }
        get { return _Reader; }
    }

    public bool HasRows
    {
        get
        {
            try
            {
                return this.Reader.HasRows;
            }
            catch { }
            return false;
        }
    }
    private void CloseReader()
    {
        try
        {
            this._Reader.Close();
        }
        catch { }
    }


    private int GetColumn(SqlDataReader reader, String name)
    {
        int index = reader.GetOrdinal(name);

        return index;
    }
    public Decimal GetDecimal(SqlDataReader reader, String ColumnName)
    {
        try
        {
            return Convert.ToDecimal(reader[ColumnName]);
        }
        catch
        {
            return 0;
        }
    }
    public Decimal GetDecimal(String ColumnName)
    {
        return GetDecimal(this.Reader, ColumnName);
    }

    public int GetInt(SqlDataReader reader, string ColumnName)
    {
        try
        {
            return Convert.ToInt32(reader[ColumnName]);
        }
        catch
        {
            return 0;
        }
    }
    public int GetInt(string ColumnName)
    {
        return this.GetInt(this.Reader, ColumnName);
    }

    public uint GetUInt(SqlDataReader reader, string ColumnName)
    {
        try
        {
            return Convert.ToUInt32(reader[ColumnName]);
        }
        catch
        {
            return 0;
        }
    }
    public uint GetUInt(string ColumnName)
    {
        return this.GetUInt(this.Reader, ColumnName);
    }

    public float GetFloat(SqlDataReader reader, string ColumnName)
    {
        try
        {
            return Convert.ToSingle(reader[ColumnName]);
        }
        catch
        {
            return 0.0F;
        }
    }
    public float GetFloat(string ColumnName)
    {
        return this.GetFloat(this.Reader, ColumnName);
    }

    public ulong GetULong(SqlDataReader reader, string ColumnName)
    {
        try
        {
            return Convert.ToUInt64(reader[ColumnName]);
        }
        catch
        {
            return 0;
        }
    }
    public ulong GetULong(string ColumnName)
    {
        return this.GetULong(this.Reader, ColumnName);
    }


    #region Get Long Value From Reader
    public long GetLong(SqlDataReader reader, string ColumnName)
    {
        try
        {
            return Convert.ToInt64(reader[ColumnName]);
        }
        catch
        {
            return 0;
        }
    }
    public long GetLong(string ColumnName)
    {
        return this.GetLong(this.Reader, ColumnName);
    }
    #endregion

    public String GetString(SqlDataReader reader, String ColumnName)
    {
        try
        {
            return Convert.ToString(reader[ColumnName]);
        }
        catch
        {
            return null;
        }
    }
    public String GetString(String ColumnName)
    {
        return GetString(this.Reader, ColumnName);
    }
    public bool GetBoolean(SqlDataReader reader, string ColumnName)
    {
        try
        {
            return Convert.ToBoolean(reader[ColumnName]);
        }
        catch
        {
            return false;
        }
    }
    public bool GetBoolean(string ColumnName)
    {
        return GetBoolean(this.Reader, ColumnName);
    }


    public DateTime GetDateTime(SqlDataReader reader, string ColumnName)
    {
        try
        {
            return Convert.ToDateTime(reader[ColumnName]);
        }
        catch
        {
            return DateTime.Now;
        }
    }
    public DateTime GetDateTime(string ColumnName)
    {
        return GetDateTime(this.Reader, ColumnName);
    }


    public bool IsExists(String sql)
    {
        try
        {
            this.Command = new SqlCommand(sql, this.Connection);
            object result = this.Command.ExecuteScalar();
            return (result != null);
        }
        catch (Exception ex)
        {
            this.Error = ex;
            //throw new ErrorHandler(ErrorCode.DB_EXECUTE_FAILD, ex.Message);
            throw ex;
        }

    }
    private void CheckConnnection()
    {
        if (this.Connection.State != ConnectionState.Open)
        {
            this.Open();
        }
    }
    /// <summary>
    /// Step 1     : db.init("proc_name");
    /// Step 2     : db.AddParameter(...);
    /// Step 3...n : db.AddParameter(...);
    /// Step n+1   : db.Execute()
    /// </summary>
    /// <returns></returns>
    public Boolean Execute()
    {
        try
        {
            this.Connection = new SqlConnection(this.ConnectionString);
            //this.Command.CommandTimeout = Config.CommandTimeout;
            this.Connection.Open();

            this.CloseReader();
            CheckConnnection();
            this._Reader = this.Command.ExecuteReader();
        }
        catch (Exception ex)
        {
            this.Error = ex;
            //throw new ErrorHandler(ErrorCode.DB_EXECUTE_FAILD, ex.Message);
            throw ex;
            //return false;
        }

        return true;
    }


    /// <summary>
    /// 
    /// </summary>
    /// <param name="sql">Select query w/out condition </param>
    /// <param name="table">If select query retrive data then DataTable has rows. Otherwise DataTable Null</param>
    /// <returns></returns>
    public Boolean Execute(String sql, out DataTable table)
    {
        table = new DataTable();
        try
        {
            String ConnString = this.ConnectionString;
            using (SqlConnection conn = new SqlConnection(ConnString))
            using (SqlDataAdapter adapter = new SqlDataAdapter())
            {
                var cmd = new SqlCommand(sql, conn);
                cmd.CommandType = System.Data.CommandType.Text;

                cmd.CommandTimeout = 900;
                adapter.SelectCommand = cmd;

                // you don't need to open it with Fill
                adapter.Fill(table);
                conn.Close();
            }
        }
        catch (Exception ex)
        {
            this.Error = ex;
            //throw new ErrorHandler(ErrorCode.DB_EXECUTE_FAILD, ex.Message);
            throw ex;
            //return false;
        }

        return true;
    }

    /// <summary>
    /// Step 1     : db.init("proc_name");
    /// Step 2     : db.AddParameter(...);
    /// Step 3...n : db.AddParameter(...);
    /// Step n+1   : db.Execute(out DataTable)
    /// </summary>
    /// <param name="table"></param>
    /// <returns></returns>
    public Boolean Execute(out DataTable table)
    {

        table = new DataTable();
        try
        {
            String ConnString = this.ConnectionString;
            using (SqlConnection conn = new SqlConnection(ConnString))
            using (SqlDataAdapter adapter = new SqlDataAdapter(this.Command))
            {

                this.Command.CommandTimeout = 900;
                this.Command.Connection = conn;
                conn.Open();

                // you don't need to open it with Fill
                adapter.Fill(table);
                conn.Close();
            }


        }
        catch (Exception ex)
        {
            this.Error = ex;
            //throw new ErrorHandler(ErrorCode.DB_EXECUTE_FAILD, ex.Message);
            throw ex;
            //return false;
        }



        return true;
    }
    /// <summary>
    /// 
    /// </summary>
    /// <param name="sql"></param>
    /// <returns></returns>
    public Boolean Execute(string sql)
    {
        try
        {

            String ConnString = this.ConnectionString;
            using (SqlConnection conn = new SqlConnection(ConnString))
            using (SqlDataAdapter adapter = new SqlDataAdapter())
            {
                var cmd = new SqlCommand(sql, conn);
                cmd.CommandType = System.Data.CommandType.Text;
                cmd.CommandTimeout = 900;
                conn.Open();
                cmd.ExecuteNonQuery();
                conn.Close();
            }
        }
        catch (Exception ex)
        {
            //this.Error = ex;
            //return false;
            this.Error = ex;
            //throw new ErrorHandler(ErrorCode.DB_EXECUTE_FAILD, ex.Message);
            throw ex;
        }

        return true;
    }
    public Boolean ExecuteSP(out DataSet _dataset)
    {
        _dataset = new DataSet();
        try
        {
            CheckConnnection();
            this.Command.Connection = this.Connection;
            SqlDataAdapter adapter = new SqlDataAdapter(this.Command);
            adapter.Fill(_dataset);
            this.Connection.Close();
        }
        catch (Exception ex)
        {
            this.Error = ex;
            //throw new ErrorHandler(ErrorCode.DB_EXECUTE_FAILD, ex.Message);
            throw ex;
            //return false;

        }

        return true;
    }
    public Boolean Execute(out DataSet _dataset)
    {
        _dataset = new DataSet();
        try
        {
            String ConnString = this.ConnectionString;
            using (SqlConnection conn = new SqlConnection(ConnString))
            using (SqlDataAdapter adapter = new SqlDataAdapter(this.Command))
            {
                this.Command.Connection = conn;
                conn.Open();

                // you don't need to open it with Fill
                adapter.Fill(_dataset);
                conn.Close();
            }
        }
        catch (Exception ex) { }



        return true;
    }
    public int Update(string sql)
    {
        try
        {
            this.CloseReader();
            CheckConnnection();
            this.Command = new SqlCommand(sql, this.Connection);
            return this.Command.ExecuteNonQuery();
        }
        catch (Exception ex)
        {
            this.Error = ex;
            //throw new ErrorHandler(ErrorCode.DB_EXECUTE_FAILD, ex.Message);
            throw ex;
        }

        return 0;
    }

    #region For Processing Image

    public Byte[] GetImage(String ColumnName)
    {
        try
        {
            int columnIndex = Reader.GetOrdinal(ColumnName);

            //Byte[] image = new Byte[Convert.ToInt32((Reader.GetBytes(columnIndex, 0, 0, 0, Int32.MaxValue)))];
            //Reader.GetBytes(columnIndex, 0, image, 0, image.Length);

            return (Byte[])Reader[ColumnName];//image;
        }
        catch
        {
            return null;
        }

    }

    /*
    public Image GetImage(SqlDataReader reader, string ColumnName)
    {
        try
        {
            byte[] imgData = (byte[])reader[ColumnName];
            MemoryStream ms = new MemoryStream(imgData);
            Image img = Bitmap.FromStream(ms);

            return img;
        }
        catch
        {
            return null;
        }
    }
    public Image GetImage(String ColumnName)
    {
        return this.GetImage(this.Read, ColumnName);            
    }
    */
    public DataSet Get_DataSet(string StoreProcedureName, string CompanyID)
    {
        DataSet myDataTable = new DataSet();
        try
        {
            String ConnString = this.ConnectionString;
            using (SqlConnection conn = new SqlConnection(ConnString))
            using (SqlDataAdapter adapter = new SqlDataAdapter())
            {
                var cmd = new SqlCommand(StoreProcedureName, conn);
                cmd.CommandType = System.Data.CommandType.Text;
                cmd.Parameters.Add("@CompanyID", SqlDbType.VarChar, 100).Value = CompanyID;

                adapter.SelectCommand = cmd;

                // you don't need to open it with Fill
                adapter.Fill(myDataTable);
            }
        }
        catch (Exception ex) { }



        return myDataTable;
    }

    public object ExecuteScalar(string Sql)
    {

        try
        {
            this.Connection = new SqlConnection(this.ConnectionString);
            this.Connection.Open();
            this.Command.Connection = this.Connection;
            this.Command.CommandText = Sql;
            return this.Command.ExecuteScalar();
        }
        catch (Exception ex)
        {
            return 0;
        }
        finally
        {
            this.Connection.Close();
        }
    }

    public object ExecuteScalarData(string sql)
    {
        object result = null;
        try
        {
            this.Connection = new SqlConnection(this.ConnectionString);
            this.Connection.Open();
            this.Command.Connection = this.Connection;
            this.Command.CommandText = sql;
            result = this.Command.ExecuteScalar();
        }
        catch (Exception ex)
        {

        }
        finally
        {
            this.Connection.Close();
        }
        return result;
    }
    public DataTable Get_DataSet_ForGaugeData(string StoreProcedureName, string CompanyID, string TimePeriod)
    {
        DataTable myDataTable = new DataTable();
        try
        {
            String ConnString = this.ConnectionString;
            using (SqlConnection conn = new SqlConnection(ConnString))
            using (SqlDataAdapter adapter = new SqlDataAdapter())
            {
                var cmd = new SqlCommand(StoreProcedureName, conn);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.Add("@CompanyID", SqlDbType.Text).Value = CompanyID;
                cmd.Parameters.Add("@TimePeriod", SqlDbType.Text).Value = TimePeriod;

                adapter.SelectCommand = cmd;

                // you don't need to open it with Fill
                adapter.Fill(myDataTable);
            }
        }
        catch { }



        return myDataTable;
    }
    public DataSet Get_DataSet_ForChartData(string StoreProcedureName, string CompanyID)
    {
        DataSet myDataTable = new DataSet();
        try
        {
            String ConnString = this.ConnectionString;
            using (SqlConnection conn = new SqlConnection(ConnString))
            using (SqlDataAdapter adapter = new SqlDataAdapter())
            {
                var cmd = new SqlCommand(StoreProcedureName, conn);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.Add("@CompanyID", SqlDbType.Text).Value = CompanyID;

                adapter.SelectCommand = cmd;

                // you don't need to open it with Fill
                adapter.Fill(myDataTable);
            }
        }
        catch { }



        return myDataTable;
    }
    #endregion
    public Boolean ExecuteCommand()
    {
        try
        {
            this.Connection = new SqlConnection(this.ConnectionString);
            //this.Command.CommandTimeout = Config.CommandTimeout;
            this.Connection.Open();
            //  CheckConnnection();
            this.Command.Connection = this.Connection;
            this.Command.ExecuteNonQuery();
            this.Connection.Close();
        }
        catch (Exception ex)
        {
            this.Error = ex;
            //throw new ErrorHandler(ErrorCode.DB_EXECUTE_FAILD, ex.Message);
            throw ex;
            //return false;

        }

        return true;
    }

    public Boolean ExecuteParam(String sql, out DataTable table)
    {
        table = new DataTable();

        try
        {
            String ConnString = this.ConnectionString;
            using (SqlConnection conn = new SqlConnection(ConnString))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.CommandType = CommandType.Text;
                cmd.CommandTimeout = 900;

                // Clone parameters instead of reusing them
                foreach (SqlParameter param in this.Command.Parameters)
                {
                    cmd.Parameters.Add(new SqlParameter(param.ParameterName, param.SqlDbType)
                    {
                        Value = param.Value,
                        Size = param.Size,
                        Direction = param.Direction
                    });
                }

                conn.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    // Load paginated email data
                    table.Load(reader);
                }
            }
        }
        catch (Exception ex)
        {
            this.Error = ex;
            throw ex;
        }

        return true;
    }

    public bool IsExist()
    {
        try
        {
            if (this.Connection.State != ConnectionState.Open)
            {
                this.Connection.Open();
            }

            object result = this.Command.ExecuteScalar();
            return result != null && result != DBNull.Value;
        }
        catch (Exception ex)
        {
            this.Error = ex;
            throw;
        }
        finally
        {
            if (this.Connection.State == ConnectionState.Open)
            {
                this.Connection.Close();
            }
        }
    }
}


