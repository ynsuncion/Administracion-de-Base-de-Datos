-- Modificador de Group By (WITH ROLLUP)

-- Podemos combinar "group by" con el operador "rollup" para generar valores de resumen a la salida.
create database agrupaciones
go 
use agrupaciones

create table personas(
  nombre varchar(30),
  edad tinyint,
  sexo char(1),
  domicilio varchar(30),
  ciudad varchar(20),
  telefono varchar(11),
  montocompra decimal(6,2) not null
);

go

insert into personas
  values ('Susana Molina',28,'f',null,'Buenos Aires',null,45.50); 
insert into personas
  values ('Marcela Mercado',36,'f','Avellaneda 345','Tandil','4545454',22.40);
insert into personas
  values ('Alberto Garcia',35,'m','Gral. Paz 123','Mar del Plata','03547123456',25); 
insert into personas
  values ('Teresa Garcia',33,'f',default,'Tandil','03547123456',120);
insert into personas
  values ('Roberto Perez',45,'m','Urquiza 335','Buenos Aires','4123456',33.20);
insert into personas
  values ('Marina Torres',22,'f','Colon 222','Mar del Plata','03544112233',95);
insert into personas
  values ('Julieta Gomez',24,'f','San Martin 333','Tandil',null,53.50);
insert into personas
  values ('Roxana Lopez',20,'f','null','Tandil',null,240);
insert into personas
  values ('Liliana Garcia',50,'f','Paso 999','Buenos Aires','4588778',48);
insert into personas
  values ('Juan Torres',43,'m','Sarmiento 876','Buenos Aires',null,15.30);

  select * from personas

-- Cantidad de personas por ciudad y el total de personas
select ciudad,
  count(*) as cantidad
  from personas
  group by ciudad with rollup;

  -- variante
  select case when ciudad is null then 'Total' else ciudad end as ciudad,
  count(*) as cantidad
  from personas
  group by ciudad with rollup;

-- Filas de resumen cuando agrupamos por 2 campos, "ciudad" y "sexo":
 select ciudad,sexo,
  count(*) as cantidad
  from personas
  group by ciudad,sexo
  with rollup;

-- Para conocer la cantidad de personas y la suma de sus compras agrupados
-- por ciudad y sexo,
 select ciudad,sexo,
  count(*) as cantidad,
  sum(montocompra) as total
  from personas
  group by ciudad,sexo
  with rollup;

-- El operador "rollup" resume valores de grupos. representan los valores de resumen de la precedente.

-- Tenemos la tabla "personas" con los siguientes campos: nombre, edad, sexo, domicilio, ciudad, telefono, montocompra.

-- Si necesitamos la cantidad de personas por ciudad empleamos la siguiente sentencia:

 select ciudad,count(*) as cantidad
  from personas
  group by ciudad;
  
-- Esta consulta muestra el total de personas agrupados por ciudad; pero si queremos además la cantidad total de personas, debemos realizar otra consulta:

  select count(*) as total
   from personas;

-- Para obtener ambos resultados en una sola consulta podemos usar "with rollup" que nos devolverá ambas salidas en una sola consulta:

 select ciudad,count(*) as cantidad
  from personas
  group by ciudad with rollup;
  
-- La consulta anterior retorna los registros agrupados por ciudad y una fila extra en la que la primera columna contiene "null" y la columna con la cantidad muestra la cantidad total.

-- La cláusula "group by" permite agregar el modificador "with rollup", el cual agrega registros extras al resultado de una consulta, que muestran operaciones de resumen.

-- Si agrupamos por 2 campos, "ciudad" y "sexo":

 select ciudad,sexo,count(*) as cantidad
  from personas
  group by ciudad,sexo
  with rollup;
  
-- La salida muestra los totales por ciudad y sexo y produce tantas filas extras como valores existen del primer campo por el que se agrupa ("ciudad" en este caso), mostrando los totales para cada valor, con la columna correspondiente al segundo campo por el que se agrupa ("sexo" en este ejemplo) conteniendo "null", y 1 fila extra mostrando el total de todos los visitantes (con las columnas correspondientes a ambos campos conteniendo "null"). Es decir, por cada agrupación, aparece una fila extra con el/ los campos que no se consideran, seteados a "null".

-- Con "rollup" se puede agrupar hasta por 10 campos.

-- Es posible incluir varias funciones de agrupamiento, por ejemplo, queremos la cantidad de visitantes y la suma de sus compras agrupados por ciudad y sexo:

 select ciudad,sexo,
  count(*) as cantidad,
  sum(montocompra) as total
  from personas
  group by ciudad,sexo
  with rollup;
  
-- Entonces, "rollup" es un modificador para "group by" que agrega filas extras mostrando resultados de resumen de los subgrupos. Si se agrupa por 2 campos SQL Server genera tantas filas extras como valores existen del primer campo (con el segundo campo seteado a "null") y una fila extra con ambos campos conteniendo "null".

-- Con "rollup" se puede emplear "where" y "having", pero no es compatible con "all".