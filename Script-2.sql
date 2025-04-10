select * from products;

select * from suppliers;


-- 2.1. Lista de productos 
-- (id, nombre, nombre_proveedor)
select product_id as id, p.name as nombre, s.name as nombre_proveedor
from products p 
join suppliers s on p.supplier_id = s.supplier_id;

-- 2.2. Lista de proveedores con la cantidad de productos 
-- (id proveedor, nombre proveedor, cantidad productos)


INSERT INTO suppliers (name, phone, address, email) values
('Proveedor K', '73333566', 'parqueindustrial', 'proveedorK@correo.com');

select * from suppliers;

select s.supplier_id id_proveedor, s.name nombre_proveedor, 
count(product_id) "cantidad de productos"
from suppliers s
left join products p on s.supplier_id = p.supplier_id 
group by s.supplier_id
order by s.supplier_id;


-- 2.3. los 10 productos mas vendidos en la ultima semana
select p.name, sum(sd.quantity) cantidad
from sales s
join sales_details sd on sd.sale_id = s.sale_id
join products p on p.product_id = sd.product_id
--where s.sale_date >= current_date - interval '30 days'
group by p.name
order by cantidad desc;
--limit 10;


-- vistAAAAAAAAAAAAAAAAAAAAAAAAAAA
create or replace view top_selling_products as 
select p.name, sum(sd.quantity) cantidad, s.sale_date  last_sale_date
from sales s
join sales_details sd on sd.sale_id = s.sale_id
join products p on p.product_id = sd.product_id
--where s.sale_date >= current_date - interval '30 days'
group by p.name, s.sale_date
order by cantidad desc;
--limit 10;


select * from top_selling_products
where sale_date >= current_date - interval '30 days'









/*
select s.sale_id as "id venta", s.sale_date as "fecha", s.nit as "nit cliente",
c.first_name as "nombre", sum(p.price * sd.quantity) as "total venta"
from sales s
join customers c on s.customer_id = c.customer_id
join sales_details sd on sd.sale_id = s.sale_id
join products p on sd.product_id = sd.product_id 
where s.sale_date >= date_trunc('month', CURRENT_DATE) - INTERVAL '1 month
group by 
*/

-- 2.4. Lista de ventas del mes pasado ordenado por fecha 
--(id venta, fecha, nit cliente, nombre cliente, total venta (cantidad*precio))

select s.sale_id, s.sale_date, s.nit, get_full_name(c.first_name, c.last_name),
sum(sd.quantity * sd.selling_price) "total venta"
from sales s
join customers c on c.customer_id = s.customer_id
join sales_details sd on s.sale_id = sd.sale_id
where s.sale_date between '2025-03-01' and '2025-03-31'
group by s.sale_id, s.sale_date, s.nit, c.first_name, c.last_name --?
order by s.sale_date;





-- 2.5. Lista de entregas en curso
select * 
from deliveries
where state = 'enviado';

-- 2.6. Lista de entregas anuladas
select * 
from deliveries
where state = 'cancelado';

-- 2.7. Lista de los 5 productos mas solicitados por delivery

select * from products;

select p.name, sum(sd.quantity) as cantidad
from deliveries d
join sales s on s.sale_id = d.sale_id
join sales_details sd on sd.sale_id = s.sale_id
join products p on p.product_id = sd.product_id
group by p.name
order by cantidad desc
limit 5;

select p.name, count(distinct p.name) as cantidad
from deliveries d
join sales s on s.sale_id = d.sale_id
join sales_details sd on sd.sale_id = s.sale_id
join products p on p.product_id = sd.product_id
group by p.name
order by cantidad desc
limit 5;


select * from customers c

select concat(first_name, ' ', last_name) "full name"
from customers;


create function get_full_name(first_name varchar, last_name varchar)
returns varchar as $$
begin
	return concat(first_name, ' ', last_name);
end;
$$ language plpgsql;

