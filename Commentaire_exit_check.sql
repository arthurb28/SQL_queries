-- query de Jonas du Quality Master "https://dash.prod.bi.auto1.team/queries/41818/source#43696" où j'ai ajouté le commentaire de l'exit lorsqu'il y a des dommages

with exc_repairs as (
select 

date(c.created_on) AS repairs_created_on,
exc.stock_number, 
b.name AS localisation,
c.old_value as old_value,
c.new_value as new_value

from wkda_retail_refurbishment_exit.changelog as c
left join wkda_retail_refurbishment_exit.exit_checks as exc on exc.id = c.parent_id
left join wkda_dm_retail_logistics.branches as b on b.id = exc.location_id

where c.old_value = 'PREPARED' 
and c.new_value IN ('REPAIRS_NEEDED','COMPLETED')
AND repairs_created_on > current_date - interval '4 month'
)

select

DISTINCT ra.stock_number
,excr.localisation as localisation_exit
,b.name as last_ws_bo -- NEW
,excr.old_value
,excr.new_value
,excr.repairs_created_on as repairs_created_on
,u3.first_name || ' ' || u3.last_name as qc_terrain_by
,u4.first_name || ' ' || u4.last_name as qc_central_by
,ue.first_name || ' ' || ue.last_name as exit_check_by
,ra.id
,r.branch_id
,e.last_completed_exit_check_id
,eee.comment


from wkda_retail_ad.retail_ad as ra
left join wkda_retail_refurbishment.refurbishment as r on r.retail_ad_id=ra.id
left join wkda_retail_refurbishment.refurbishment as r2 on r2.retail_ad_id=ra.id and r2.created_on > r.created_on
left join wkda_dm_retail_logistics.branches as b on b.id = r.branch_id
left join wkda_retail_refurbishment_exit.exit_checks as e on e.stock_number = ra.stock_number and e.state = 'COMPLETED' -- completion date
left join wkda_retail_refurbishment_exit.exit_checks as e2 on e2.stock_number = e.stock_number and e2.state = 'COMPLETED' and e2.completed_on > e.completed_on -- completion date
left join wkda_retail_refurbishment.refurbishment_transition as rt1 on rt1.refurbishment_id = r.id and rt1.state_to ='PREPARATION_STARTED'
left join wkda_retail_refurbishment.refurbishment_transition as rt1b on rt1b.refurbishment_id = r.id and rt1b.state_to ='PREPARATION_STARTED' and rt1b.created_on < rt1.created_on
left join wkda_retail_refurbishment.refurbishment_transition as rt2 on rt2.refurbishment_id = r.id and rt2.state_to ='REFURBISHMENT_AUTHORIZED'
left join wkda_retail_refurbishment.refurbishment_transition as rt2b on rt2b.refurbishment_id = r.id and rt2b.state_to ='REFURBISHMENT_AUTHORIZED' and rt2b.created_on < rt2.created_on
left join wkda_retail_refurbishment.refurbishment_transition as rt3 on rt3.refurbishment_id = r.id and rt3.state_to ='QUALITY_CHECK_ORDERED'
left join wkda_retail_refurbishment.refurbishment_transition as rt3b on rt3b.refurbishment_id = r.id and rt3b.state_to ='QUALITY_CHECK_ORDERED' and rt3b.created_on < rt3.created_on
left join wkda_retail_refurbishment.refurbishment_transition as rt4 on rt4.refurbishment_id = r.id and rt4.state_to ='QUALITY_CHECK_COMPLETED'
left join wkda_retail_refurbishment.refurbishment_transition as rt4b on rt4b.refurbishment_id = r.id and rt4b.state_to ='QUALITY_CHECK_COMPLETED' and rt4b.created_on < rt4.created_on
left join wkda_retail_refurbishment.refurbishment_transition as rt5 on rt5.refurbishment_id = r.id and rt5.state_to ='REFURBISHMENT_ORDERED'
left join wkda_retail_refurbishment.refurbishment_transition as rt5b on rt5b.refurbishment_id = r.id and rt5b.state_to ='REFURBISHMENT_ORDERED' and rt5b.created_on < rt5.created_on
left join wkda_retail_refurbishment.refurbishment_transition as rt6 on rt6.refurbishment_id = r.id and rt6.state_to ='REFURBISHMENT_STARTED'
left join wkda_retail_refurbishment.refurbishment_transition as rt6b on rt6b.refurbishment_id = r.id and rt6b.state_to ='REFURBISHMENT_STARTED' and rt6b.created_on < rt6.created_on
left join wkda_refurbishment_user.user as ue on ue.id = e.updated_by
left join wkda_refurbishment_user.user as u1 on u1.id = rt1.created_by
left join wkda_refurbishment_user.user as u2 on u2.id = rt2.created_by
left join wkda_refurbishment_user.user as u3 on u3.id = rt3.created_by
left join wkda_refurbishment_user.user as u4 on u4.id = rt4.created_by
left join wkda_refurbishment_user.user as u5 on u5.id = rt5.created_by
left join wkda_refurbishment_user.user as u6 on u6.id = rt6.created_by
left join exc_repairs as excr on excr.stock_number = ra.stock_number
left join wkda_retail_refurbishment_exit.damages as eee on eee.exit_check_id = e.last_completed_exit_check_id

where 1
and (ra.is_test = 'false' or ra.is_test is null)
and repairs_created_on > current_date - interval '4 month'
and ra.retail_country = 'FR'
and ra.first_purchased_on is not null
and r2.id is null
and e2.id is null
and rt1b.id is null
and rt2b.id is null
and rt3b.id is null
and rt4b.id is null
and rt5b.id is null
and rt6b.id is null
and excr.repairs_created_on is not null
and eee.comment is not null

ORDER BY repairs_created_on

-- CS56251 exemple d'un cas où l'exit-check est passé 2X en statut REPAIRS_NEEDED
