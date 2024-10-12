using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Reflection;
using System.Diagnostics;

namespace SalesDataApp.Data
{
    public class DataAccess
    {
        private readonly string _connectionString;

        public DataAccess()
        {
            _connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
        }

        public List<T> ExecuteReader<T>(SqlCommand command) where T : new()
        {
            var results = new List<T>();

            try
            {
                using (var conn = new SqlConnection(_connectionString))
                {
                    command.Connection = conn;
                    conn.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var instance = new T();

                            for (int i = 0; i < reader.FieldCount; i++)
                            {
                                var property = typeof(T).GetProperty(reader.GetName(i), BindingFlags.Public | BindingFlags.Instance);
                                if (property != null && !reader.IsDBNull(i))
                                {
                                    property.SetValue(instance, reader.GetValue(i));
                                }
                            }

                            results.Add(instance);
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                LogError(sqlEx); // Log SQL-related issues
                throw new Exception("Database operation failed. Please contact support."); // Re-throw a user-friendly message
            }
            catch (Exception ex)
            {
                LogError(ex); // Log any other generic issues
                throw new Exception("An error occurred. Please try again later.");
            }

            return results;
        }

        private void LogError(Exception ex)
        {
            // You could log this to a database, file, or event log
            Debug.WriteLine($"Error: {ex.Message}\nStack Trace: {ex.StackTrace}");
        }
    }
}