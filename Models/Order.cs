using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SalesDataApp.Models
{
    public class Order
    {
        public int OrderID { get; set; }
        public int CustomerID { get; set; }
        public int ProductID { get; set; }
        public int Quantity { get; set; }
        public DateTime OrderDate { get; set; }
        public DateTime RequestedDeliveryDate { get; set; }
        public DateTime ActualDeliveryDate { get; set; }
        public int DaysDifference { get; set; } // Difference in days for early or late deliveries

 
    }
}