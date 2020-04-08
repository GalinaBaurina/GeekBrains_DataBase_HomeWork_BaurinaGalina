--1. Пусть задан некоторый пользователь. 
--Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.

select m1.user_id, count(*) as messages_cnt
from 
	(
	select m.id as message_id, m.from_user_id as main_user_id, m.to_user_id as user_id
	from messages m
	where m.from_user_id = 1 
	union
	select m.id as message_id, m.to_user_id as main_user_id, m.from_user_id as user_id
	from messages m
	where m.to_user_id = 1
	) m1
where m1.user_id in
	(
	select initiator_user_id
	from friend_requests
	where status = 'approved'
	and target_user_id = m.main_user_id
	union
	select target_user_id
	from friend_requests
	where status = 'approved'
	and initiator_user_id = m.main_user_id
	)
group by m1.user_id
order by count(*) desc
limit 1


--2. Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.

select count(l.id) as likes_cnt
from likes l
where l.user_id in
	(
	select p.user_id from profiles p
	order by NOW() - p.birthday asc
	limit 10
	)
	
--3. Определить кто больше поставил лайков (всего) - мужчины или женщины?

select case when sum(case when p.gender = 'ж' then 1 else 0 end)/count(*) > 0.5 
			then 'Женщины поставили больше лайков'
			when sum(case when p.gender = 'ж' then 1 else 0 end)/count(*) < 0.5
			then 'Мужчины поставили больше лайков'
			else 'Мужчины и женщины поставили одинаковое количество лайков'
		end
from likes l
left join profiles p
	on p.user_id = l.user_id
	
--4. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.

select user_id from
(
select from_user_id as user_id, created_at as active_dttm
from messages
union
select initiator_user_id as user_id, requested_at as active_dttm
from friend_requests
union
select user_id, updated_at as active_dttm
from media
union
select user_id, created_at as active_dttm
from likes
) a
group by user_id
order by count(*) asc
limit 10
