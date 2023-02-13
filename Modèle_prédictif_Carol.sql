select rs.*,
rr.stock_number
from wkda_retail_fr_2.retail_refurbishment_service as rs
left join wkda_retail_fr_2.retail_refurbishment as rr on rr.id = rs.refurbishment_id
left join wkda_retail_fr_2.retail_ad as ra on ra.stock_number = rr.stock_number
where (rs.state = 'ORDERED' or rs.state = 'PERFORMED')
and rs.source_type = 'ENTRY_CHECK_SUBMIT'
and ra.state = 'IMPORTED_TO_RETAIL' 
and ra.retail_ready_date is null
limit 10000
