-- VVV ->>>

with tire_details as (SELECT cl.stock_number,
CASE
    WHEN cw.part_id in (30187,30021,153)  THEN 'front_left_wheel'
    WHEN cw.part_id in (30189,30066,159)   THEN 'front_right_wheel'
    WHEN cw.part_id in (30186,30019,155)   THEN 'back_left_wheel'
    WHEN cw.part_id in (30188,30064,157)  THEN 'back_right_wheel'
    END AS tire_part,
case
    when cw.rim_type_id in (2200,2208) THEN 'Aluminium - factory'
    when cw.rim_type_id=2202 THEN 'Steel'
    when cw.rim_type_id=2201 THEN 'Aluminium - supplier'
    when cw.rim_type_id=2203 THEN 'Steel with cover'
    end as rim_type,
cw.profile_depth,
cw.date_of_manufacturing as dot,
cw.condition as tire_condition,
case
    when cw.wheel_type_id= 2207 then 'All season'
    when cw.wheel_type_id= 2205 then 'Summer'
    when cw.wheel_type_id =2204 then 'Winter'
    when cw.wheel_type_id =2206 then 'Emergency' 
    else null end as wheel_type_id
           
   FROM wkda_retail_purchase_fr.car_leads cl
   LEFT JOIN wkda_retail_purchase_fr.car_wheels cw ON cl.id = cw.car_id
   where cw.discriminator = 0
     ),
brake_details as (
select cl.stock_number,
CASE
    WHEN cb.part_id=30182 THEN 'front_left_brake'
    WHEN cb.part_id=30183 THEN 'front_right_brake'
    WHEN cb.part_id=30185 THEN 'back_left_brake'
    WHEN cb.part_id=30184 THEN 'back_right_brake'
    END AS brake_part,

cb.type,
cb.pad_thickness,
cb.disc_condition
FROM wkda_retail_purchase_fr.car_leads cl
left join wkda_retail_purchase_fr.car_brakes cb on cl.id=cb.car_id 

     ) ,


-- AUTOHERO -->>>



-- transition dates
transition_dates as (
    select
        stock_number,
        min(prep_start_date) as prep_start_date

        
    from (
        select
            ra.stock_number,
            case when state_to = 'PREPARATION_STARTED' then datediff(day, '1899-12-30', transition_date) end as prep_start_date

        from wkda_retail_purchase_fr.retail_refurbishment_transition rt
        left join wkda_retail_purchase_fr.retail_refurbishment as r on rt.refurbishment_id = r.id
        left join wkda_retail_purchase_fr.retail_ad as ra on r.retail_ad_id=ra.id
        where r.cancel_reason is null
        order by transition_date
    ) group by stock_number
),


-- dot arrière droit
 dbd_table as (
 select  distinct 
 eci.entry_check_id,
json_extract_path_text(eciv1.proposed_value, 'dot', true)  as dot_arriere_droit
from  wkda_retail_purchase_fr.refurbishment_entry_check_item as eci 
 left join wkda_retail_purchase_fr.refurbishment_entry_check_item_value as eciv1 on eci.id = eciv1.entry_check_item_id and json_extract_path_text(eciv1.proposed_value, 'payloadType', true) = 'WHEEL_DOT' and json_extract_path_text(eciv1.proposed_value, 'position', true) = 'bwr' and json_extract_path_text(eciv1.proposed_value, 'isSecondaryWheel', true) = 'false'
where  eciv1.id is not null
 ),
 
 -- dot arrière gauche
 dbg_table as (select distinct
 eci.entry_check_id,
json_extract_path_text(eciv1.proposed_value, 'dot', true)  as dot_arriere_gauche
from  wkda_retail_purchase_fr.refurbishment_entry_check_item as eci 
 left join wkda_retail_purchase_fr.refurbishment_entry_check_item_value as eciv1 on eci.id = eciv1.entry_check_item_id and json_extract_path_text(eciv1.proposed_value, 'payloadType', true) = 'WHEEL_DOT' and json_extract_path_text(eciv1.proposed_value, 'position', true) = 'bwl' and json_extract_path_text(eciv1.proposed_value, 'isSecondaryWheel', true) = 'false'
where  eciv1.id is not null
 ), 
 
  -- dot avant droit
