<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Main.aspx.cs" Inherits="SalesDataApp.Main" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
 
<head runat="server">
    <title>Top Selling Products</title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
                        var table = '<table border="1"><tr><th>שם המוצר</th><th>עיר</th><th>סה"כ מכירות</th></tr>';
                        $.each(products, function (index, product) {
                            table += '<tr><td>' + product.ProductName + '</td><td>' + product.City + '</td><td>' + product.TotalSales + '</td></tr>';
                        });
                        table += '</table>';
                        $('#divTopTenProductsRes').html(table);
                    },
                    error: function (xhr, status, error) {
                        console.log("Error: " + error);
                    }
                });



            // Set default delivery status to "Late" and perform initial load
            loadOrders("Late");

            $('#btnSearch').click(function () {
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

                        if (orders.length === 0) {
                            // Display a message if no orders are found
                            $('#ordersSearchRes').html("<p>לא נמצאו הזמנות לחיפוש</p>");
                            $('#orderChart').hide(); // Hide the chart if no data is available
                            return;
                        }

                        $('#orderChart').show(); // Show the chart if data is available


                        let table = '<table border="1"><tr><th>מס. הזמנה</th><th>ת. הזמנה</th><th>ת. אספקה מבוקש</th><th>ת. אספקה בפועל</th><th>הפרש ימים</th><th>סטטוס</th></tr>';


                    
                        let orderIds = [];
                        let daysDifferences = [];

                        // Populate arrays for order IDs and days differences
                        orders.forEach(order => {
                            orderIds.push(order.OrderID);
                            daysDifferences.push(order.DaysDifference);
                        });

                        // Render the chart
                        renderChart(orderIds, daysDifferences, deliveryStatus);







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
                        $('#ordersSearchRes').html(table);
                    },
                    error: function (xhr, status, error) {
                        console.error("Error:", error);
                    }
                });
            }
 

         
        });




        // Function to render the chart
        function renderChart(orderIds, daysDifferences, deliveryStatus) {
            let ctx = document.getElementById('orderChart').getContext('2d');

            // Destroy existing chart instance if it exists to avoid overlap
            // Check if there's an existing chart instance before attempting to destroy it
            if (window.orderChart instanceof Chart) {
                window.orderChart.destroy();
            }
            // Define color based on delivery status
            let backgroundColor = (deliveryStatus === "Late") ? 'red' : 'green';
            let borderColor = (deliveryStatus === "Late") ? 'darkred' : 'darkgreen';


            // Create new chart instance
            window.orderChart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: orderIds,
                    datasets: [{
                        label: 'הפרש ימים (הקדמה או איחור)',
                        data: daysDifferences,
                        backgroundColor: backgroundColor,
                        borderColor: borderColor,
                        borderWidth: 1
                    }]
                },
                options: {
                    scales: {
                        y: {
                            beginAtZero: true,
                            title: {
                                display: true,
                                text: 'הפרש ימים'
                            }
                        },
                        x: {
                            title: {
                                display: true,
                                text: 'מס. הזמנה'
                            }
                        }
                    }
                }
            });
        }




    </script>

       <style>
      /* Global Styling */
body {
    font-family: Arial, sans-serif;
    background: linear-gradient(135deg, #f0f4f8, #d9e2ec);
    color: #333;
    direction: rtl;
    padding: 20px;
    margin: 0;
}

h3 {
    color: #2f3e46;
    font-weight: 600;
    margin-top: 0;
    text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.1);
}

/* Button Styling */
button {
    background: linear-gradient(135deg, #5da3e9, #417fb8); /* Blue gradient to match Ocean Mist */
    color: white;
    border: none;
    padding: 12px 24px;
    margin-top: 10px;
    cursor: pointer;
    font-size: 15px;
    border-radius: 25px;
    transition: all 0.3s ease;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
}

button:hover {
    background: linear-gradient(135deg, #417fb8, #356a98);
    transform: translateY(-2px);
    box-shadow: 0 6px 12px rgba(0, 0, 0, 0.25);
}

/* Advanced Search Panel Styling */
#advancedSearchPanel {
    background: linear-gradient(135deg, #f0f7fa, #dae8ef);
    padding: 20px;
    border-radius: 10px;
    box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15);
    margin-bottom: 20px;
    transition: all 0.3s ease;
}

#advancedSearchPanel label {
    font-weight: bold;
    margin-top: 10px;
    display: block;
    color: #2f3e46;
}

#advancedSearchPanel input,
#advancedSearchPanel select {
    padding: 8px;
    width: 100%;
    max-width: 300px;
    margin-bottom: 10px;
    border-radius: 8px;
    border: 1px solid #b0c4ce;
    background-color: #fdfdfd;
    transition: border-color 0.3s;
}

#advancedSearchPanel input:focus,
#advancedSearchPanel select:focus {
    border-color: #5da3e9;
    outline: none;
}

/* Table Styling */
table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 20px;
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
    border-radius: 8px;
    overflow: hidden;
}

th,
td {
    padding: 12px;
    text-align: center;
    border-bottom: 1px solid #f1f1f1;
}

/* Header Styling */
th {
    background: linear-gradient(180deg, #cfe3e8, #9fbac6); /* Light misty blue to gray-blue */
    color: #2f3e46; /* Dark slate gray text */
    font-weight: 600;
    border-bottom: 1px solid #8fa5af; /* Soft gray-blue border */
}

/* Row Styling */
tr:nth-child(even) {
    background-color: #f7f9fc;
}

tr:nth-child(odd) {
    background-color: #eef2f7;
}

/* Status Colors */
.late {
    background-color: #fdecea !important; /* Light pastel red */
    color: #b71c1c !important; /* Rich red text */
}

.early {
    background-color: #e8f4f0 !important; /* Light pastel teal */
    color: #00796b !important; /* Dark teal text */
}

/* Chart Container */
#orderChart {
    background-color: white;
    padding: 20px;
    border-radius: 15px;
    box-shadow: 0px 4px 12px rgba(0, 0, 0, 0.15);
    margin-top: 20px;
}
        
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
 



    <div id="divTopTenProductsRes"></div>



    <div id="orderSearchResults">
    <h3>תוצאות חיפוש של הזמנות</h3>
    <div id="ordersSearchRes">
        <!-- Table for order search results -->
    </div>
    <!-- Canvas for the chart -->
    <canvas id="orderChart" width="400" height="200"></canvas>
</div>
</body>
</html>
