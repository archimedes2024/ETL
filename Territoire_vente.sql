use TIA
go

SET DATEFORMAT ymd

if exists(select * from sys.objects where type = 'P' and name = 'sp_import_Territoire_Vente_data')
drop procedure sp_import_Territoire_Vente_data
go

create procedure sp_import_Territoire_Vente_data
as
if not exists
(select * from information_schema.tables where table_schema = current_user and table_name  = 'etl_config')
begin
create table etl_config (
Table_name			varchar(50)			not null constraint PK_etl_config primary key,
Last_load_date		datetime			not null);
end

Begin
INSERT INTO dbo.Territoire_vente (NomTerritoire,CodePaysRegion,ZoneGeographique,RangVentesYTD,RangVentesLastYear,AmeliorationNetteVentes, EffectiveDate)
SELECT
ST.Name,
ST.CountryRegionCode,
ST.[Group],
RANK() OVER(ORDER BY (ST.[SalesYTD]) DESC) AS 'RangVentesYTD',
RANK() OVER(ORDER BY (ST.[SalesLastYear]) DESC) AS 'RangVentesLastYear',
(ST.salesYTD)-(ST.SalesLastYear) AS 'AméliorationNetteVentes',
GETDATE()
FROM AdventureWorks2019.Sales.SalesTerritory AS ST

end 

begin
insert into etl_config (Table_name, Last_load_date) values ('Territoire_Vente', GETDATE());
end


-- Exécution de la procédure stockée
--sp_import_Territoire_Vente_data

-- Lecture de la table
--Select * from etl_config
--SELECT * FROM Territoire_vente


/* Commentaire dimension type 2 :
Nous avons implémenté cette table en tant que dimension type 2. En effet, on suppose qu'un territoire peut être divisé en plusieurs territoires. 
Par exemple, le territoire USA pourrait être divisé en plusieurs États comme la Floride, la Californie etc... */
