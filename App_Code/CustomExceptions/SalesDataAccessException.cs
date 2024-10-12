using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SalesDataApp.CustomExceptions
{
 
    public class SalesDataAccessException : Exception
    {
        public SalesDataAccessException(string message, Exception innerException)
            : base(message, innerException)
        {
        }
    }


}