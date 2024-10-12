
$(document).ready(function () {
    $('#btnSearch').click(function () {
        // Clear any previous error message
        $('#errorMessage').text('');

        // Retrieve search criteria
        let dateType = $('#dateType').val();
        let startDate = $('#startDate').val();
        let endDate = $('#endDate').val();


        // Validate search inputs
        let errorMessage = validateSearchInputs(dateType, startDate, endDate);

        if (errorMessage) {
            $('#errorMessage').text(errorMessage);
            console.error(`Validation error: ${errorMessage}`);
            return;
        }
  
        // If all validations pass, log the search criteria to the console
        console.log(`Search criteria - Date Type: ${dateType}, Start Date: ${startDate}, End Date: ${endDate}, Delivery Status: ${deliveryStatus}`);

        // Execute search with valid criteria
        deliveryStatus = $('#deliveryStatus').val();

        loadOrders();

    });


    // Validation function for search inputs
    function validateSearchInputs(dateType, startDate, endDate) {
        if (!dateType) return 'אנא בחר סוג תאריך.';
        if (!startDate || !endDate) return 'אנא בחר תאריכי התחלה וסיום.';
        if (new Date(startDate) > new Date(endDate)) return 'תאריך הסיום אינו יכול להיות מוקדם מתאריך ההתחלה.';
        return '';
    }


    // Toggle Advanced Search Panel
    $('#btnToggleSearch').click(function () {
        const $panel = $('#advancedSearchPanel');
        const $icon = $('#toggleIcon');

        $panel.toggle();
        $icon.text($panel.is(':visible') ? '-' : '+');
    });



});
