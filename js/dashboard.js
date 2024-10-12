
$(document).ready(function () {
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

        else if ($panel.is(':visible')) {
            // Display a message if no data is available
            $('#dashboardPanel').html('<p>אין מידע להצגה בלוח כרגע</p>');
        }

    });

});




// Function to render the chart
function renderChart(orderIds, daysDifferences, deliveryStatus) {
    //remove error messages if append before.
    $('#dashboardPanel').html('');


    // Check if the chart canvas exists; if not, create it
    if (!document.getElementById('orderChart')) {
        $('#dashboardPanel').append('<canvas id="orderChart" ></canvas>');
    }

 




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

