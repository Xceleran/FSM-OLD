using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FSM.Entity.Customer
{
    public class CustomerSite : CustomerBaseEntity
    {
        public int Id { get; set; }
        public string SiteName { get; set; }
        public string Address { get; set; }
        public string Contact { get; set; }
        public string Note { get; set; }
        public bool IsActive { get; set; }
        public DateTime? CreatedDateTime { get; set; }
    }

    public class Equipment : CustomerBaseEntity
    {
        public int Id { get; set; }
        public int SiteId { get; set; }
        public string SpecialInstruction { get; set; }
        public string EquipmentName { get; set; }
        public string EquipmentType { get; set; }
        public int? EquipmentTypeId { get; set; }
        public DateTime? CreatedDateTime { get; set; }
        public string InstallDate { get; set; }
        public string WarrantyExpireDate { get; set; }
    }

    public class EquipmentType
    {
        public int Id { get; set; }
        public string TypeName { get; set; }
        public string CreatedBy { get; set; }
        public string UpdatedBy { get; set; }
        public DateTime? CreatedDateTime { get; set; }
        public DateTime? UpdateDateTime { get; set; }
    }
}
