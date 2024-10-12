using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SalesDataApp.CustomExceptions
{
    public class SalesOperationFailedException : Exception
    {
        public SalesOperationFailedException(string message, Exception innerException)
            : base(message, innerException)
        {
        }
    }
}