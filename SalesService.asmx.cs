using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;
using SalesDataApp.Data;
using System.Web.Services;
using SalesDataApp.Models;

namespace SalesDataApp
{
    /// <summary>
    /// Summary description for SalesService
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
   [System.Web.Script.Services.ScriptService]
    public class SalesService : System.Web.Services.WebService
    {
        private readonly DataAccess _dataAccess = new DataAccess();


        [WebMethod]
        public List<ProductSales> GetTopSellingProducts()
        {
 
            using (var cmd = new SqlCommand("sp_getTopSellingProductsByCity"))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                return _dataAccess.ExecuteReader<ProductSales>(cmd);
            }


        }




        [WebMethod]
        public List<Order> GetOrdersByDeliveryStatus(string dateType, DateTime startDate, DateTime endDate, string deliveryStatus)
        {
            using (var cmd = new SqlCommand("sp_getOrdersByDeliveryStatus"))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@DateType", dateType);
                cmd.Parameters.AddWithValue("@StartDate", startDate);
                cmd.Parameters.AddWithValue("@EndDate", endDate);
                cmd.Parameters.AddWithValue("@DeliveryStatus", deliveryStatus);

                return _dataAccess.ExecuteReader<Order>(cmd);
            }

        }






  


    }
}
