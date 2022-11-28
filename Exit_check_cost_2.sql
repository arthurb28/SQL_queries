select 
ra.stock_number,
ec.created_on,
ec.completed_on,
ec.order_number,
ecd.state as damage_state,
sum(ecd.service_budget)/100 as service_budget_damage,
ecs.state as service_state,
sum(ecs.service_budget)/100 as service_budget_services
from wkda_retail_refurbishment_exit.exit_checks as ec
left join wkda_retail_ad.retail_ad as ra on ra.stock_number=ec.stock_number 
left join wkda_retail_refurbishment_exit.damages as ecd on ecd.exit_check_id=ec.id
left join wkda_retail_refurbishment_exit.services as ecs on ecs.exit_check_id=ec.id
where ra.retail_country = 'FR'
and ec.created_on > '01-09-2022'
and damage_state = 'CONFIRMED'
group by 1,2,3,4,5,7
order by ec.completed_on DESC
