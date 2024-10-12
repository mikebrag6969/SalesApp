using SalesDataApp.CustomExceptions;
using SalesDataApp.Models;
using SalesDataApp.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;

namespace SalesDataApp
{
    /// <summary>
    /// Summary description for OrderService
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
   [System.Web.Script.Services.ScriptService]
    public class OrderService : System.Web.Services.WebService
    {

        private readonly OrderServiceHandler _orderServiceHandler;

        public OrderService()
        {
            _orderServiceHandler = new OrderServiceHandler();
        }

        [WebMethod]
        public List<Order> GetOrdersByDeliveryStatus(string dateType, DateTime startDate, DateTime endDate, string deliveryStatus)
        {
            try
            {
                // Call the service handler to get orders based on the parameters
                return _orderServiceHandler.GetOrdersByDeliveryStatus(dateType, startDate, endDate, deliveryStatus);
            }
        
 catch (Exception ex)
            {
                throw new HttpException(500, ex.Message);
            }







        }
    }
}
