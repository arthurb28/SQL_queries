select
rt.*

from wkda_retail_ad.retail_ad ra
left join wkda_retail_refurbishment.refurbishment as r on r.retail_ad_id = ra.id
left join wkda_retail_refurbishment.refurbishment_transition rt on rt.refurbishment_id = r.id

where ra.stock_number = 'DW39504'

order by transition_date
