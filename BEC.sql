with finalsi as 
(
Select distinct
ra.stock_number
, b.name            as final_hub
from wkda_retail_purchase_fr.retail_ad as ra
left join wkda_retail_purchase_fr.retail_order as ro on ro.stock_number = ra.stock_number
left join wkda_retail_purchase_fr.car_leads as car_leads on car_leads.stock_number = ro.stock_number
left join wkda_retail_purchase_fr.logistics_shipping_routes as lsr on lsr.car_id=car_leads.id
left join wkda_retail_purchase_fr.logistics_shipping_items as lsi on lsi.route_id=lsr.id
left join wkda_retail_purchase_fr.branches as b on b.id = lsi.location_id
where lsi.status not in ('900','1000')
and lsi.delivery_location_id is null
)
select distinct
ro.order_number
,ro.stock_number
,location.name as current_location
,finalsi.final_hub
,case when location.name = finalsi.final_hub then 'yes' else 'no' end as at_final_hub
--,bec.status
,case
when bec.status = 10 then 'STARTED'
when bec.status = 20 then 'ACTION_NEEDED'
when bec.status = 30 then 'ACTION_IN_PROGRESS'
when bec.status = 40 then 'PASSED'
end as bec_status
,bec.started_on as latest_bec_started_on
,bec.submitted_on as latest_bec_submitted_on
,bec.passed_on as latest_bec_passed_on
,bra.name as latest_bec_branch
,brec.name as ec_branch
from wkda_retail_purchase_fr.retail_order as ro
left join wkda_retail_purchase_fr.branch_entry_check as bec on bec.order_id = ro.id
left join wkda_retail_purchase_fr.branch_entry_check as bec2 on bec2.order_id = ro.id and bec2.started_on > bec.started_on
left join wkda_retail_purchase_fr.branches as bra on bra.id = bec.branch_id
left join wkda_retail_purchase_fr.retail_refurbishment_exit_checks as ec on ec.stock_number = ro.stock_number
left join wkda_retail_purchase_fr.retail_refurbishment_exit_checks as ec2 on ec2.stock_number = ro.stock_number and ec2.created_on > ec.created_on
left join wkda_retail_purchase_fr.branches as brec on brec.id = ec.location_id
left join wkda_retail_purchase_fr.retail_ad as ra on ro.stock_number = ra.stock_number
left join finalsi as finalsi on finalsi.stock_number = ra.stock_number
left join wkda_retail_purchase_fr.car_leads as cl on cl.stock_number = ro.stock_number
left join wkda_retail_purchase_fr.branches as location on location.id =cl.location_id
where bec.status is not null
and ro.retail_country = 'FR'
and bec2.id is null
and ec2.id is null
--and ro.stock_number = 'GB80563'
--and ro.state in ('CONTRACT_SIGNED', 'PENDING_VERIFICATION', 'VERIFIED')
and ro.state in ('DELIVERED','COMPLETED')
limit 10000