dfd_table as (
 select  distinct 
 eci.entry_check_id,
json_extract_path_text(eciv1.proposed_value, 'dot', true)  as dot_avant_droit
from  wkda_retail_purchase_fr.refurbishment_entry_check_item as eci 
 left join wkda_retail_purchase_fr.refurbishment_entry_check_item_value as eciv1 on eci.id = eciv1.entry_check_item_id and json_extract_path_text(eciv1.proposed_value, 'payloadType', true) = 'WHEEL_DOT' and json_extract_path_text(eciv1.proposed_value, 'position', true) = 'fwr' and json_extract_path_text(eciv1.proposed_value, 'isSecondaryWheel', true) = 'false'
where  eciv1.id is not null
 ),
 
 -- dot avant gauche
 dfg_table as (select distinct
 eci.entry_check_id,
json_extract_path_text(eciv1.proposed_value, 'dot', true)  as dot_avant_gauche
from  wkda_retail_purchase_fr.refurbishment_entry_check_item as eci 
 left join wkda_retail_purchase_fr.refurbishment_entry_check_item_value as eciv1 on eci.id = eciv1.entry_check_item_id and json_extract_path_text(eciv1.proposed_value, 'payloadType', true) = 'WHEEL_DOT' and json_extract_path_text(eciv1.proposed_value, 'position', true) = 'fwl' and json_extract_path_text(eciv1.proposed_value, 'isSecondaryWheel', true) = 'false'
where  eciv1.id is not null
 ), 
 
 --- condition arrière droite
 card_table as (
 select 
 
 distinct 

 eci.entry_check_id,
json_extract_path_text(eciv1.proposed_value, 'value', true)  as condition_arrière_droite
from  wkda_retail_purchase_fr.refurbishment_entry_check_item as eci 
left join wkda_retail_purchase_fr.refurbishment_entry_check_item_value as eciv1 on eci.id = eciv1.entry_check_item_id and  json_extract_path_text(eciv1.proposed_value, 'payloadType', true) = 'IS_TIRE_IN_GOOD_CONDITION' and json_extract_path_text(eciv1.proposed_value, 'position', true) = 'bwr' and json_extract_path_text(eciv1.proposed_value, 'isSecondaryWheel', true) = 'false'
where  eciv1.id is not null
 ),
 
  --- condition arrière gauche
 carg_table as (
 select 
 
 distinct 

 eci.entry_check_id,
json_extract_path_text(eciv1.proposed_value, 'value', true)  as condition_arrière_gauche
from  wkda_retail_purchase_fr.refurbishment_entry_check_item as eci 
left join wkda_retail_purchase_fr.refurbishment_entry_check_item_value as eciv1 on eci.id = eciv1.entry_check_item_id and  json_extract_path_text(eciv1.proposed_value, 'payloadType', true) = 'IS_TIRE_IN_GOOD_CONDITION' and json_extract_path_text(eciv1.proposed_value, 'position', true) = 'bwl' and json_extract_path_text(eciv1.proposed_value, 'isSecondaryWheel', true) = 'false'
where  eciv1.id is not null
 ),
 
  --- condition avant droite
 cavd_table as (
 select 
 
 distinct 

 eci.entry_check_id,
json_extract_path_text(eciv1.proposed_value, 'value', true)  as condition_avant_droite
from  wkda_retail_purchase_fr.refurbishment_entry_check_item as eci 
left join wkda_retail_purchase_fr.refurbishment_entry_check_item_value as eciv1 on eci.id = eciv1.entry_check_item_id and  json_extract_path_text(eciv1.proposed_value, 'payloadType', true) = 'IS_TIRE_IN_GOOD_CONDITION' and json_extract_path_text(eciv1.proposed_value, 'position', true) = 'fwr' and json_extract_path_text(eciv1.proposed_value, 'isSecondaryWheel', true) = 'false'
where  eciv1.id is not null
 ),
 
  --- condition avant gauche
 cavg_table as (
 select 
 
 distinct 

 eci.entry_check_id,
json_extract_path_text(eciv1.proposed_value, 'value', true)  as condition_avant_gauche
from  wkda_retail_purchase_fr.refurbishment_entry_check_item as eci 
left join wkda_retail_purchase_fr.refurbishment_entry_check_item_value as eciv1 on eci.id = eciv1.entry_check_item_id and  json_extract_path_text(eciv1.proposed_value, 'payloadType', true) = 'IS_TIRE_IN_GOOD_CONDITION' and json_extract_path_text(eciv1.proposed_value, 'position', true) = 'fwl' and json_extract_path_text(eciv1.proposed_value, 'isSecondaryWheel', true) = 'false'
where  eciv1.id is not null
 )
 ,
   --- epaisseur pneus arrière droite
 epard_table as (
 select 
 
 distinct 

 eci.entry_check_id,
json_extract_path_text(eciv1.proposed_value, 'depth', true)  as epaisseur_pneus_arrière_droite
from  wkda_retail_purchase_fr.refurbishment_entry_check_item as eci 
left join wkda_retail_purchase_fr.refurbishment_entry_check_item_value as eciv1 on eci.id = eciv1.entry_check_item_id and json_extract_path_text(eciv1.proposed_value, 'payloadType', true) = 'WHEEL_PROFILE' and json_extract_path_text(eciv1.proposed_value, 'position', true) = 'bwr' and json_extract_path_text(eciv1.proposed_value, 'isSecondaryWheel', true) = 'false'
where  eciv1.id is not null
)
 ,
 
    --- epaisseur pneus arrière gauche
 eparg_table as (
 select 
 
 distinct 

 eci.entry_check_id,
json_extract_path_text(eciv1.proposed_value, 'depth', true)  as epaisseur_pneus_arrière_gauche
from  wkda_retail_purchase_fr.refurbishment_entry_check_item as eci 
left join wkda_retail_purchase_fr.refurbishment_entry_check_item_value as eciv1 on eci.id = eciv1.entry_check_item_id and json_extract_path_text(eciv1.proposed_value, 'payloadType', true) = 'WHEEL_PROFILE' and json_extract_path_text(eciv1.proposed_value, 'position', true) = 'bwl' and json_extract_path_text(eciv1.proposed_value, 'isSecondaryWheel', true) = 'false'
where  eciv1.id is not null
)
 ,
    --- epaisseur pneus avant droite
 epavd_table as (
 select 
 
 distinct 

 eci.entry_check_id,
json_extract_path_text(eciv1.proposed_value, 'depth', true)  as epaisseur_pneus_avant_droite
from  wkda_retail_purchase_fr.refurbishment_entry_check_item as eci 
left join wkda_retail_purchase_fr.refurbishment_entry_check_item_value as eciv1 on eci.id = eciv1.entry_check_item_id and json_extract_path_text(eciv1.proposed_value, 'payloadType', true) = 'WHEEL_PROFILE' and json_extract_path_text(eciv1.proposed_value, 'position', true) = 'fwr' and json_extract_path_text(eciv1.proposed_value, 'isSecondaryWheel', true) = 'false'
where  eciv1.id is not null
 )
 ,
    --- epaisseur pneus avant gauche
 epavg_table as (
 select 
 
 distinct 

 eci.entry_check_id,
json_extract_path_text(eciv1.proposed_value, 'depth', true)  as epaisseur_pneus_avant_gauche
from  wkda_retail_purchase_fr.refurbishment_entry_check_item as eci 
left join wkda_retail_purchase_fr.refurbishment_entry_check_item_value as eciv1 on eci.id = eciv1.entry_check_item_id and json_extract_path_text(eciv1.proposed_value, 'payloadType', true) = 'WHEEL_PROFILE' and json_extract_path_text(eciv1.proposed_value, 'position', true) = 'fwl' and json_extract_path_text(eciv1.proposed_value, 'isSecondaryWheel', true) = 'false'
where  eciv1.id is not null
 ),
 
 -- saison arrière droit
