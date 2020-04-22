-- ������������ ������� �� ���� ����������, ����������, ���������� � �����������

-- 1. ����� � ������� users ���� created_at � updated_at ��������� ��������������. 
-- ��������� �� �������� ����� � ��������.
drop table if exists example.users;

create table example.users (
  id int not null auto_increment,
  name varchar(100) not null,
  created_at datetime,
  updated_at datetime,
  primary key (id)
);

insert into example.users (name, created_at, updated_at)
values ('�', null,  null),
		('�', null,  null),
		('�', null,  null),
		('�', null,  null),
		('�', null,  null);

update example.users 
set created_at = now()
	,updated_at = now()
where created_at is null;

-- 2. ������� users ���� �������� ��������������. 
-- ������ created_at � updated_at ���� ������ ����� VARCHAR � � ��� ������ ����� ���������� �������� � ������� "20.10.2017 8:10". 
-- ���������� ������������� ���� � ���� DATETIME, �������� �������� ����� ��������.
drop table if exists example.users;

create table example.users (
  id int not null auto_increment,
  name varchar(100) not null,
  created_at varchar(50),
  updated_at varchar(50),
  primary key (id)
);

insert into example.users (name, created_at, updated_at)
values ('�', '2020-04-12 00:00',  '2020-04-12 00:01'),
		('�', '2020-04-12 00:02',  '2020-04-12 00:03'),
		('�', '2020-04-12 00:04',  '2020-04-12 00:05'),
		('�', '2020-04-12 00:06',  '2020-04-12 00:07'),
		('�', '2020-04-12 00:08',  '2020-04-12 00:09');
	
update example.users 
set created_at = cast(created_at as datetime)
	,updated_at = cast(updated_at as datetime);
	
alter table example.users
change created_at created_at datetime;

alter table example.users
change updated_at updated_at datetime;

-- 3. � ������� ��������� ������� storehouses_products � ���� value ����� ����������� ����� ������ �����: 0, ���� ����� ���������� � ���� ����, ���� �� ������ ������� ������. 
-- ���������� ������������� ������ ����� �������, ����� ��� ���������� � ������� ���������� �������� value. 
-- ������, ������� ������ ������ ���������� � �����, ����� ���� �������.
select * from example.storehouses_products t1
inner join 
	(select max(value) max_value from example.storehouses_products) t2
	on 1 = 1
order by case when value = 0 then value + max_value else value end asc;

-- 4. �� ������� users ���������� ������� �������������, ���������� � ������� � ���. 
-- ������ ������ � ���� ������ ���������� �������� ('may', 'august')
select * from  vk.profiles
where date_format(birthday,'%M') in ('may', 'august');

-- 5. �� ������� catalogs ����������� ������ ��� ������ �������. 
-- SELECT * FROM catalogs WHERE id IN (5, 1, 2); ������������ ������ � �������, �������� � ������ IN.
select * from example.catalogs
where id in (5, 1, 2)
order by case when value = 5 then 1 when value = 1 then 2 when value = 2 then 3 end asc;

-- ������������ ������� ���� ���������� �������

-- 1. ����������� ������� ������� ������������� � ������� users
select avg(timestampdiff(year, birthday, now())) as avg_age
from vk.profiles;

-- 2. ����������� ���������� ���� ��������, ������� ���������� �� ������ �� ���� ������. 
-- ������� ������, ��� ���������� ��� ������ �������� ����, � �� ���� ��������.
select case when year(date_add(birthday, interval timestampdiff(year, birthday, now()) year)) = 2019 
				then date_format(date_add(birthday, interval (timestampdiff(year, birthday, now()) + 1) year),'%W')
			else date_format(date_add(birthday, interval timestampdiff(year, birthday, now()) year),'%W')
		end as day_of_week
		,count(*) as birthday_cnt
from vk.profiles
group by day_of_week;

-- 3. ����������� ������������ ����� � ������� �������
