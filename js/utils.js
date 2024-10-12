function parseAspNetJsonDate(dateString) {
    let timestamp = parseInt(dateString.replace(/\/Date\((\d+)\)\//, "$1"), 10);


    let date = new Date(timestamp);

    // Manually format the date as dd/mm/yyyy
    let day = String(date.getDate()).padStart(2, '0');
    let month = String(date.getMonth() + 1).padStart(2, '0'); // Months are zero-based
    let year = date.getFullYear();

    return `${day}/${month}/${year}`;
}