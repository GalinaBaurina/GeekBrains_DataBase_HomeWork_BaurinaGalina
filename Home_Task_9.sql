-- Практическое задание по теме “Транзакции, переменные, представления”

-- 1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
-- Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.
start transaction;

insert into sample.users from 
	select * from shop.users 
	where id = 1;

delete from shop.users 
	where id = 1;

commit;

-- 2. Создайте представление, которое выводит название name товарной позиции из таблицы products и соответствующее название каталога name из таблицы catalogs.
create or replace view example.product_list as
select p.product_name, c.catalog_name
from example.products p
left join example.catalogs c
	on c.catalog_id = p.catalog_id
	
-- 3. Пусть имеется таблица с календарным полем created_at. 
-- В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. 
-- Составьте запрос, который выводит полный список дат за август, выставляя в соседнем поле значение 1, если дата присутствует в исходном таблице и 0, если она отсутствует.
create table if not exists example.products
	(
	product_id int auto_increment not null primary key,
	product_name VARCHAR(100) not null,
	created_at date not null
	);

insert into example.products values
	(null, 'product_1','2018-08-01'),
	(null, 'product_2','2018-08-04'),
	(null, 'product_2','2018-08-16'),
	(null, 'product_2','2018-08-17');

create table if not exists example.august_days
	(
	august_day date not null
	);

insert into example.august_days values
	('2018-08-01'),
	('2018-08-02'),
	('2018-08-03'),
	('2018-08-04'),
	('2018-08-05'),
	('2018-08-06'),
	('2018-08-07'),
	('2018-08-08'),
	('2018-08-09'),
	('2018-08-10'),
	('2018-08-11'),
	('2018-08-12'),
	('2018-08-13'),
	('2018-08-14'),
	('2018-08-15'),
	('2018-08-16'),
	('2018-08-17'),
	('2018-08-18'),
	('2018-08-19'),
	('2018-08-20'),
	('2018-08-21'),
	('2018-08-22'),
	('2018-08-23'),
	('2018-08-24'),
	('2018-08-25'),
	('2018-08-26'),
	('2018-08-27'),
	('2018-08-28'),
	('2018-08-29'),
	('2018-08-30'),
	('2018-08-31');

select august_day, case when p.created_at is not null then 1 else 0 end as product_flg
from example.august_days d
left join example.products p
	on d.august_day = p.created_at
order by d.august_day;


-- 4. Пусть имеется любая таблица с календарным полем created_at. 
-- Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.
start transaction;

select @users_cnt := count(*) - 5 from example.users;

prepare del from 'delete from example.users order by created_at asc limit ?';

execute del using @users_cnt;

commit;

-- Практическое задание по теме “Хранимые процедуры и функции, триггеры"

-- 1. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
-- С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".
delimiter //
create function example.hello()
returns varchar(100) not deterministic
begin
	declare h int;
	set h = hour(now());
	case 
		when h between 0 and 5 then return "Доброй ночи";
		when h between 6 and 11 then return "Доброе утро";
		when h between 12 and 17 then return "Добрый день";
		when h between 18 and 23 then return "Добрый вечер";
	end case;	
end //
delimiter ;

select example.hello();

-- 2. В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
-- Допустимо присутствие обоих полей или одно из них. 
-- Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. 
-- Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. 
-- При попытке присвоить полям NULL-значение необходимо отменить операцию.
delimiter //
create trigger insert_null_check before insert on example.products
for each row
	begin
		case 
			when new.product_name is null and new.product_desc is null
				then signal sqlstate "45000" set message_text = "Не заполнены обязательные поля!";
		end case;
	end //
	
create trigger update_null_check before update on example.products
for each row
	begin
		case 
			when new.product_name is null and new.product_desc is null
				then signal sqlstate "45000" set message_text = "Не заполнены обязательные поля!";
		end case;
	end //
delimiter ;

-- 3. Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. 
-- Числами Фибоначчи называется последовательность в которой число равно сумме двух предыдущих чисел. 
-- Вызов функции FIBONACCI(10) должен возвращать число 55.
