﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FSM.Models.Customer
{
    public class CustomerBaseEntity
    {
        public string CompanyID { get; set; }
        public string CustomerID { get; set; }
        public string CustomerGuid { get; set; }

    }
    public class CustomerEntity : CustomerBaseEntity
    {
        public Int32 BusinessID { get; set; } = 0;
        public string Address1 { get; set; }
        public string Address2 { get; set; }
        public string FirstName { get; set; }
        public string FirstName2 { get; set; } = "";
        public string LastName { get; set; } = "";
        public string LastName2 { get; set; } = "";
        public string Title { get; set; }
        public string Title2 { get; set; } = "";
        public string JobTitle { get; set; }
        public string JobTitle2 { get; set; } = "";
        public string City { get; set; }
        public string State { get; set; }
        public string ZipCode { get; set; }
        public string Phone { get; set; }
        public string Mobile { get; set; }
        public string Email { get; set; }
        public string Notes { get; set; }
        public string CompanyName { get; set; }
        public string CompanyName2 { get; set; } = "";
        public string BusinessName { get; set; }
        public bool IsBusinessContact { get; set; } = false;

        public bool IsPrimaryContact { get; set; } = false;
        public bool IsDealer { get; set; } = false;
        public string DealerID { get; set; } = "";

        public DateTime CreatedDateTime { get; set; }
        public string CallPopAppId { get; set; }
        public string QboId { get; set; }
        public string LeadSource { get; set; }
        public string SalesRep { get; set; }
        public string LeadType { get; set; }

        public string SalesStatus { get; set; }
        public string ProjectType { get; set; }
        public string projectStatus { get; set; }
        public string CurrentProjectId { get; set; } = "";
        public string CreatedCompanyID { get; set; } = "";

        public Dictionary<string, string> CustomFields { get; set; }

    }

    public class CustomerSummeryCount : CustomerBaseEntity
    {
        public int PendingAppointments { get; set; }
        public int ScheduledAppointments { get; set; }
        public int CompletedAppointments { get; set; }
        public int Estimates { get; set; }
        public int OpenInvoices { get; set; }
        public int UnpaidInvoices { get; set; }
        public int PaidInvoices { get; set; }
    }

    public class CustomerAppoinment : CustomerBaseEntity
    {
        public string AppoinmentDate { get; set; }
        public string RequestDate { get; set; }
        public string ServiceType { get; set; }
        public string ResourceName { get; set; }
        public string TimeSlot { get; set; }

        public string TicketStatus { get; set; }
        public string CustomTags { get; set; }
        public string AppoinmentStatus { get; set; }
    }

    public class CustomerInvoice : CustomerBaseEntity
    { 
        public string InvoiceDate { get; set; }
        public string InvoiceNumber { get; set; }
        public string InvoiceType { get; set; }

        public string Subtotal { get; set; }
        public string Discount { get; set; }
        public string Tax { get; set; }
        public string Total { get; set; }
        public string Due { get; set; }
        public string DepositAmount { get; set; }

        public string InvoiceStatus { get; set; }

        public string CustomTags { get; set; }

        public string CustomerName { get; set; }
        public string ID { get; set; }
    }
}
