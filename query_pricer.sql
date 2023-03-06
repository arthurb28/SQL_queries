select 

ra.stock_number,
u2.firstname || ' ' || u2.name as priced_by

from wkda_retail_purchase_fr.retail_ad as ra
left join wkda_retail_purchase_fr.car_leads as cl on ra.stock_number = cl.stock_number
LEFT JOIN wkda_retail_purchase_fr.car_evaluations ce ON cl.id = ce.id
LEFT JOIN wkda_retail_purchase_fr.users AS u2 ON u2.id = ce.pricing_platform_priced_by

order by ra.autohero_purchase_on desc

limit 6000
