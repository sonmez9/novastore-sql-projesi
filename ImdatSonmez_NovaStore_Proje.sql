/* =====================================================================
   NovaStore E-Ticaret Veri Yönetim Sistemi
   Hazırlayan : İmdat Sönmez
   Platform   : Microsoft SQL Server (T-SQL)
   ===================================================================== */


/* =====================================================================
   BÖLÜM 1: VERİ TABANI TASARIMI (DDL)
   ===================================================================== */

-- Görev 1.1: Veri tabanı oluşturma (NovaStoreDB)
-- Script tekrar çalıştırılabilsin diye varsa önce silinir.
-- Türkçe karakterlerin (ş, ğ, İ...) varchar kolonlarda bozulmaması için
-- Turkish_CI_AS collation kullanılmıştır.
USE master;
GO

IF DB_ID(N'NovaStoreDB') IS NOT NULL
BEGIN
    ALTER DATABASE NovaStoreDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NovaStoreDB;
END
GO

CREATE DATABASE NovaStoreDB COLLATE Turkish_CI_AS;
GO

USE NovaStoreDB;
GO

-- Görev 1.2-A: Categories (Kategoriler)
CREATE TABLE Categories (
    CategoryID   INT IDENTITY(1,1) NOT NULL,
    CategoryName VARCHAR(50)       NOT NULL,
    CONSTRAINT PK_Categories PRIMARY KEY (CategoryID)
);
GO

-- Görev 1.2-B: Products (Ürünler)
CREATE TABLE Products (
    ProductID   INT IDENTITY(1,1) NOT NULL,
    ProductName VARCHAR(100)      NOT NULL,
    Price       DECIMAL(10,2)     NULL,
    Stock       INT               NULL CONSTRAINT DF_Products_Stock DEFAULT 0,
    CategoryID  INT               NULL,
    CONSTRAINT PK_Products PRIMARY KEY (ProductID),
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryID)
        REFERENCES Categories (CategoryID)
);
GO

-- Görev 1.2-C: Customers (Müşteriler)
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) NOT NULL,
    FullName   VARCHAR(50)       NULL,
    City       VARCHAR(20)       NULL,
    Email      VARCHAR(100)      NULL,
    CONSTRAINT PK_Customers PRIMARY KEY (CustomerID),
    CONSTRAINT UQ_Customers_Email UNIQUE (Email)   -- E-posta benzersiz olmalı
);
GO

-- Görev 1.2-D: Orders (Siparişler)
CREATE TABLE Orders (
    OrderID     INT IDENTITY(1,1) NOT NULL,
    CustomerID  INT               NULL,
    OrderDate   DATETIME          NULL CONSTRAINT DF_Orders_OrderDate DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2)     NULL,
    CONSTRAINT PK_Orders PRIMARY KEY (OrderID),
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID)
        REFERENCES Customers (CustomerID)
);
GO

-- Görev 1.2-E: OrderDetails (Sipariş Detayları - Ara Tablo)
CREATE TABLE OrderDetails (
    DetailID  INT IDENTITY(1,1) NOT NULL,
    OrderID   INT               NULL,
    ProductID INT               NULL,
    Quantity  INT               NULL,
    CONSTRAINT PK_OrderDetails PRIMARY KEY (DetailID),
    CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY (OrderID)
        REFERENCES Orders (OrderID),
    CONSTRAINT FK_OrderDetails_Products FOREIGN KEY (ProductID)
        REFERENCES Products (ProductID)
);
GO


/* =====================================================================
   BÖLÜM 2: VERİ GİRİŞİ (DML - INSERT)
   ===================================================================== */

-- Görev 2.1: 5 adet kategori
INSERT INTO Categories (CategoryName) VALUES
(N'Elektronik'),
(N'Giyim'),
(N'Kitap'),
(N'Kozmetik'),
(N'Ev ve Yaşam');
GO

