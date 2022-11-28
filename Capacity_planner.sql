with c as (
select 
date(dt) as day
,dyw as weekday
from wkda.ref_calendar as cal
where dt >= current_date - interval '120 day'
order by dt asc
limit 250
)

,capa as (
select

b.name as hub_name
,aux.firstname+' '+aux.lastname as driver_name
,sh.day_of_week
,date(sh.start_date) as shift_start_date
,date(sh.end_date) as shift_end_date
,to_char(sh.start_time, 'HH24:MI:SS') as capa_start_time
,to_char(sh.end_time, 'HH24:MI:SS') as capa_end_time
,datediff(m,sh.start_time,sh.end_time) as capa_mn

from wkda_retail_handover_appointment.shift as sh
left join wkda.branches as b on b.id = sh.branch_id
left join wkda_aux_user.aux_user as aux on aux.id = sh.user_id

where 1
and b.country = 'FR'

)

,block as (
select

b.name as hub_name
,aux.firstname+' '+aux.lastname as driver_name
,date(blo.start_date_time) as block_start_date
,sum(datediff(m,blo.start_date_time,blo.end_date_time)) as blocked_mn

from wkda_retail_handover_appointment.shift as sh
left join wkda.branches as b on b.id = sh.branch_id
left join wkda_retail_handover_appointment.blocked_time as blo on blo.shift_id = sh.id
left join wkda_aux_user.aux_user as aux on aux.id = sh.user_id

where 1
and b.country = 'FR'


group by 1,2,3
)

select

to_char(getdate(), 'YYYY-MM-DD HH24:MI:SS') as time_reporting
,case when c.day < capa.shift_start_date or c.day > capa.shift_end_date then 0 else 1 end as to_include
,capa.hub_name
,capa.driver_name
,datediff(day, '1899-12-30', c.day) as day
,to_char(c.day,'IWYYYY') as week
,capa.capa_mn
,block.blocked_mn
,case when (capa.capa_mn - block.blocked_mn) < 0 then 0 when block.blocked_mn is null then capa.capa_mn else (capa.capa_mn - block.blocked_mn) end as availability_mn
,count(distinct capa.driver_name) as nb_drivers_capa

from capa
left join c on capa.day_of_week = c.weekday
left join block on block.block_start_date = c.day and block.driver_name = capa.driver_name and block.hub_name = capa.hub_name


where 1
and to_include = 1
and capa.hub_name in ('Hub Aix-en-Provence 2',
'Hub Bordeaux',
'Hub Longueil',
'Logistikzentrum Rennes',
'Showroom Toulouse-Eurocentre',
'Workshop Vatry',
'Hub Quincieux')
group by 1,2,3,4,5,6,7,8,9

order by 3 asc, 4 asc, 5 asc