sbd_table as (
 select  distinct 
 eci.entry_check_id,
case 
when json_extract_path_text(eciv1.proposed_value, 'season', true) = 2207 then 'All season'
when json_extract_path_text(eciv1.proposed_value, 'season', true) = 2205 then 'Summer'
when json_extract_path_text(eciv1.proposed_value, 'season', true) = 2204 then 'Winter'
when json_extract_path_text(eciv1.proposed_value, 'season', true) = 2206 then 'Emergency' 
else null end as saison_arriere_droit
from  wkda_retail_purchase_fr.refurbishment_entry_check_item as eci 
 left join wkda_retail_purchase_fr.refurbishment_entry_check_item_value as eciv1 on eci.id = eciv1.entry_check_item_id and json_extract_path_text(eciv1.proposed_value, 'payloadType', true) = 'WHEEL_SEASON' and json_extract_path_text(eciv1.proposed_value, 'position', true) = 'bwr' and json_extract_path_text(eciv1.proposed_value, 'isSecondaryWheel', true) = 'false'
where  eciv1.id is not null
 ),
 
 -- saison arrière gauche
 sbg_table as (select distinct
 eci.entry_check_id,
case 
when json_extract_path_text(eciv1.proposed_value, 'season', true) = 2207 then 'All season'
when json_extract_path_text(eciv1.proposed_value, 'season', true) = 2205 then 'Summer'
when json_extract_path_text(eciv1.proposed_value, 'season', true) = 2204 then 'Winter'
when json_extract_path_text(eciv1.proposed_value, 'season', true) = 2206 then 'Emergency' 
else null end as saison_arriere_gauche
from  wkda_retail_purchase_fr.refurbishment_entry_check_item as eci 
 left join wkda_retail_purchase_fr.refurbishment_entry_check_item_value as eciv1 on eci.id = eciv1.entry_check_item_id and json_extract_path_text(eciv1.proposed_value, 'payloadType', true) = 'WHEEL_SEASON' and json_extract_path_text(eciv1.proposed_value, 'position', true) = 'bwl' and json_extract_path_text(eciv1.proposed_value, 'isSecondaryWheel', true) = 'false'
where  eciv1.id is not null
 ), 
 
  -- saison avant droit
