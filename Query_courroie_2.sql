with c as (
select refurbishment_id,
case when state = 'PERFORMED' then 'changement effectué'::varchar
    when state = 'ORDERED' then 'changement demandé'::varchar
    end as state,
case when service_name = 'V_BELT_CHANGE' then 'courroie accessoire'::varchar
    when service_name = 'CAM_BELT_CHANGE' then 'courroie distribution'::varchar
    end as service_name
from wkda_retail_fr_2.retail_refurbishment_service as rs
where rs.source_type = 'ENTRY_CHECK_SUBMIT'
and rs.service_name LIKE '%BELT%'
and (rs.state = 'ORDERED' or rs.state = 'PERFORMED'))

select 
rr.stock_number as stock_number,
c.service_name as type_courroie,
c.state as statut_courroie
from c
left join wkda_retail_fr_2.retail_refurbishment as rr on rr.id = c.refurbishment_id
left join wkda_retail_fr_2.retail_ad as ra on ra.stock_number = rr.stock_number
order by ra.autohero_purchase_on desc
limit 6000
