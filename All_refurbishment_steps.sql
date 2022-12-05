-- Environment :RS_BA_RETAIL_PURCHASE_FR
select
rt.*

from wkda_retail_ad.retail_ad ra
left join wkda_retail_refurbishment.refurbishment as r on r.retail_ad_id = ra.id
left join wkda_retail_refurbishment.refurbishment_transition rt on rt.refurbishment_id = r.id

where ra.stock_number = 'DW39504'

order by transition_date

-- Environment :RS_BA_RETAIL_PURCHASE_FR_2
select
rt.*

from wkda_retail_purchase_fr.retail_ad as ra
left join wkda_retail_purchase_fr.retail_refurbishment as r on r.retail_ad_id = ra.id
left join wkda_retail_purchase_fr.retail_refurbishment_transition rt on rt.refurbishment_id = r.id

where ra.stock_number = 'TP26831'

order by transition_date