sfd_table as (
 select  distinct 
 eci.entry_check_id,
 case 
when json_extract_path_text(eciv1.proposed_value, 'season', true) = 2207 then 'All season'
when json_extract_path_text(eciv1.proposed_value, 'season', true) = 2205 then 'Summer'
when json_extract_path_text(eciv1.proposed_value, 'season', true) = 2204 then 'Winter'
when json_extract_path_text(eciv1.proposed_value, 'season', true) = 2206 then 'Emergency' 
else null end as saison_avant_droit
from  wkda_retail_purchase_fr.refurbishment_entry_check_item as eci 
 left join wkda_retail_purchase_fr.refurbishment_entry_check_item_value as eciv1 on eci.id = eciv1.entry_check_item_id and json_extract_path_text(eciv1.proposed_value, 'payloadType', true) = 'WHEEL_SEASON' and json_extract_path_text(eciv1.proposed_value, 'position', true) = 'fwr' and json_extract_path_text(eciv1.proposed_value, 'isSecondaryWheel', true) = 'false'
where  eciv1.id is not null
 ),
 
 -- saison avant gauche
 sfg_table as (select distinct
 eci.entry_check_id,
case 
when json_extract_path_text(eciv1.proposed_value, 'season', true) = 2207 then 'All season'
when json_extract_path_text(eciv1.proposed_value, 'season', true) = 2205 then 'Summer'
when json_extract_path_text(eciv1.proposed_value, 'season', true) = 2204 then 'Winter'
when json_extract_path_text(eciv1.proposed_value, 'season', true) = 2206 then 'Emergency' 
else null end as saison_avant_gauche
from  wkda_retail_purchase_fr.refurbishment_entry_check_item as eci 
 left join wkda_retail_purchase_fr.refurbishment_entry_check_item_value as eciv1 on eci.id = eciv1.entry_check_item_id and json_extract_path_text(eciv1.proposed_value, 'payloadType', true) = 'WHEEL_SEASON' and json_extract_path_text(eciv1.proposed_value, 'position', true) = 'fwl' and json_extract_path_text(eciv1.proposed_value, 'isSecondaryWheel', true) = 'false'
where  eciv1.id is not null
 )

 
 select distinct
ra.stock_number,
datediff(day, '1899-12-30', ra.first_purchased_on) as autohero_purchase_on,
td.prep_start_date,
json_extract_path_text(ca.vehicle,'modelApi','make',true)|| ' '||json_extract_path_text(ca.vehicle,'modelApi','model',true) as brand_model,
b2.name as agence,
b.name as last_workshop_name_BO,
td1.profile_depth as ep_avg,
td2.profile_depth as ep_avd,
td3.profile_depth as ep_arg,
td4.profile_depth as ep_ard,
td1.tire_condition as cond_avg,
td2.tire_condition as cond_avd,
td3.tire_condition as cond_arg,
td4.tire_condition as cond_ard,
td1.dot as dot_avg,
td2.dot as dot_avd,
td3.dot as dot_arg,
td4.dot as dot_ard,
td1.wheel_type_id as tire_type_avg,
td2.wheel_type_id as tire_type_avd,
td3.wheel_type_id as tire_type_arg,
td4.wheel_type_id as tire_type_ard,
rpc2.amount/100 as provision_mecanique,
rpc1.amount/100 as provision_revision,
t12.epaisseur_pneus_avant_gauche,
t11.epaisseur_pneus_avant_droite,
t10.epaisseur_pneus_arrière_gauche,
t9.epaisseur_pneus_arrière_droite,
t8.condition_avant_gauche,
t7.condition_avant_droite,
t6.condition_arrière_gauche,
t5.condition_arrière_droite,
t4.dot_avant_gauche,
t3.dot_avant_droit,
t2.dot_arriere_gauche,
t1.dot_arriere_droit,
t16.saison_avant_gauche,
t15.saison_avant_droit,
t14.saison_arriere_gauche,
t13.saison_arriere_droit,
u.firstname || ' ' || u.name AS purchaser_by,
u2.firstname || ' ' || u2.name as priced_by,
u3.first_name || ' ' || u3.last_name as entry_check_by,
'https://admin.wkda.de/car/detail/'||cl.stock_number as admin_link,
'https://www.carol.autohero.com/fr-BE/refurbishment/'||ec.refurbishment_id as carol_link

