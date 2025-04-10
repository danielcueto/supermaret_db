create table customers (
    customer_id serial primary key,
    first_name varchar(100) not null,
    last_name varchar(100) not null,
    phone varchar(20),
    address text,
    email varchar(150) unique not null,
    customer_type varchar(20) check (customer_type in ('casual', 'regular', 'empresa'))
);



create table employees_roles (
    role_id serial primary key,
    name varchar(50) unique not null,
    description text
);

/* on delete restrict, para que, si hay
 * empleados con el rol que quiero eliminar
 * no pueda eliminar el rol
 * 
 * on update cascade, para que, si el rol
 * se actualiza, tambien lo haga en el empleado
 * 
 * 
 */
create table employees (
    employee_id serial primary key,
    first_name varchar(100) not null,
    last_name varchar(100) not null,
    phone varchar(20),
    email varchar(150),
    role_id int references employees_roles(role_id) on delete restrict on update cascade
);

create table suppliers (
    supplier_id serial primary key,
    name varchar(100) unique not null,
    phone varchar(20),
    address text,
    email varchar(150)
);

delete from suppliers;

truncate table products;

truncate table suppliers;

alter table suppliers update name uniq

select * from product_categories;
	
	select * from products;
	select * from suppliers;



/*
 * Si un provedor se elimina, no quiero 
 * eliminar los productos, por eso solo 
 * queda null
 * 
 * si el provedor cambia, tambien al producto
 */

create table products (
    product_id serial primary key,
    name varchar(100) not null,
    brand varchar(100) not null,
    description text,
    weight numeric(10,2),
    stock int default 0,
    supplier_id int references suppliers(supplier_id) on delete set null on update cascade
);

create table categories (
    category_id serial primary key,
    name varchar(100) unique not null,
    description text
);

create table product_categories (
    product_id int references products(product_id) on delete cascade on update cascade,
    category_id int references categories(category_id) on delete cascade on update cascade,
    primary key (product_id, category_id)
);

create table areas (
    area_id serial primary key,
    type varchar(50) unique not null,
    price numeric(10,2)
);

create table product_areas (
    product_id int references products(product_id) on delete cascade on update cascade,
    area_id int references areas(area_id) on delete cascade on update cascade,
    primary key (product_id, area_id)
);

create table warehouses (
    warehouse_id serial primary key,
    name varchar(100) not null,
    description text
);

create table warehouses_products (
    warehouse_id int references warehouses(warehouse_id) on delete cascade on update cascade,
    product_id int references products(product_id) on delete cascade on update cascade,
    quantity int default 0,
    primary key (warehouse_id, product_id)
);

/*
 * Si se borra un cliente, no quiero 
 * eliminar toda la referencia de los
 * carritos porque puede pasar
 * que haya hecho una compra
 * 
 * y seria datos que podria perder
 * 
 * 
 */

create table carts (
    cart_id serial primary key,
    customer_id int unique references customers(customer_id) on delete set null on update cascade,
    created_at timestamp default current_timestamp
);


/*
 * restrict, para que no se borren
 * los productos si forman parte de un detalle
 * 
 */
create table cart_details (
    cart_id int references carts(cart_id) on delete cascade on update cascade,
    product_id int references products(product_id) on delete restrict on update cascade,
    quantity int not null,
    primary key (cart_id, product_id)
);

create table coupons (
    coupon_id serial primary key,
    code varchar(50) unique not null,
    expiration_date date,
    discount numeric(5,2) not null check (discount >= 0 and discount <= 100)
);

/*
 * si se borra el cupon no pasa nada
 * se pone null
 * 
 * si se elimina el cliente se pone null
 * pero no se perde la info de la venta
 * 
 * 
 * 
 * 
 */
create table sales (
    sale_id serial primary key,
    sale_date timestamp default current_timestamp,
    subtotal numeric(10,2),
    state varchar(20) check (state in ('solicitado', 'cancelado', 'enviado', 'cerrado')),
    nit varchar(20),
   	customer_id int references customers(customer_id) on delete restrict on update cascade,      
    employee_id int references employees(employee_id) on delete set null on update cascade,
    coupon_id int references coupons(coupon_id) on delete set null on update cascade
);

create table sales_details (
    sale_id integer references sales(sale_id) on delete cascade on update cascade,
    product_id integer not null references products(product_id) on delete restrict on update cascade,
    quantity integer not null check (quantity > 0),
    selling_price numeric(10,2) not null,
    primary key (sale_id, product_id)
);



create table payments (
    payment_id serial primary key,
    amount numeric(10,2) not null,
    payment_method varchar(20) check (payment_method in ('tarjeta', 'efectivo', 'qr')),
    state varchar(20) check (state in ('finalizado', 'en espera')),
    date timestamp default current_timestamp,
    sale_id int references sales(sale_id) on delete cascade on update cascade
);

create table deliveries (
    delivery_id serial primary key,
    shipment_date timestamp,
    delivery_date timestamp,
    state varchar(20) check (state in ('enviado', 'entregado', 'cancelado', 'completado')),
    address text,
    sale_id int references sales(sale_id) on delete cascade on update cascade
);