select get_full_name('hola', 'mundo');



-- actualizacion para mover price de products a
-- selling_price de sales_details

-- resultado esperado
select sd.sale_id, sd.product_id, sd.quantity, p.price
from sales_details sd
join products p on p.product_id = sd.product_id;


-- le agrego el precio de venta
alter table sales_details add column selling_price numeric(10,2);

select * from sales_details;

-- muevo los precios de los products a precio venta
update sales_details sd
set selling_price = p.price
from products p
where p.product_id = sd.product_id;

-- borro la columna de precio
alter table products drop column price;


select * from products;

-- agrego el contrant de not null pa la integridad
alter table sales_details alter column selling_price set not null;



/************** NUEVA INFORMACION DE TAREAS ************/

--### Queries 1

-- 1. Obtén todos los productos que tiene un usuario específico en su carrito de compras.
explain (analyze, verbose, costs , summary)
select p.name, p.reference_price, cd.quantity
from products p
join cart_details cd on cd.product_id = p.product_id
join carts c on cd.cart_id = c.cart_id
where c.customer_id = 10; -- se supone que conozco que cliente especifico



-- 2. Calcula el total del carrito de un usuario multiplicando cantidades por precios.
alter table products add column reference_price numeric(10,2);
select * from products;

insert into products (name, brand, description, stock, reference_price, supplier_id) values
('Aceite de Girasol', 'crisol', 'Botella de 1 litro.', 100, 10.50, 1);

alter table products alter column reference_price set not null;

select get_full_name(c.first_name, c.last_name) "Cliente", sum(p.reference_price * cd.quantity)
from customers c
join carts ct on ct.customer_id = c.customer_id
join cart_details cd on cd.cart_id = ct.cart_id
join products p on p.product_id = cd.product_id
where c.customer_id = 10 -- se supone que lo conozco
group by c.first_name, c.last_name;



-- 3. Muestra los 5 productos más agregados a los carritos por todos los usuarios.
select p.name, sum(cd.quantity) cantidad
from products p
join cart_details cd on cd.product_id = p.product_id
group by p.product_id 
order by cantidad desc
limit 5;

-- segun se dice que todo select va en groupby
select p.name, sum(cd.quantity) cantidad
from products p
join cart_details cd on cd.product_id = p.product_id
group by p.product_id, p.name
order by cantidad desc
limit 5;


-- 4. Lista todos los usuarios que actualmente tienen al menos un producto en su carrito.
select get_full_name(c.first_name, c.last_name) nombre
from customers c 
join carts c2 on c2.customer_id = c.customer_id;



-- 5. Consulta el historial de órdenes realizadas por un usuario, incluyendo total y fecha.

select s.sale_date, sum(sd.quantity * sd.selling_price) total
from sales s
join sales_details sd on sd.sale_id = s.sale_id
where customer_id = 33
group by s.sale_id, s.sale_date;



-- ### Views

-- 6. Crea una vista que muestre el contenido detallado de todos los carritos, 
-- incluyendo nombre del usuario, producto, cantidad y precio.


create or replace view carts_contents as
select get_full_name(c.first_name, c.last_name) name, p.name product_name, p.reference_price, cd.quantity, c2.cart_id
from customers c 
join carts c2 on c2.customer_id = c.customer_id
join cart_details cd on cd.cart_id = c2.cart_id
join products p on p.product_id = cd.product_id;


select * from carts_contents;



-- 7. Crea una vista que calcule el total del carrito por cada usuario.
create or replace view cart_totals_by_user as
select get_full_name(c.first_name, c.last_name) name, sum(p.reference_price * cd.quantity) total, c2.cart_id
from customers c 
join carts c2 on c2.customer_id = c.customer_id
join cart_details cd on cd.cart_id = c2.cart_id
join products p on p.product_id = cd.product_id
group by c.customer_id, c2.cart_id;

select * from cart_totals_by_user;