from wkda_retail_purchase_fr.refurbishment_entry_check as ec 
left join dbd_table as t1 on t1.entry_check_id=ec.id
left join dbg_table as t2 on t2.entry_check_id=ec.id
left join dfd_table as t3 on t3.entry_check_id=ec.id
left join dfg_table as t4 on t4.entry_check_id=ec.id
left join card_table as t5 on t5.entry_check_id=ec.id
left join carg_table as t6 on t6.entry_check_id=ec.id
left join cavd_table as t7 on t7.entry_check_id=ec.id
left join cavg_table as t8 on t8.entry_check_id=ec.id
left join epard_table as t9 on t9.entry_check_id=ec.id
left join eparg_table as t10 on t10.entry_check_id=ec.id
left join epavd_table as t11 on t11.entry_check_id=ec.id
left join epavg_table as t12 on t12.entry_check_id=ec.id
left join sbd_table as t13 on t13.entry_check_id=ec.id
left join sbg_table as t14 on t14.entry_check_id=ec.id
left join sfd_table as t15 on t15.entry_check_id=ec.id
left join sfg_table as t16 on t16.entry_check_id=ec.id

left join wkda_retail_purchase_fr.retail_refurbishment as rr on ec.refurbishment_id = rr.id
left join wkda_retail_purchase_fr.retail_ad as ra on rr.retail_ad_id = ra.id 
left join wkda_retail_purchase_fr.car_leads as cl on ra.stock_number = cl.stock_number
left join wkda_retail_purchase_fr.retail_pricing_costs as rpc1 on cl.id = rpc1.car_id AND rpc1.[type]='maintenance-repair'
left join  wkda_retail_purchase_fr.retail_pricing_costs as rpc2 on cl.id = rpc2.car_id AND rpc2.[type]='mechanical-repair'
left join wkda_retail_purchase_fr.car_evaluations ce ON cl.id = ce.id
left join wkda_retail_purchase_fr.users AS u2 ON u2.id = ce.pricing_platform_priced_by
left join wkda_retail_purchase_fr.users as u ON ce.evaluation_by = u.id
left join wkda_retail_purchase_fr.retail_refurbishment as r on r.id=rr.id
left join transition_dates as td on td.stock_number = ra.stock_number
left join wkda_retail_purchase_fr.branches as b on b.id = r.branch_id 
left join wkda_retail_purchase_fr.classifieds_ad as ca on ca.id=ra.ad_id
left join wkda_retail_purchase_fr.retail_refurbishment_transition as rt on rt.refurbishment_id = r.id and rt.state_to = 'PREPARATION_STARTED'
left join wkda_retail_purchase_fr.refurbishment_user as u3 on u3.id = rt.created_by
   left join wkda_retail_purchase_fr.car_sales cs on cs.id=cl.id
   LEFT JOIN tire_details td1 on td1.stock_number=cl.stock_number and td1.tire_part='front_left_wheel' 
   LEFT JOIN tire_details td2 on td2.stock_number=cl.stock_number and td2.tire_part='front_right_wheel' 
   LEFT JOIN tire_details td3 on td3.stock_number=cl.stock_number and td3.tire_part='back_left_wheel'   
   LEFT JOIN tire_details td4 on td4.stock_number=cl.stock_number and td4.tire_part='back_right_wheel'  
   LEFT JOIN wkda_retail_purchase_fr.branches b2 ON b2.id = cl.branch_id

where ra.autohero_purchase_on is not null
and rr.state not in ('CANCELLED')
and rr.refurbishment_type = 'REFURBISHMENT'
 and td.prep_start_date is not null
 and td.prep_start_date > current_date - interval '4 month' 
 
 order by td.prep_start_date desc 
 
 limit 6000
