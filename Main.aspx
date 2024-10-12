<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Main.aspx.cs" Inherits="SalesDataApp.Main" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
 
<head runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Top Selling Products</title>

        <link rel="stylesheet" href="css/styles.css" />
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="js/utils.js"></script>
          <script src="js/dashboard.js" defer></script>
     <script src="js/main.js" defer></script>
 
     <script src="js/searchPanel.js" defer></script>
    
 
 
      
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

        <div id="errorMessage" style="color: red; font-weight: bold; margin-top: 10px;"></div>

    </div>
 

    <!-- Dashboard Button and Panel -->
<button id="btnToggleDashboard" >
    <span id="toggleIconDashboard">+</span>
    <span id="toggleTextDashboard">דשבורד</span>
</button>

<div id="dashboardPanel" style="display: none;">

 
    <!-- Include any specific dashboard charts or summary metrics here -->
</div>



    <!-- Orders Table -->
    <h3>רשימת הזמנות</h3>
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
