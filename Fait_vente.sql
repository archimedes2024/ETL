use TIA
go

IF EXISTS(select * from sys.objects where type = 'P' and name = 'sp_ETL_Fait_Vente')
drop procedure sp_ETL_Fait_Vente
GO

CREATE PROCEDURE sp_ETL_Fait_Vente
AS
INSERT INTO dbo.Fait_Vente (QuantiteVendue,Benefice,noDate,noProduit,noTerritoire)
SELECT
SUM(SOD.OrderQty),
SUM(SOD.LineTotal-(PP.StandardCost*SOD.OrderQty)),
D.[noDate],
P.noProduit,
TV.noTerritoire
FROM AdventureWorks2019.Sales.SalesOrderDetail AS SOD
INNER JOIN AdventureWorks2019.Production.Product AS PP ON SOD.ProductID=PP.ProductID
INNER JOIN AdventureWorks2019.Sales.SalesOrderHeader AS SOH ON SOH.SalesOrderID=SOD.SalesOrderID
INNER JOIN Date AS D ON SOH.OrderDate=D.Date
INNER JOIN Produit AS P ON PP.ProductNumber=P.NumeroProduit
INNER JOIN AdventureWorks2019.Sales.SalesTerritory AS ST ON SOH.TerritoryID=ST.TerritoryID
INNER JOIN Territoire_vente AS TV ON ST.Name=TV.NomTerritoire
GROUP BY	D.[noDate],P.noProduit,TV.noTerritoire

GO

-- On exécute la procédure stockée
--EXEC sp_ETL_Fait_Vente

-- Lecture de la table
--SELECT * FROM Fait_Vente