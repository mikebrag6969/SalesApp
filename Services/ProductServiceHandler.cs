using SalesDataApp.CustomExceptions;
using SalesDataApp.Data;
using SalesDataApp.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Diagnostics;


namespace SalesDataApp.Services
{
    public class ProductServiceHandler
    {
        private readonly DataAccess _dataAccess;

        public ProductServiceHandler()
        {
            _dataAccess = new DataAccess();
        }

        private void LogError(Exception ex)
        {
            Debug.WriteLine($"Service Layer Error: {ex.Message}\nStack Trace: {ex.StackTrace}");
        }

        public List<ProductSales> GetTopSellingProducts()
        {
            try
            {
                using (var cmd = new SqlCommand("sp_getTopSellingProductsByCity"))
                {
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    return _dataAccess.ExecuteReader<ProductSales>(cmd);
                }
            }
            catch (SalesDataAccessException ex)
            {
                LogError(ex);
                throw new Exception("Database error. Please contact support.");
            }
            catch (SalesOperationFailedException ex)
            {
                LogError(ex);
                throw new Exception("An unexpected error occurred. Please try again later.");
            }
        }
    }
}