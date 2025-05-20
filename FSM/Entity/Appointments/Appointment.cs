using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FSM.Entity.Appoinments
{
    public class Appointment
    {
        public string CompanyID { get; set; }
        public string CustomerID { get; set; }
        public string AppoinmentId { get; set; }
        public string AppoinmentDate { get; set; }
        public string StartDateTime { get; set; }
        public string EndDateTime { get; set; }
        public string RequestDate { get; set; }
        public string ServiceType { get; set; }
        public string ResourceName { get; set; }
        public int ResourceID { get; set; }
        public string TimeSlot { get; set; }

        public string TicketStatus { get; set; }
        public string CustomTags { get; set; }
        public string Status { get; set; }
        public string Note { get; set; }
    }
}
