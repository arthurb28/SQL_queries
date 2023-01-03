-- query pour connaitre la marge prévue
-- Cost_gate = ctm_net_inv * 0,60

select stock_number,
ctm_net_inv
from ba_kr_retail_margins
where retail_country = 'FR'
