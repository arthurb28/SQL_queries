// https://dash.prod.bi.auto1.team/queries/49574/source#51768

// this query is working :) 
____________________________________
select
distinct ra.stock_number
,ra.state
,status_id
,cs.picked_up_datetime

from wkda_retail_ad.retail_ad as ra
left join wkda.car_leads as cl on cl.stock_number = ra.stock_number
left join wkda.car_sales as cs on cs.id = cl.id

where ra.state = 'RETURN_TO_AUTO1'
and (ra.is_test = 'false' or ra.is_test is null)
and ra.first_purchased_on is not null
and ra.retail_country = 'FR'
____________________________________
 // V2 (this query is also working) : 
 
 select
distinct ra.stock_number
,ra.state
,status_id
,cs.pickup_date
,cs.picked_up_datetime
,cs.pickup_date_updated_at
,cs.pickup_date_confirmed_bool
,cs.picked_up_bool

from wkda_retail_ad.retail_ad as ra
left join wkda.car_leads as cl on cl.stock_number = ra.stock_number
left join wkda.car_sales as cs on cs.id = cl.id

where ra.state = 'RETURN_TO_AUTO1'
and (ra.is_test = 'false' or ra.is_test is null)
and ra.first_purchased_on is not null
and ra.retail_country = 'FR'

_______________________________________
