-- Практическое задание по теме “Операторы, фильтрация, сортировка и ограничение”

-- 1. Пусть в таблице users поля created_at и updated_at оказались незаполненными. 
-- Заполните их текущими датой и временем.
drop table if exists example.users;

create table example.users (
  id int not null auto_increment,
  name varchar(100) not null,
  created_at datetime,
  updated_at datetime,
  primary key (id)
);

insert into example.users (name, created_at, updated_at)
values ('А', null,  null),
		('Б', null,  null),
		('В', null,  null),
		('Г', null,  null),
		('Д', null,  null);

update example.users 
set created_at = now()
	,updated_at = now()
where created_at is null;

-- 2. Таблица users была неудачно спроектирована. 
-- Записи created_at и updated_at были заданы типом VARCHAR и в них долгое время помещались значения в формате "20.10.2017 8:10". 
-- Необходимо преобразовать поля к типу DATETIME, сохранив введеные ранее значения.
drop table if exists example.users;

create table example.users (
  id int not null auto_increment,
  name varchar(100) not null,
  created_at varchar(50),
  updated_at varchar(50),
  primary key (id)
);

insert into example.users (name, created_at, updated_at)
values ('А', '2020-04-12 00:00',  '2020-04-12 00:01'),
		('Б', '2020-04-12 00:02',  '2020-04-12 00:03'),
		('В', '2020-04-12 00:04',  '2020-04-12 00:05'),
		('Г', '2020-04-12 00:06',  '2020-04-12 00:07'),
		('Д', '2020-04-12 00:08',  '2020-04-12 00:09');
	
update example.users 
set created_at = cast(created_at as datetime)
	,updated_at = cast(updated_at as datetime);
	
alter table example.users
change created_at created_at datetime;

alter table example.users
change updated_at updated_at datetime;

-- 3. В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 0, если товар закончился и выше нуля, если на складе имеются запасы. 
-- Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value. 
-- Однако, нулевые запасы должны выводиться в конце, после всех записей.
select * from example.storehouses_products t1
inner join 
	(select max(value) max_value from example.storehouses_products) t2
	on 1 = 1
order by case when value = 0 then value + max_value else value end asc;

-- 4. Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. 
-- Месяцы заданы в виде списка английских названий ('may', 'august')
select * from  vk.profiles
where date_format(birthday,'%M') in ('may', 'august');

-- 5. Из таблицы catalogs извлекаются записи при помощи запроса. 
-- SELECT * FROM catalogs WHERE id IN (5, 1, 2); Отсортируйте записи в порядке, заданном в списке IN.
select * from example.catalogs
where id in (5, 1, 2)
order by case when value = 5 then 1 when value = 1 then 2 when value = 2 then 3 end asc;

-- Практическое задание теме “Агрегация данных”

-- 1. Подсчитайте средний возраст пользователей в таблице users
select avg(timestampdiff(year, birthday, now())) as avg_age
from vk.profiles;

-- 2. Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. 
-- Следует учесть, что необходимы дни недели текущего года, а не года рождения.
select case when year(date_add(birthday, interval timestampdiff(year, birthday, now()) year)) = 2019 
				then date_format(date_add(birthday, interval (timestampdiff(year, birthday, now()) + 1) year),'%W')
			else date_format(date_add(birthday, interval timestampdiff(year, birthday, now()) year),'%W')
		end as day_of_week
		,count(*) as birthday_cnt
from vk.profiles
group by day_of_week;

-- 3. Подсчитайте произведение чисел в столбце таблицы
