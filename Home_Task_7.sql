--1. Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
select u.user_name from users u
where exists 
	(select 1 from orders where user_id = u.user_id)
	
--или

select u.user_name from users u
where u.user_id in 
	(select distinct user_id from orders)
	
--2. Выведите список товаров products и разделов catalogs, который соответствует товару.

select p.product_name, c.catalog_nm
from products p
left join catalogs c
	on c.catalog_id = p.catalog_id

--3.Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). 
--Поля from, to и label содержат английские названия городов, поле name — русское. 
--Выведите список рейсов flights с русскими названиями городов.

select f.id, fc.name as from, tc.name as to
from flights f
left join cities fc
	on fc.label = f.from 
left join cities tc
	on tc.label = f.to 