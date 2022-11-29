select 
rpc.id,
rpc.car_id,
rpc.[type],
rpc.amount/100,
rpc.note,
cdi.stock_number,
ra.first_purchased_on
from wkda_retail_purchase_fr.retail_pricing_costs as rpc
left join wkda_retail_purchase_fr.car_document_items as cdi on cdi.car_id = rpc.car_id
left join wkda_retail_purchase_fr.retail_ad as ra on ra.stock_number = cdi.stock_number
where ra.first_purchased_on is not null
and rpc.amount>0
and rpc.[type] like '%repair%'
group by 1,2,3,4,5,6,7
order by ra.first_purchased_on desc
limit 20000
