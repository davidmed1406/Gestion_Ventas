# Creando la base de datos
create database analysis;
use analysis;
create table sales (
    Row_ID int,
    Order_ID varchar(50),
    Order_Date date,
    Ship_Date date,
    Ship_Mode varchar(50),
    Customer_ID varchar(50),
    Customer_Name varchar(100),
    Segment varchar(50),
    Country varchar(50),
    City varchar(50),
    State varchar(50),
    Region varchar(50),
    Product_ID varchar(50),
    Category varchar(50),
    Sub_Category varchar(50),
    Product_Name varchar(255),
    Sales decimal(15,2)
);

LOAD DATA INFILE '\Sales.csv'
INTO TABLE sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    Row_ID,
    Order_ID,
    Order_Date,
    Ship_Date,
    Ship_Mode,
    Customer_ID,
    Customer_Name,
    Segment,
    Country,
    City,
    State,
    Region,
    Product_ID,
    Category,
    Sub_Category,
    Product_Name,
    Sales
);

#Se tuvo inconveniente con la BD original ya que Order Date y Ship Date no tenian el fomato correcto y habia campos que me recorrían la información por lo que se modifico el CSV manual

#Analizamos las ventas totales y el numero de registros para validar con el CSV que todo se haya subido correctamente

select count(sales) as Registros, sum(sales) as Ventas_Totales from sales;

#Analizamos las ventas por mes
select year(Order_date) as Año, month(Order_Date) as mes, sum(sales) as Ventas_Totales from sales 
group by Año, Mes order by Año, Mes;

#Obtengamos los 10 productos que tuvieron mayor venta en dinero y cantidad
select Product_Name, sum(Sales) as Total_Ventas FROM sales group by Product_Name order by Total_Ventas desc limit 10;
select Product_Name, count(Sales) as Cantidad_Ventas FROM sales group by Product_Name order by Cantidad_Ventas desc limit 10;

#Obtengamos el top ten de clientes por Region
with ranked as ( select region, Customer_Name, sum(sales) as Ventas_Totales,
row_number() over(partition by region order by sum(sales) desc) as N
from sales group by Region, Customer_Name)
select region, customer_name, Ventas_Totales from ranked where N <=10
order by region, Ventas_Totales desc;

#Por ultimo, obtengamos un calculo complicado pero valioso, el 8020 de los clientes
with VentasporCliente as (select Customer_Name, sum(sales) as Total_Cliente from sales group by Customer_Name),
TotalAcumulado as (select Customer_Name, Total_Cliente, 
sum(Total_Cliente) over (order by total_Cliente desc) as Acum_Ventas,
sum(Total_Cliente) over () as Total_General from VentasporCliente)
select Customer_Name, Total_Cliente, (Acum_Ventas / Total_General) * 100 as Porcentaje_Acum FROM TotalAcumulado
where (Acum_Ventas - Total_Cliente) < (Total_General * 0.80) ORDER BY Total_Cliente DESC;