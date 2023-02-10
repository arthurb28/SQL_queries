select 
ra.stock_number,
u.first_name || ' ' || u.last_name as agent,
b.name as ws,
r.refurbishment_type,
rt.*,
to_char(rt.transition_date,'IW') as weeknum,
to_char(rt.transition_date,'mm') as month

from wkda_retail_ad.retail_ad AS ra
left join wkda_retail_refurbishment.refurbishment as r on r.retail_ad_id = ra.id -- and r.cancel_reason is null
left join wkda_retail_refurbishment.refurbishment_transition as rt on rt.refurbishment_id = r.id
left join wkda_refurbishment_user.user as u on u.id = rt.created_by
left join wkda.branches as b on b.id = r.branch_id

where 1
and ra.retail_country = 'FR'
and rt.transition_date > current_date - interval '4 month'
order by transition_date
