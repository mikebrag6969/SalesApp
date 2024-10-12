using SalesDataApp.CustomExceptions;
using SalesDataApp.Data;
using SalesDataApp.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;


namespace SalesDataApp.Services
{
    public class OrderServiceHandler
    {
        private readonly DataAccess _dataAccess;

        public OrderServiceHandler()
        {
            _dataAccess = new DataAccess();
        }

        // LogError in the Service Layer (optional if you want to handle logging here)
        private void LogError(Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Service Layer Error: {ex.Message}\nStack Trace: {ex.StackTrace}");
        }

        // Method to get orders by delivery status
        public List<Order> GetOrdersByDeliveryStatus(string dateType, DateTime startDate, DateTime endDate, string deliveryStatus)
        {
            try
            {

                // Validate input parameters
                if (string.IsNullOrEmpty(dateType) || string.IsNullOrEmpty(deliveryStatus))
                {
                    throw new ArgumentException("DateType and DeliveryStatus must be provided.");
                }

                if (startDate == default || endDate == default)
                {
                    throw new ArgumentException("StartDate and EndDate must be valid dates.");
                }




                using (var cmd = new SqlCommand("sp_getOrdersByDeliveryStatus"))
                {
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@DateType", dateType);
                    cmd.Parameters.AddWithValue("@StartDate", startDate);
                    cmd.Parameters.AddWithValue("@EndDate", endDate);
                    cmd.Parameters.AddWithValue("@DeliveryStatus", deliveryStatus);

                    // Call the data access layer to execute the command
                    return _dataAccess.ExecuteReader<Order>(cmd);
                }
            }
            catch (SalesDataAccessException ex)
            {
                // Log the error and throw a user-friendly message for data access issues
                LogError(ex);
                throw new Exception("Database error. Please contact support.");
            }
            catch (SalesOperationFailedException ex)
            {
                // Log the error and throw a user-friendly message for operation failures
                LogError(ex);
                throw new Exception("An unexpected error occurred. Please try again later.");
            }
        }
    }
}