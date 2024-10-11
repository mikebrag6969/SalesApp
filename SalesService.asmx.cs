using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;
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

        [WebMethod]
        public List<ProductSales> GetTopSellingProducts()
        {
            List<ProductSales> products = new List<ProductSales>();
            string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                SqlCommand cmd = new SqlCommand("sp_getTopSellingProductsByCity", conn);
                cmd.CommandType = CommandType.StoredProcedure;
 

                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    products.Add(new ProductSales
                    {
                        ProductName = reader["ProductName"].ToString(),
                        City = reader["City"].ToString(),
                        TotalSales = Convert.ToInt32(reader["TotalSales"])
                    });
                }
            }
            return products;
        }




        [WebMethod]
        public List<Order> GetOrdersByDeliveryStatus(string dateType, DateTime startDate, DateTime endDate, string deliveryStatus)
        {
            var orders = new List<Order>();

            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString))
            {
                SqlCommand cmd = new SqlCommand("GetOrdersByDeliveryStatus", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@DateType", dateType);
                cmd.Parameters.AddWithValue("@StartDate", startDate);
                cmd.Parameters.AddWithValue("@EndDate", endDate);
                cmd.Parameters.AddWithValue("@DeliveryStatus", deliveryStatus);

                conn.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        orders.Add(new Order
                        {
                            OrderID = reader.GetInt32(0),
                            CustomerID = reader.GetInt32(1),
                            ProductID = reader.GetInt32(2),
                            Quantity = reader.GetInt32(3),
                            OrderDate = reader.GetDateTime(4),
                            RequestedDeliveryDate = reader.GetDateTime(5),
                            ActualDeliveryDate = reader.GetDateTime(6),
                            DaysDifference = reader.GetInt32(7)
                        });
                    }
                }
            }

            return orders;
        }






  


    }
}
