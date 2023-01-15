--https://dash.prod.bi.auto1.team/queries/59054

select 
rpc.[type],
rpc.amount/100,
cdi.stock_number,
ra.first_purchased_on
from wkda_retail_purchase_fr.retail_pricing_costs as rpc
left join wkda_retail_purchase_fr.car_document_items as cdi on cdi.car_id = rpc.car_id
left join wkda_retail_purchase_fr.retail_ad as ra on ra.stock_number = cdi.stock_number
where ra.first_purchased_on is not null
and rpc.[type] = 'maintenance-repair' or rpc.[type] = 'mechanical-repair' or rpc.[type] = 'estimated-repair-maintenance' 
and rpc.amount>0
and ra.first_purchased_on is not null
group by 1,2,3,4
order by ra.first_purchased_on desc
limit 20000
