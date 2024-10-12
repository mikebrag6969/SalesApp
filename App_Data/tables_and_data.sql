 
 
 CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(255),
    Price DECIMAL(10, 2),
    Description NVARCHAR(MAX)
);




CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    Email NVARCHAR(255),
    Phone NVARCHAR(50),
    Address NVARCHAR(255),
	City NVARCHAR(100)
);






CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT,
    ProductID INT,
    Quantity INT,
    OrderDate DATETIME,
    DeliveryDate DATETIME,
	RequestedDeliveryDate DATETIME,
		ActualDeliveryDate DATETIME,
	 
    Status NVARCHAR(100),
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_Orders_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);



-- Populate Customers table
INSERT INTO [dbo].[Customers] (FirstName, LastName, Email, Phone, Address, City)
VALUES 
(N'Avi', N'Cohen', 'avi.cohen@example.com', '123-456-7890', N'123 Main St', N'תל אביב'),
(N'Yael', N'Levi', 'yael.levi@example.com', '123-456-7891', N'456 Side St', N'ירושלים'),
(N'David', N'Goldman', 'david.goldman@example.com', '123-456-7892', N'789 Back St', N'טבריה'),
(N'Shira', N'Shalom', 'shira.shalom@example.com', '123-456-7893', N'159 Up St', N'יבנה'),
(N'Maya', N'Reuven', 'maya.reuven@example.com', '123-456-7894', N'951 Down St', N'חיפה');


-- Populate Products table
INSERT INTO [dbo].[Products] (ProductName, Price, Description)
VALUES 
(N'במבה', 10.00, N'חטיף במבה מלוח וטעים'),
(N'ביסלי גריל', 12.00, N'חטיף ביסלי בטעם גריל'),
(N'בייגלה', 8.00, N'בייגלה פריך ומלוח'),
(N'שוקולד קינדר', 5.00, N'שוקולד קינדר מתוק ועדין');

-- Populate Orders table
-- במבה orders (some early, some late)
INSERT INTO [dbo].[Orders] (CustomerID, ProductID, Quantity, OrderDate, RequestedDeliveryDate, Status, ActualDeliveryDate)
VALUES 
(1, 1, 10, '2024-09-01', '2024-09-10', 'Completed', '2024-09-08'), -- במבה, תל אביב (early)
(2, 1, 20, '2024-09-02', '2024-09-11', 'Completed', '2024-09-12'), -- במבה, ירושלים (late)
(3, 1, 70, '2024-09-03', '2024-09-12', 'Completed', '2024-09-12'); -- במבה, טבריה (on time)

-- ביסלי גריל orders (some early, some late)
INSERT INTO [dbo].[Orders] (CustomerID, ProductID, Quantity, OrderDate, RequestedDeliveryDate, Status, ActualDeliveryDate)
VALUES 
(1, 2, 65, '2024-09-04', '2024-09-13', 'Completed', '2024-09-15'), -- ביסלי גריל, תל אביב (late)
(4, 2, 64, '2024-09-05', '2024-09-14', 'Completed', '2024-09-13'), -- ביסלי גריל, יבנה (early)
(2, 2, 6, '2024-09-06', '2024-09-15', 'Completed', '2024-09-15'), -- ביסלי גריל, ירושלים (on time)
(3, 2, 9, '2024-09-07', '2024-09-16', 'Completed', '2024-09-17'); -- ביסלי גריל, טבריה (late)

-- בייגלה orders (some early, some late)
INSERT INTO [dbo].[Orders] (CustomerID, ProductID, Quantity, OrderDate, RequestedDeliveryDate, Status, ActualDeliveryDate)
VALUES 
(1, 3, 11, '2024-09-08', '2024-09-17', 'Completed', '2024-09-16'), -- בייגלה, תל אביב (early)
(2, 3, 49, '2024-09-09', '2024-09-18', 'Completed', '2024-09-20'), -- בייגלה, ירושלים (late)
(5, 3, 50, '2024-09-10', '2024-09-19', 'Completed', '2024-09-19'); -- בייגלה, חיפה (on time)

-- שוקולד קינדר orders (some early, some late)
INSERT INTO [dbo].[Orders] (CustomerID, ProductID, Quantity, OrderDate, RequestedDeliveryDate, Status, ActualDeliveryDate)
VALUES 
(1, 4, 54, '2024-09-11', '2024-09-20', 'Completed', '2024-09-21'), -- שוקולד קינדר, תל אביב (late)
(2, 4, 36, '2024-09-12', '2024-09-21', 'Completed', '2024-09-20'), -- שוקולד קינדר, ירושלים (early)
(3, 4, 9, '2024-09-13', '2024-09-22', 'Completed', '2024-09-22'); -- שוקולד קינדר, טבריה (on time)