-- Görev 2.2: Her kategoriye ait toplam 12 ürün
-- (CategoryID: 1=Elektronik, 2=Giyim, 3=Kitap, 4=Kozmetik, 5=Ev ve Yaşam)
INSERT INTO Products (ProductName, Price, Stock, CategoryID) VALUES
(N'Kablosuz Kulaklık',       1499.90,  45, 1),
(N'Akıllı Saat',             2899.00,  12, 1),
(N'Powerbank 20000 mAh',      649.50,  80, 1),
(N'Erkek Kot Pantolon',       799.90,  30, 2),
(N'Kadın Mont',              1899.00,   8, 2),
(N'Spor Ayakkabı',           1299.90,  18, 2),
(N'Sefiller',                 189.50, 120, 3),
(N'Suç ve Ceza',              165.00,  15, 3),
(N'Nemlendirici Krem',        249.90,  60, 4),
(N'Parfüm',                   899.00,   5, 4),
(N'Kahve Makinesi',          2199.00,  10, 5),
(N'Nevresim Takımı',          559.90,  25, 5);
GO

-- Görev 2.3: 6 adet müşteri
INSERT INTO Customers (FullName, City, Email) VALUES
(N'Ahmet Yılmaz', N'İstanbul', N'ahmet.yilmaz@mail.com'),
(N'Ayşe Demir',   N'Ankara',   N'ayse.demir@mail.com'),
(N'Mehmet Kaya',  N'İzmir',    N'mehmet.kaya@mail.com'),
(N'Elif Çelik',   N'Bursa',    N'elif.celik@mail.com'),
(N'Can Öztürk',   N'Antalya',  N'can.ozturk@mail.com'),
(N'Zeynep Arslan',N'İstanbul', N'zeynep.arslan@mail.com');   -- henüz siparişi yok
GO

-- Görev 2.4: Farklı tarihlerde 10 sipariş
-- TotalAmount, sipariş detaylarındaki (Adet x Ürün Fiyatı) toplamıdır.
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount) VALUES
(1, '2026-01-15 10:30', 1878.90),   -- 1
(1, '2026-03-02 14:15', 1548.90),   -- 2
(2, '2026-02-10 09:45', 2698.90),   -- 3
(3, '2026-04-21 16:20', 2899.00),   -- 4
(4, '2026-05-05 11:05', 1398.80),   -- 5
(5, '2026-06-18 19:40', 1794.90),   -- 6
(2, '2026-07-09 13:25', 3318.80),   -- 7
(3, '2026-09-14 12:10', 1088.00),   -- 8
(4, '2026-10-03 18:00', 1209.40),   -- 9
(1, '2026-10-27 15:35', 3099.70);   -- 10
GO

-- Sipariş detayları (OrderID, ProductID, Quantity)
INSERT INTO OrderDetails (OrderID, ProductID, Quantity) VALUES
(1, 1, 1), (1, 7, 2),
(2, 3, 2), (2, 9, 1),
(3, 5, 1), (3, 4, 1),
(4, 2, 1),
(5, 10, 1), (5, 9, 2),
(6, 6, 1), (6, 8, 3),
(7, 11, 1), (7, 12, 2),
(8, 7, 4), (8, 8, 2),
(9, 12, 1), (9, 3, 1),
(10, 4, 2), (10, 1, 1);
GO


/* =====================================================================
   BÖLÜM 3: SORGULAMA VE ANALİZ (DQL)
   ===================================================================== */

-- Sorgu 3.1: Temel Listeleme
-- Stok miktarı 20'den az olan ürünler, stok miktarına göre AZALAN sırada
SELECT ProductName AS [Ürün Adı], Stock AS [Stok]
FROM Products
WHERE Stock < 20
ORDER BY Stock DESC;
GO

-- Sorgu 3.2: Veri Birleştirme (INNER JOIN)
-- Hangi müşteri, hangi tarihte sipariş vermiş?
SELECT c.FullName     AS [Müşteri Adı],
       c.City         AS [Şehir],
       o.OrderDate    AS [Sipariş Tarihi],
       o.TotalAmount  AS [Toplam Tutar]
FROM Customers c
INNER JOIN Orders o ON o.CustomerID = c.CustomerID
ORDER BY o.OrderDate;
GO

-- Sorgu 3.3: Çoklu Birleştirme ve Detay Raporu
-- "Ahmet Yılmaz" isimli müşterinin aldığı ürünler, fiyatları ve kategorileri
SELECT c.FullName     AS [Müşteri],
       p.ProductName  AS [Ürün Adı],
       p.Price        AS [Fiyat],
       cat.CategoryName AS [Kategori]
