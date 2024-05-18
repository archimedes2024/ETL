USE TIA
GO

SET DATEFORMAT ymd




/******************************************************************************************************************************************

********	Utilisation des variables @StartDate = '2011-01-01' et @EndDate= '2014-12-31' pour executer la proc�dure stock�e sp_ETL_Date		********

 *****************************************************************************************************************************************/


EXEC sp_ETL_Date @StartDate = '2011-01-01', @EndDate = '2014-12-31'

SELECT *
FROM [Date]


/******************************************************************************************************************************************

********												On ex�cute la proc�dure stock�e	sp_import_product_data											********

 *****************************************************************************************************************************************/


exec sp_import_product_data

-- Lecture des tables
select * from etl_config  

SELECT * FROM dbo.Produit 


/* Commentaire dimension type 2 : 
Nous avons impl�ment� cette table en tant que dimension type 2. En effet, on suppose qu'un produit peut changer de nom */


/******************************************************************************************************************************************

********												On ex�cute la proc�dure stock�e	sp_import_Territoire_Vente_data											********

 *****************************************************************************************************************************************/


exec sp_import_Territoire_Vente_data 

-- Lecture des tables
select * from etl_config  

SELECT * FROM dbo.Territoire_Vente 


/* Commentaire dimension type 2 :
Nous avons impl�ment� cette table en tant que dimension type 2. En effet, on suppose qu'un territoire peut �tre divis� en plusieurs territoires. 
Par exemple, le territoire USA pourrait �tre divis� en plusieurs �tats comme la Floride, la Californie etc... */


/******************************************************************************************************************************************

********												On ex�cute la proc�dure stock�e	sp_ETL_Fait_Vente											********

 *****************************************************************************************************************************************/


EXEC sp_ETL_Fait_Vente

-- Lecture de la table
SELECT * FROM Fait_Vente


