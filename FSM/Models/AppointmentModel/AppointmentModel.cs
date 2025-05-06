using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FSM.Models.AppoinmentModel
{
    public class AppointmentModel
    {
        public string AppoinmentId { get; set; }
        public string AppoinmentDate { get; set; }
        public string RequestDate { get; set; }
        public string ServiceType { get; set; }
        public string ResourceName { get; set; }
        public string TimeSlot { get; set; }
        public string TicketStatus { get; set; }
        public string CustomTags { get; set; }

        public string Duration { get; set; } = "0";
        public string AppoinmentStatus { get; set; }

        public string CompanyID { get; set; }
        public string CustomerID { get; set; }
        public string CustomerGuid { get; set; }

        public Int32 BusinessID { get; set; } = 0;
        public string Address1 { get; set; }
        public string Address2 { get; set; }
        public string FirstName { get; set; }
        public string FirstName2 { get; set; } = "";
        public string LastName { get; set; } = "";
        public string LastName2 { get; set; } = "";
        public string Title { get; set; }
        public string JobTitle { get; set; }
        public string City { get; set; }
        public string State { get; set; }
        public string ZipCode { get; set; }
        public string Phone { get; set; }
        public string Mobile { get; set; }
        public string Email { get; set; }
        public string Notes { get; set; }
        public string CompanyName { get; set; }
        public string BusinessName { get; set; }
        public string CustomerName { get; set; }
        public bool IsBusinessContact { get; set; } = false;
    }
}
