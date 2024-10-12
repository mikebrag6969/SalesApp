using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SalesDataApp.Models
{
    public class ProductSales
    {
        public string ProductName { get; set; }
        public string City { get; set; }
        public int TotalSales { get; set; }
    }
}