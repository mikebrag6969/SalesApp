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
    /// Summary description for ProductService
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
     [System.Web.Script.Services.ScriptService]
    public class ProductService : System.Web.Services.WebService
    {


        private readonly ProductServiceHandler _productServiceHandler;

        public ProductService()
        {
            _productServiceHandler = new ProductServiceHandler();
        }

        [WebMethod]
        public List<ProductSales> GetTopSellingProducts()
        {
            try
            {
                return _productServiceHandler.GetTopSellingProducts();
            }
            catch (Exception ex)
            {
                throw new HttpException(500, ex.Message);
            }
        }
    }
}
