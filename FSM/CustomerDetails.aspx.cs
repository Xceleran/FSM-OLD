using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace FSM
{
    public partial class CustomerDetails : System.Web.UI.Page  // Changed from 'Customer' to 'Customers'
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string customerId = Request.QueryString["custId"];
            string customerGuid = Request.QueryString["custGuid"];
        }
    }
}