with candidate as (
select
ra.stock_number,
rt.state_to,
rt.transition_date,
row_number() OVER (PARTITION BY rt.refurbishment_id ORDER BY rt.transition_date desc) AS row_number
from wkda_retail_purchase_fr.retail_ad as ra
left join wkda_retail_purchase_fr.retail_refurbishment as r on r.retail_ad_id = ra.id
left join wkda_retail_purchase_fr.retail_refurbishment_transition rt on rt.refurbishment_id = r.id
order by transition_date desc
)

select *
from candidate
where candidate.row_number = 1
and candidate.state_to = 'RETURN_TO_AUTO1_CANDIDATE'
