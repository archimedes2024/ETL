if exists(select * from sys.databases where name='TIA')
drop database TIA
go

create database TIA collate SQL_Latin1_General_CP1_CI_AS
go

use TIA
go

-- Si les tables du schéma étoile existent, elles seront supprimées

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'Date' AND TABLE_SCHEMA = 'dbo')
drop table dbo.[Date]

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'Produit' AND TABLE_SCHEMA = 'dbo')
drop table dbo.Produit

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'Territoire_vente' AND TABLE_SCHEMA = 'dbo')
drop table dbo.Territoire_vente

if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'Fait_vente' AND TABLE_SCHEMA = 'dbo')
drop table dbo.Fait_vente

-- Création de la dimension Date

create table dbo.[Date] (
NoDate				int identity(1,1)	primary key,
[Date]				datetime			not null,
Jour				smallint			not null,
Mois				smallint			not null,
Trimestre			varchar(2)			not null,
Annee				smallint			not null,
Anneefiscale		smallint			not null,
Trimestrefiscale	varchar(2)			not null)

-- Création de la dimension Produit

create table dbo.Produit (
noProduit				int IDENTITY(1,1)	PRIMARY KEY,
NomProduit				nvarchar(50)		NOT NULL,
NumeroProduit			nvarchar(25)		NOT NULL,
TailleProduitPouces		decimal(8,2),
PoidsProduitLivres		decimal(8,2),
Nombresjoursmarché		smallint			NOT NULL,
Evaluation				decimal(3,2),
EffectiveDate			datetime			not null,
ExpirationDate			datetime			not null default ('9999-12-31'),
CurrentStatus			varchar(7)			not null default ('Current')
)

-- Création de la dimension Territoire_Vente

create table dbo.Territoire_Vente (
noTerritoire				int IDENTITY(1,1)	PRIMARY KEY,
NomTerritoire				nvarchar(50)		NOT NULL,
CodePaysRegion				nvarchar(3)			NOT NULL,
ZoneGeographique			nvarchar(50)		NOT NULL,
RangVentesYTD				smallint			NOT NULL,
RangVentesLastYear			smallint			NOT NULL,
AmeliorationNetteVentes		money				NOT NULL,
EffectiveDate				datetime			not null,
ExpirationDate				datetime			not null default ('9999-12-31'),
CurrentStatus				varchar(7)			not null default ('Current')
)

-- Création de la table Fait_Vente

create table dbo.Fait_Vente (
noVente			int		IDENTITY(1,1)	PRIMARY KEY,
QuantiteVendue	int		NOT NULL,
Benefice		money	NOT NULL,
noDate			int		NOT NULL		FOREIGN KEY REFERENCES dbo.[date] (noDate),
noProduit		int		NOT NULL		FOREIGN KEY REFERENCES dbo.[Produit] (noProduit),
noTerritoire	int		NOT NULL		FOREIGN KEY REFERENCES dbo.[Territoire_vente] (noTerritoire)
)