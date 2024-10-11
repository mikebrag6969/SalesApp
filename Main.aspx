<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Main.aspx.cs" Inherits="SalesDataApp.Main" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
 
<head runat="server">
    <title>Top Selling Products</title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script type="text/javascript">

        function parseAspNetJsonDate(dateString) {
            let timestamp = parseInt(dateString.replace(/\/Date\((\d+)\)\//, "$1"), 10);


            let date = new Date(timestamp);

            // Manually format the date as dd/mm/yyyy
            let day = String(date.getDate()).padStart(2, '0');
            let month = String(date.getMonth() + 1).padStart(2, '0'); // Months are zero-based
            let year = date.getFullYear();

            return `${day}/${month}/${year}`;
        }


        $(document).ready(function () {
            // Set default date range for startDate and endDate
            let today = new Date();
            let lastMonth = new Date();
            lastMonth.setDate(today.getDate() - 30);

            $('#startDate').val(lastMonth.toISOString().split("T")[0]);
            $('#endDate').val(today.toISOString().split("T")[0]);
          
                $.ajax({
                    type: "POST",
                    url: "https://localhost:44339/SalesService.asmx/GetTopSellingProducts",
           /*         data: JSON.stringify({ city: city }),*/
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var products = response.d;
                        var table = '<table border="1"><tr><th>Product Name</th><th>City</th><th>Total Sales</th></tr>';
                        $.each(products, function (index, product) {
                            table += '<tr><td>' + product.ProductName + '</td><td>' + product.City + '</td><td>' + product.TotalSales + '</td></tr>';
                        });
                        table += '</table>';
                        $('#divResults').html(table);
                    },
                    error: function (xhr, status, error) {
                        console.log("Error: " + error);
                    }
                });



            // Set default delivery status to "Late" and perform initial load
            loadOrders("Late");

            // Reload orders when delivery status changes
            $('#deliveryStatus').change(function () {
                let deliveryStatus = $('#deliveryStatus').val();
                loadOrders(deliveryStatus);
            });


            $('#btnToggleSearch').click(function () {
                $('#advancedSearchPanel').toggle();
            });

            function loadOrders(deliveryStatus) {
                let dateType = $('#dateType').val();
                let startDate = $('#startDate').val();
                let endDate = $('#endDate').val();

                $.ajax({
                    type: "POST",
                    url: "https://localhost:44339/SalesService.asmx/GetOrdersByDeliveryStatus",
                    data: JSON.stringify({
                        dateType: dateType,
                        startDate: startDate,
                        endDate: endDate,
                        deliveryStatus: deliveryStatus
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        let orders = response.d;
                        let table = '<table border="1"><tr><th>Order ID</th><th>Order Date</th><th>Requested Delivery Date</th><th>Actual Delivery Date</th><th>Days Difference</th><th>Status</th></tr>';

                        orders.forEach(order => {
                            let rowClass = (deliveryStatus === "Late") ? "late" : "early";
                            let statusText = (deliveryStatus === "Late") ? "איחור" : "הקדמה";


                            let orderDate = parseAspNetJsonDate(order.OrderDate);
                            let requestedDeliveryDate = parseAspNetJsonDate(order.RequestedDeliveryDate);
                            let actualDeliveryDate = parseAspNetJsonDate(order.ActualDeliveryDate);



                            table += `<tr class="${rowClass}">
                          <td>${order.OrderID}</td>
                          <td>${orderDate}</td>
                          <td>${requestedDeliveryDate}</td>
                          <td>${actualDeliveryDate}</td>
                          <td>${order.DaysDifference}</td>
                          <td>${statusText}</td>
                        </tr>`;
                        });

                        table += '</table>';
                        $('#results').html(table);
                    },
                    error: function (xhr, status, error) {
                        console.error("Error:", error);
                    }
                });
            }
 

         
        });

    
    </script>

       <style>
           body {

               direction: rtl;
           }
        /* Style for rows */
        .late { background-color: red; color: white; }
        .early { background-color: green; color: white; }
    </style>
</head>
<body>

     <button id="btnToggleSearch">חיפוש מתקדם</button>
    <div id="advancedSearchPanel" style="display: none;">
        <label for="dateType">סוג תאריך:</label>
        <select id="dateType">
            <option value="OrderDate">תאריך ביצוע הזמנה</option>
            <option value="RequestedDeliveryDate">תאריך אספקה מבוקש</option>
            <option value="ActualDeliveryDate">תאריך בו בוצע המשלוח</option>
        </select><br />

        <label for="startDate">החל מתאריך:</label>
        <input type="date" id="startDate" /><br />

        <label for="endDate">עד לתאריך:</label>
        <input type="date" id="endDate" /><br />

        <label for="deliveryStatus">מצב אספקה:</label>
        <select id="deliveryStatus">
            <option value="Late">איחור</option>
            <option value="Early">הקדמה</option>
        </select><br />

        <button id="btnSearch">חיפוש</button>
    </div>

    <div id="results"></div>



    <div id="divResults"></div>
</body>
</html>
