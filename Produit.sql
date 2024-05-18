use TIA
go

if exists(select * from sys.objects where type = 'P' and name = 'sp_import_product_data')
drop procedure sp_import_product_data
go

create procedure sp_import_product_data
as
if not exists
(select * from information_schema.tables where table_schema = current_user and table_name  = 'etl_config')
begin
create table etl_config (
Table_name			varchar(50)			not null constraint PK_etl_config primary key,
Last_load_date		datetime			not null);
end

---- Zone de préparation

-- On crée la table'ProduitEvaluation' afin de charger les données d'évaluation
if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ProduitEvaluation' AND TABLE_SCHEMA = 'dbo')
drop table dbo.ProduitEvaluation

CREATE TABLE dbo.ProduitEvaluation 
(
ProductID	int		NOT NULL,
Rating		int		NOT NULL
)

-- On insère les données provenant du fichier 'produits_evaluations.csv' dans la table ProduitEvaluation
bulk insert dbo.[ProduitEvaluation]
from 'C:\Users\a\Desktop\MAITRISE HEC\SESSION_2_HIVER_2023\60701 Technologies_Intelligence_Afaiires\TPS\TP4\remise\produits_evaluations.csv'
with
(
firstrow = 2,
fieldterminator = '|',	
rowterminator = '\n',	
tablock	
)

-- On insère les évaluations qui se trouve déjà dans la table ProductReview d'AdventureWorks
INSERT INTO ProduitEvaluation (ProductID, Rating)
SELECT	ProductID,
		Rating
FROM AdventureWorks2019.Production.ProductReview 


begin
INSERT INTO Produit (NomProduit,NumeroProduit,TailleProduitPouces,PoidsProduitLivres,Nombresjoursmarché,Evaluation,EffectiveDate)
SELECT
P.Name,
P.ProductNumber,
CASE
	WHEN P.SizeUnitMeasureCode = 'IN'
	THEN P.Size
	WHEN P.SizeUnitMeasureCode = 'CM'
	THEN ROUND(CAST(P.Size AS float)*0.393701,0)
	WHEN P.SizeUnitMeasureCode = 'DM'
	THEN ROUND(CAST(P.Size AS float)*3.93701,0)
	WHEN P.SizeUnitMeasureCode = 'M'
	THEN ROUND(CAST(P.Size AS float)*39.3701,0)
	WHEN P.SizeUnitMeasureCode = 'MM'
	THEN ROUND(CAST(P.Size AS float)*0.0393701,0)
END,
CASE 
	WHEN P.WeightUnitMeasureCode = 'G'
	THEN P.Weight*0.00220462
	WHEN P.WeightUnitMeasureCode = 'KG'
	THEN P.Weight*2.20462
	WHEN P.WeightUnitMeasureCode = 'LB'
	THEN P.Weight
	WHEN P.WeightUnitMeasureCode = 'MG'
	THEN P.Weight/453592.37
END,
CASE 
WHEN DATEDIFF(DAY, SellStartDate, SellEndDate) IS NOT NULL then DATEDIFF(DAY, SellStartDate, SellEndDate)
ELSE DATEDIFF(DAY, SellStartDate, GETDATE())
END,
PE.MoyenneEvaluation,
GETDATE()
FROM AdventureWorks2019.production.product AS P
LEFT JOIN (SELECT  ProductID,
				   AVG(Rating) as MoyenneEvaluation
		   FROM ProduitEvaluation 
		   GROUP BY ProductID) AS PE ON P.ProductID=PE.ProductID
end

begin
insert into etl_config (Table_name, Last_load_date) values ('Produit', GETDATE());
end

-- On exécute la procédure stockée
--exec sp_import_product_data

-- Lecture des tables
--select * from etl_config
--SELECT * FROM dbo.Produit 


/* Commentaire dimension type 2 : 
Nous avons implémenté cette table en tant que dimension type 2. En effet, on suppose qu'un produit peut changer de nom */



