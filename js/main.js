 
let deliveryStatus = "Late"; // Default value for initial load
let orderIds = [];
let daysDifferences = [];


$(document).ready(function () {
    // Set default date range for startDate and endDate
    setDefaultDateRange()

    $.ajax({
        type: "POST",
        url: "https://localhost:44339/ProductService.asmx/GetTopSellingProducts",
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

});




function loadOrders() {
    let dateType = $('#dateType').val();
    let startDate = $('#startDate').val();
    let endDate = $('#endDate').val();

    $.ajax({
        type: "POST",
        url: "https://localhost:44339/OrderService.asmx/GetOrdersByDeliveryStatus",
        data: JSON.stringify({
            dateType: dateType,
            startDate: startDate,
            endDate: endDate,
            deliveryStatus: deliveryStatus
        }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
          

            displayOrders(response.d);
            populateChartVars(response.d);

            // Render the chart only if the dashboard is open
            if ($('#dashboardPanel').is(':visible') ) {
                renderChart(orderIds, daysDifferences, deliveryStatus);
            }

            else if ($('#dashboardPanel').is(':visible') && orderIds.length > 0 && daysDifferences.length > 0) {
                // Display a message if no data is available
                $('#dashboardPanel').html('<p>אין מידע להצגה בלוח כרגע</p>');
            }

        },
        error: function (xhr, status, error) {
            console.error("Error:", error);
        }
    });
}




function displayOrders(orders) {

    if (orders.length === 0) {
        // Display a message if no orders are found
        $('#ordersSearchDiv').html("<p>לא נמצאו הזמנות</p>");
        $('#dashboardPanel').hide(); // Hide the chart if no data is available

        return;
    }

    let table = '<table border="1"><tr><th>מס. הזמנה</th><th>ת. הזמנה</th><th>ת. אספקה מבוקש</th><th>ת. אספקה בפועל</th><th>הפרש ימים</th><th>סטטוס</th></tr>';

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

}


// Move other reusable functions outside $(document).ready to keep them accessible if needed.
function setDefaultDateRange() {
    let today = new Date();
    let lastMonth = new Date();
    lastMonth.setDate(today.getDate() - 60);

    $('#startDate').val(lastMonth.toISOString().split("T")[0]);
    $('#endDate').val(today.toISOString().split("T")[0]);
}


// Populate order IDs and days differences for the chart
function populateChartVars(orders) {
    //Reset chart global vars
    orderIds = [];
    daysDifferences = [];

    // Populate arrays for order IDs and days differences
    orders.forEach(order => {
        orderIds.push(order.OrderID);
        daysDifferences.push(order.DaysDifference);
    });
 
}









