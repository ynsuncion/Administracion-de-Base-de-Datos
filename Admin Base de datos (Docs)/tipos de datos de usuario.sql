CREATE DATABASE PRUEBA

USE PRUEBA

--Tipos de datos definidos por el usuario

CREATE TYPE CUIT
FROM char(11) null

--Este será un nuevo tipo de dato que se usará para definir las columnas CUIT de todas las tablas que tengan un campo CUIT.

CREATE TABLE [dbo].[Empresa]
(
[EmpresaID] int PRIMARY KEY NOT NULL,
[RazonSocial] varchar(40) NOT NULL,
[Contacto] varchar(30) NULL,
[Direccion] varchar(30) NULL,
[Cuit] CUIT NULL,
[Ciudad] varchar(15) NULL,
[Region] int NULL
) ON [PRIMARY]

--El siguiente script SQL puede usarse para crear una tabla desde SSMS llamada "Customers " en el esquema predeterminado (dbo)


CREATE TABLE [dbo].[Customers]
(
[CustomerID] [char](5) NOT NULL,
[CompanyName] [varchar](40) NOT NULL,
[ContactName] [varchar](30) NULL,
[ContactTitle] [varchar](30) NULL,
[Address] [varchar](60) NULL,
[City] [varchar](15) NULL,
[Region] [int] NULL,
[PostalCode] [varchar](10) NULL,
[Country] [varchar](15) NULL,
[Phone] [varchar](24) NULL,
[DateAdded] [datetime] NULL,
CONSTRAINT [PK_Customers] PRIMARY KEY ([CustomerID] ASC)
) ON [PRIMARY]

--Veamos las tablas existentes: 

sp_tables @table_owner='dbo';

--Veamos la estructura de la tabla "Customers ": 

sp_help Customers;