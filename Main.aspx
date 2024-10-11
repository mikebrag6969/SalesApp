<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Main.aspx.cs" Inherits="SalesDataApp.Main" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
 
<head runat="server">
    <title>Top Selling Products</title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script type="text/javascript">

        let deliveryStatus = "Late"; // Default value for initial load
        let orderIds = [];
        let daysDifferences = [];

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
                        $('#topProductsDiv').html(table);
                    },
                    error: function (xhr, status, error) {
                        console.log("Error: " + error);
                    }
                });



            // default delivery status to "Late" and perform initial load
            loadOrders();

            $('#btnSearch').click(function () {
                deliveryStatus = $('#deliveryStatus').val();
                alert("deliveryStatus", deliveryStatus)
                loadOrders();

            });

          


            //$('#btnToggleSearch').click(function () {
            //    $('#advancedSearchPanel').toggle();
            //});









            function loadOrders() {
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
                            $('#ordersSearchDiv').html("<p>לא נמצאו הזמנות לחיפוש</p>");
                            $('#dashboardPanel').hide(); // Hide the chart if no data is available

                   
                     


                            return;
                        }

           


                        let table = '<table border="1"><tr><th>מס. הזמנה</th><th>ת. הזמנה</th><th>ת. אספקה מבוקש</th><th>ת. אספקה בפועל</th><th>הפרש ימים</th><th>סטטוס</th></tr>';


                    
                       orderIds = [];
                   daysDifferences = [];

                        // Populate arrays for order IDs and days differences
                        orders.forEach(order => {
                            orderIds.push(order.OrderID);
                            daysDifferences.push(order.DaysDifference);
                        });
 

 
                        // Render the chart only if the dashboard is open
                        if ($('#dashboardPanel').is(':visible')) {
                            renderChart(orderIds, daysDifferences, deliveryStatus);
                        }




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
                        $('#ordersSearchDiv').html(table);
                    },
                    error: function (xhr, status, error) {
                        console.error("Error:", error);
                    }
                });
            }
 






            // Toggle Advanced Search Panel
            $('#btnToggleSearch').click(function () {
                const $panel = $('#advancedSearchPanel');
                const $icon = $('#toggleIcon');

                $panel.toggle();
                $icon.text($panel.is(':visible') ? '-' : '+');
            });

            // Toggle Dashboard Panel
            $('#btnToggleDashboard').click(function () {
                const $panel = $('#dashboardPanel');
                const $icon = $('#toggleIconDashboard');

                $panel.toggle();
                $icon.text($panel.is(':visible') ? '-' : '+');


                // Render the chart if data is already loaded and dashboard is now visible
                if ($panel.is(':visible') && orderIds.length > 0 && daysDifferences.length > 0) {
                    renderChart(orderIds, daysDifferences, deliveryStatus);
                }

            });






         
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
            let backgroundColor = (deliveryStatus === "Late") ? '#b71c1c' : '#00796b';
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
            $('#dashboardPanel').show(); // Show the chart if data is available

            $('#orderChart').show()
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
     background-color: #f8d7da !important; /* Stronger pastel red */

    color: #b71c1c !important; /* Rich red text */
}

.early {
    background-color: #cce4e0 !important; /* Stronger pastel teal */
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
        

/* Header Styling */
#siteHeader {
    background: linear-gradient(90deg, #cfe3e8, #9fbac6); /* Light misty blue gradient */
    padding: 20px;
    text-align: center;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); /* Soft shadow for depth */
    border-bottom: 1px solid #8fa5af;
}

#siteHeader h1 {
    color: #2f3e46; /* Dark slate gray */
    font-size: 32px;
    font-weight: 700;
    margin: 0;
    font-family: 'Arial', sans-serif;
    letter-spacing: 1px; /* Slight letter spacing for elegance */
    text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.1); /* Soft shadow for text depth */
}




 

 /* Toggle Button Styling */
#btnToggleSearch, #btnToggleDashboard {
    background-color: #5da3e9;
    color: white;
    border: none;
    padding: 12px;
    cursor: pointer;
    font-size: 16px;
    border-radius: 8px;
    width: 100%; /* Full-width button for a long, rectangular look */
    position: relative;
    text-align: center;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
    display: inline-flex;
    justify-content: center;
    align-items: center;
}

#btnToggleSearch:hover {
    background-color: #417fb8;
}

/* Icon Styling */
#toggleIcon,#toggleIconDashboard {
    position: absolute;
    left: 15px; /* Keeps the icon consistently on the left */
    font-size: 20px;
    font-weight: bold;
}

/* Text Styling */
#toggleText, #toggleTextDashboard {
    font-size: 16px;
    font-weight: 600;
}


/* Flexbox for responsive input layout */
#advancedSearchPanel {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 15px; /* Space between items */
    padding: 20px;
    background: linear-gradient(135deg, #f0f7fa, #dae8ef);
    border-radius: 10px;
    box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15);
    margin-bottom: 20px;
}

#advancedSearchPanel label {
    font-weight: bold;
 
    color: #2f3e46;
}

#advancedSearchPanel input,
#advancedSearchPanel select {
    padding: 8px;
    border-radius: 8px;
    border: 1px solid #b0c4ce;
    background-color: #fdfdfd;
    transition: border-color 0.3s;
    min-width: 150px; /* Ensures each element has enough space */
}

#advancedSearchPanel input:focus,
#advancedSearchPanel select:focus {
    border-color: #5da3e9;
    outline: none;
}

/* Button styling */
#advancedSearchPanel button {
    background: linear-gradient(135deg, #5da3e9, #417fb8);
    color: white;
    border: none;
    padding: 10px 20px;
    cursor: pointer;
    font-size: 15px;
    border-radius: 25px;
    transition: all 0.3s ease;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
    margin: 0px;
}
}

#advancedSearchPanel button:hover {
    background: linear-gradient(135deg, #417fb8, #356a98);
}

/* Responsive adjustments */
@media (max-width: 768px) {
    #advancedSearchPanel {
        flex-direction: column;
        align-items: flex-start;
    }
}






    </style>
</head>
<body>
    <header id="siteHeader">
    <h1>SalesApp</h1>
</header>
<!-- Toggle Button for Advanced Search with icon and text alignment -->
<button id="btnToggleSearch">
    <span id="toggleIcon">+</span>
    <span id="toggleText">חיפוש מתקדם</span>
</button>
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
 

    <!-- Dashboard Button and Panel -->
<button id="btnToggleDashboard" >
    <span id="toggleIconDashboard">+</span>
    <span id="toggleTextDashboard">דשבורד</span>
</button>

<div id="dashboardPanel" style="display: none;">

        <canvas id="orderChart"  style="display: none;"></canvas>
    <!-- Include any specific dashboard charts or summary metrics here -->
</div>



    <!-- Orders Table -->
    <h3>תוצאות חיפוש של הזמנות</h3>
<div id="ordersSearchDiv">
    <!-- Orders data will populate here based on search -->
</div>

<!-- Top 10 Products Section -->
<h3>עשרת המוצרים המובילים לפי עיר</h3>
<div id="topProductsDiv">
    <!-- Top 10 Products data will populate here -->
</div>



 


</div>
</body>
</html>