FROM Customers c
INNER JOIN Orders o        ON o.CustomerID = c.CustomerID
INNER JOIN OrderDetails od ON od.OrderID   = o.OrderID
INNER JOIN Products p      ON p.ProductID  = od.ProductID
INNER JOIN Categories cat  ON cat.CategoryID = p.CategoryID
WHERE c.FullName = N'Ahmet Yılmaz';
GO

-- Sorgu 3.4: Gruplama ve Aggregate Fonksiyonlar
-- Hangi kategoride toplam kaç adet ürünümüz var?
-- (LEFT JOIN: ürünü olmayan kategori de 0 ile listelenir)
SELECT cat.CategoryName AS [Kategori],
       COUNT(p.ProductID) AS [Ürün Sayısı]
FROM Categories cat
LEFT JOIN Products p ON p.CategoryID = cat.CategoryID
GROUP BY cat.CategoryName
ORDER BY [Ürün Sayısı] DESC;
GO

-- Sorgu 3.5: Ciro Analizi
-- Her müşterinin toplam cirosu, en çok harcayandan en aza doğru
-- (LEFT JOIN + ISNULL: siparişi olmayan müşteri 0 TL görünür)
SELECT c.FullName AS [Müşteri],
       ISNULL(SUM(o.TotalAmount), 0) AS [Toplam Ciro]
FROM Customers c
LEFT JOIN Orders o ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.FullName
ORDER BY [Toplam Ciro] DESC;
GO

-- Sorgu 3.6: Zaman Analizi
-- Bugünün tarihine göre siparişlerin üzerinden kaç gün geçtiği
SELECT OrderID                                   AS [Sipariş No],
       OrderDate                                 AS [Sipariş Tarihi],
       DATEDIFF(DAY, OrderDate, GETDATE())       AS [Geçen Gün]
FROM Orders
ORDER BY OrderDate;
GO


-- Sorgu 3.7 (BONUS): Alt Sorgu (Subquery)
-- Toplam harcaması, müşterilerin ortalama harcamasının üstünde olanlar
SELECT c.FullName AS [Müşteri],
       SUM(o.TotalAmount) AS [Toplam Harcama]
FROM Customers c
INNER JOIN Orders o ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.FullName
HAVING SUM(o.TotalAmount) > (
    SELECT AVG(t.Toplam)
    FROM (SELECT SUM(TotalAmount) AS Toplam
          FROM Orders
          GROUP BY CustomerID) AS t
)
ORDER BY [Toplam Harcama] DESC;
GO

/* =====================================================================
   BÖLÜM 4: İLERİ SEVİYE VERİ TABANI NESNELERİ
   ===================================================================== */

-- Görev 4.1: View oluşturma
-- Müşteri Adı, Sipariş Tarihi, Ürün Adı ve Adet bilgilerini tek tablo gibi getirir.
-- (CREATE VIEW, bir batch'teki ilk komut olmalıdır; bu yüzden GO ile ayrılmıştır.)
CREATE VIEW vw_SiparisOzet
AS
SELECT c.FullName     AS MusteriAdi,
       o.OrderDate    AS SiparisTarihi,
       p.ProductName  AS UrunAdi,
       od.Quantity    AS Adet
FROM Customers c
INNER JOIN Orders o        ON o.CustomerID = c.CustomerID
INNER JOIN OrderDetails od ON od.OrderID   = o.OrderID
INNER JOIN Products p      ON p.ProductID  = od.ProductID;
GO

-- View kullanım örneği
SELECT * FROM vw_SiparisOzet ORDER BY SiparisTarihi;
GO

-- Görev 4.2: Yedekleme (Backup)
-- NovaStoreDB veri tabanının C:\Yedek\ klasörüne yedeğini alır.
-- (C:\Yedek klasörünün sunucuda önceden oluşturulmuş olması gerekir.)
BACKUP DATABASE NovaStoreDB
TO DISK = N'C:\Yedek\NovaStoreDB.bak'
WITH INIT, NAME = N'NovaStoreDB Tam Yedek';
GO
