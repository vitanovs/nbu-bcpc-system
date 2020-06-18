select o.name as олимпиада, o.year as година, u.name as Домакин,
c.name as Град, o.external_link as Източник
from local.olympiad o inner join local.university u on o.university_id = u.id
inner join local.city c on u.city_id = c.id;