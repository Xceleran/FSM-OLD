using Microsoft.Ajax.Utilities;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Net.NetworkInformation;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using static System.Runtime.CompilerServices.RuntimeHelpers;

namespace FSM.Processors
{
    public class QBOManager
    {
        public bool VerifyCompanySetting(string CompanyID, ref QBOSettins qboSettings)
        {
            bool bRetVal = false;

            try
            {
                Database db = new Database();
                //  db.Open();
                string Sql = "select AccessToken, RefreshToken, BQOFileID, CompanyID, ConnectedCompanyName from [myServiceJobs].[dbo].[QBOCompanySettings] where CompanyID='" + CompanyID + "'";

                DataTable dt;

                db.Execute(Sql, out dt);

                if (dt.Rows.Count > 0)
                {
                    DataRow dr = dt.Rows[0];
                    qboSettings = new QBOSettins();
                    qboSettings.AccessToken = dr["AccessToken"].ToString();
                    qboSettings.RefreshToken = dr["RefreshToken"].ToString();
                    qboSettings.FileID = dr["BQOFileID"].ToString();
                    qboSettings.ConnectedCompanyName = dr["ConnectedCompanyName"].ToString();
                    qboSettings.isQBConnected = true;
                    bRetVal = true;
                }
                db.Close();
            }
            catch (Exception ex)
            {

            }

            return bRetVal;
        }
        
    }
}
