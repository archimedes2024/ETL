USE TIA
GO

SET DATEFORMAT ymd

IF EXISTS(select * from sys.objects where name = 'sp_ETL_Date' and type = 'P')
DROP PROCEDURE sp_ETL_Date
GO

CREATE PROCEDURE sp_ETL_Date 
(
@StartDate		nvarchar(10),
@EndDate		nvarchar(10)
)

AS

set datefirst 1;
	
WITH MyCTE([CalendarDate]) AS 
(
SELECT CONVERT(datetime, @StartDate) as [CalendarDate]
UNION ALL
SELECT DATEADD(DAY, 1, [CalendarDate]) as [CalendarDate]
FROM MyCTE WHERE [CalendarDate] < CONVERT(datetime,  @EndDate)
)

INSERT INTO dbo.[Date] ([Date], Jour, Mois, Trimestre, Annee, Anneefiscale, Trimestrefiscale)	

SELECT
[CalendarDate],
DAY([CalendarDate]),
MONTH([CalendarDate]),
CASE 
		WHEN MONTH([CalendarDate]) IN (1,2,3)
	    THEN 'Q1'
		WHEN MONTH([CalendarDate]) IN (4,5,6)
	    THEN 'Q2'
		WHEN MONTH([CalendarDate]) IN (7,8,9)
	    THEN 'Q3'
		WHEN MONTH([CalendarDate]) IN (10,11,12)
	    THEN 'Q4'
END,
YEAR([CalendarDate]),
CASE 
		WHEN DATEPART(MONTH, [CalendarDate]) < 6 THEN YEAR([CalendarDate]) - 1
		ELSE YEAR([CalendarDate])
END,
CASE 
		WHEN MONTH([CalendarDate]) IN (6,7,8)
	    THEN 'Q1'
		WHEN MONTH([CalendarDate]) IN (9,10,11)
		THEN 'Q2'
		WHEN MONTH([CalendarDate]) IN (12,1,2)
		THEN 'Q3'
		WHEN MONTH([CalendarDate]) IN (3,4,5)
		THEN 'Q4'
END

FROM MyCTE
WHERE ((NullIf(@StartDate, '') IS NULL) OR CAST([CalendarDate] AS DATE) >= @StartDate)  AND ((NullIf(@EndDate, '') IS NULL) OR CAST([CalendarDate] AS DATE) <= @EndDate)  
ORDER BY [CalendarDate] DESC

OPTION (maxrecursion 10000);

GO



-- On utilise les variables @StartDate = '2011-01-01' et @EndDate= '2014-12-31' pour exécuter la procédure stockée		
--EXEC sp_ETL_Date @StartDate = '2011-01-01', @EndDate = '2014-12-31'

-- Lecture de la table
--SELECT * FROM [Date]