-- 8. Crea una vista para visualizar los productos con bajo stock 
-- (menos de 10 unidades disponibles).

create or replace view products_with_low_stock as
select * from products
where stock <= 10;

insert into products (name, brand, description, reference_price, weight, stock, supplier_id)
values
('Caviar Beluga', 'Gourmet', 'Caviar Beluga de la mejor calidad', 200.00, 0.2, 5, 1),
('Vino Tinto Reserva', 'Reserva del Valle', 'Vino tinto reserva, añada 2015', 45.00, 1.0, 4, 2),
('Aceite de Oliva Extra Virgen', 'Oliva Premium', 'Aceite de oliva extra virgen, prensado en frío', 15.00, 0.75, 8, 3),
('Trufas Negras', 'Gourmet Delights', 'Trufas negras frescas de temporada', 120.00, 0.1, 7, 4),
('Queso Manchego Curado', 'La Manchega', 'Queso manchego curado con denominación de origen', 25.00, 0.5, 6, 5),
('Chocolate Belga Premium', 'Luxe Chocolat', 'Chocolate belga premium con cacao 75%', 10.00, 0.15, 3, 6),
('Salmón Ahumado Premium', 'Sea Delights', 'Salmón ahumado premium de las costas del norte', 35.00, 0.3, 9, 7);

select * from products_with_low_stock;



-- ### Functions

-- 9. Crea una función que reciba un `cart_id` y devuelva el total en dinero del carrito.

select * from carts;
select * from cart_totals_by_user;

select sum(p.reference_price * cd.quantity) 
from cart_details cd 
join products p on p.product_id = cd.product_id
where cart_id = 7;

create or replace function get_cart_total(cart_id integer)
returns numeric(10, 2) as $$ 
begin
	return (
		select sum(p.reference_price * cd.quantity) 
		from cart_details cd 
		join products p on p.product_id = cd.product_id
		where cd.cart_id = $1
	);
end;
$$ language plpgsql;


select get_cart_total(4);



-- 10. Crea una función que reciba un `cart_id`
-- y devuelva la cantidad de productos en ese carrito.

create or replace function get_cart_product_count(cart_id integer)
returns integer as $$ 
begin
    return (
        select sum(cd.quantity) 
        from cart_details cd 
        where cd.cart_id = $1
    );
end;
$$ language plpgsql;

select get_cart_product_count(2);

select * from carts_contents;


-- 11. Crea una función que reciba un `product_id`
-- y una cantidad, y retorne si hay suficiente stock disponible.


select stock > 20 
from products
where product_id = 2;

create or replace function check_enough_stock(product_id integer, quantity integer)
returns boolean as $$
begin
	return (
		select p.stock >= $2 
		from products p
		where p.product_id = $1
	);
end;
$$ language plpgsql;

select * from products;

select check_enough_stock(6, 700);



-- ### Triggers

-- 12. Crea un trigger que actualice el stock de los productos 
-- después de que se inserten ítems en una orden (sales).

create or replace function update_product_stock()
returns trigger as $$
begin
	update products	
	set stock = stock - NEW.quantity
	where product_id = NEW.product_id;

	return NEW;
end;
$$ language plpgsql;


create trigger update_stock_after_sale
after insert on sales_details
for each row
execute function update_product_stock();




-- 13. Crea un trigger que impida agregar productos al carrito 
-- si no hay suficiente stock disponible.




-- 14. Crea un trigger que limpie automáticamente los carritos de un 
-- usuario una vez que se genera una orden.


-- ### Queries 2

-- 15. Consulta el producto más caro del sistema.

-- 16. Muestra los productos que no han sido agregados a ningún carrito.

-- 17. Obtén los 3 usuarios que más dinero han gastado en órdenes.

-- 18. Muestra todas las entregas creadas durante la última semana.

-- 19. Actualiza el precio de todos los productos incrementándolo en un 10%.

-- 20. Elimina todos los carritos que están vacíos (sin ítems).




