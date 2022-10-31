create database Ejercicio12


CREATE TABLE Proveedor
(
	codProveedor int,
	razonSocial varchar(100),
	fechaInicio date,
	CONSTRAINT PKPROVEEDOR PRIMARY KEY (codProveedor)
)

CREATE TABLE Producto
(
	codProducto int,
	descripcion varchar(100),
	codProveedor int,
	stockActual int,
	CONSTRAINT PKPRODUCTO PRIMARY KEY(codProducto),
	CONSTRAINT FKPRODUCTO FOREIGN KEY (codProveedor) REFERENCES Proveedor(codProveedor)  ON DELETE CASCADE ON UPDATE CASCADE
)

CREATE TABLE Stock
(
	nro int,
	fecha date,
	codProducto int,
	cantidad int,
	
	CONSTRAINT PKSTOCK PRIMARY KEY (nro, fecha, codProducto),
	CONSTRAINT FKSTOCK FOREIGN KEY (codProducto) REFERENCES Producto(codProducto) ON DELETE CASCADE ON UPDATE CASCADE
)


INSERT INTO Proveedor VALUES(1, 'Razon01', '2022-10-17')
INSERT INTO Proveedor VALUES(2, 'Razon02', '2020-10-17')
INSERT INTO Proveedor VALUES(3, 'Razon03', '2021-10-17')
INSERT INTO Proveedor VALUES(4, 'Razon04', '2020-10-17')

select * from Proveedor

INSERT INTO Producto VALUES(1, 'Descripcion01', 1, 0)
INSERT INTO Producto VALUES(2, 'Descripcion02', 2, 10)
INSERT INTO Producto VALUES(3, 'Descripcion03', 3, 5)
INSERT INTO Producto VALUES(4, 'Descripcion04', 4, 10)
INSERT INTO Producto VALUES(5, 'Descripcion05', 1, 2)

select * from Producto

INSERT INTO Stock VALUES(1, '2022-10-10', 1, 10)
INSERT INTO Stock VALUES(2, '2022-10-10', 2, 0)
INSERT INTO Stock VALUES(3, '2022-10-10', 3, 10)
INSERT INTO Stock VALUES(4, '2022-10-10', 4, 50)
INSERT INTO Stock VALUES(5, '2022-10-20', 5, 20)
INSERT INTO Stock VALUES(5, '2022-10-20', 3, 30)

SELECT * FROM STOCK


--1

create or ALTER PROCEDURE p_EliminaSinStock 
AS
BEGIN
	delete from Producto where stockActual = 10;
END

EXEC p_EliminaSinStock
select * from Producto
select* from sys.procedures
sp_helptext p_EliminaSinStock 
--2

create or alter PROCEDURE p_ActualizarStock
AS
begin

	update Producto set stockActual = s.Cantidad 
	from Stock s, Producto p 
    where p.codProducto = s.codProducto and s.fecha = (select MAX(s.fecha)
													   from Stock s
													   where p.codProducto = s.codProducto)

end

exec p_ActualizarStock

	update Stock set cantidad = 350 where codProducto = 3 and nro = 5
	select * from Producto
	select * from Stock
--
/**
    2- p_ActualizaStock(): Para los casos que se presenten inconvenientes en los
    datos, se necesita realizar un procedimiento que permita actualizar todos los
    Stock_Actual de los productos, tomando los datos de la entidad Stock. Para ello,
    se utilizará como stock válido la última fecha en la cual se haya cargado el stock.
**/

/**
    crear vista con fecha maxima
**/
CREATE VIEW stockUltimasFechas(codProd, fecha)
AS
SELECT STO.codProducto, MAX(STO.FECHA)  FROM STOCK STO GROUP BY STO.codProducto
/**
    creo vista con todos los campos
**/
CREATE VIEW stockUlt (nro, fecha, cosProducto, cantidad)
as
SELECT stoc.nro, stoc.fecha, stoc.codProducto, stoc.cantidad   FROM stockUltimasFechas stUlt, Stock stoc 
WHERE stUlt.codProd = stoc.codProducto AND stUlt.fecha = stoc.fecha 

CREATE OR ALTER PROCEDURE p_ActualizaStock
AS
BEGIN 
    BEGIN
        UPDATE Producto SET stockActual = sto.cantidad FROM stockUlt sto
        WHERE Producto.codProducto = sto.cosProducto
    END
END

exec p_ActualizaStock

--3--eliminar proveedores con posean productos con stock de
--de hace menos de un año(2021)
--stock = 0 and fecha hasta 2021


create or alter proc p_DepurarProveedor 
as
begin
	delete Proveedor where codProveedor in (select codProveedor
											from Producto p, Stock s
											where p.codProducto = s.codProducto and 
											s.cantidad = 0 and year(s.fecha) < '2021')
end

select * from Stock
select * from Proveedor
select * from Producto

exec p_DepurarProveedor


--otra forma
/**
    3- p_DepuraProveedor(): Realizar un procedimiento que permita depurar todos los
    proveedores de los cuales no se posea stock de ningún producto provisto desde
    hace más de 1 año.
**/
CREATE OR ALTER PROCEDURE p_DepuraProveedor
as
BEGIN
    DELETE FROM Proveedor WHERE codProveedor IN
    (
        SELECT prod.codProveedor FROM Producto prod WHERE codProducto IN
        (
        SELECT sto.codProducto FROM Stock sto WHERE sto.cantidad = 0 --year(sto.fecha) < '2021' 
        )
    )
END
--mostrar
--print @idNueva

--4
create or alter proc p_InsertStock(@nro int, @fecha date, @prod int, @cant int)
as
begin
	declare @idNueva int
	
	if @prod in (select codProducto from Producto) and @cant > 0
	begin
		set @idNueva = (select max(s.nro)
						from Stock s) + 1
		if @idNueva = @nro
			insert into Stock values(@nro, @fecha, @prod, @cant)
		else
			select 'error de idNueva Stock'
	end
	else
		select 'error 404'
end

select*from Stock
select*from Producto

exec p_InsertStock 6, '2023-07-12', 4, 100

delete Stock where nro = 5 and fecha = '2023-07-12'

--7

	create table listaStock(
	fecha date primary key,
	may1000 int,
	men1000 int,
	igualCero int,
	)
	insert into listaStock values('2030-08-10', 100, 100, 10)
	select * from listaStock


	create proc or alter p_ListaStock
	as
	begin
		declare @fechaa date, @may1000 int,  @meb1000 int;

		create view stockResumen(Fecha, CodProd, Cantidad)
		as
		select s.fecha, s.codProducto, sum(s.Cantidad) 
		from Stock s
		group by s.fecha, s.codProducto
		order by s.fecha asc


		create view resp(Fecha, may1000, men1000, cero)
		as
		select s.fecha, count(select codProducto from Stock where cantidad >1000), 
		count(select codProducto from Stock where cantidad < 1000), 
		count(select codProducto from Stock where cantidad = 0)
		from Stock s
		group by s.fecha

	end

	drop view stockResumen
select * from stockResumen
select*from Stock
select*from Producto
----????????????????????????????????????????