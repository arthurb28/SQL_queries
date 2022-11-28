with finalsi as 

(
Select distinct
ra.stock_number
, car_leads.id as car_id
, lsi.location_id
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






, entry_check as (

select distinct 
ro.order_number
,ro.stock_number
,location.name as current_location
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
,case when rod.branch_id is not null and rbp.name = 'handover-location.private-customer' then 'Pickup From Branch'
      when rod.branch_id is not null and rbp.name not in ('handover-location.private-customer') then 'Wrong Delivery Method'
      when rod.branch_id is not null and bad.id in (64,3,41,233,2,4,72,7,15,76,223,245,240,54,267,344,242,8,355,222) then 'Pickup From Branch'
      when rod.branch_id is not null and bad.id not in (64,3,41,233,2,4,72,7,15,76,223,245,240,54,267,344,242,8,355,222) then 'Wrong Delivery Method'
      when rod.branch_id is null and (sra.street+', '+sra.house_number+', '+sra.zipcode+', '+sra.city+', '+sra.country) is null then 'Wrong Delivery Method'
      when sra.street like 'Am Juliusturm%'  then 'Pickup From Branch'
      when sra.street = bad.street and sra.zipcode = bad.zipcode then 'Pickup From Branch'
      else 'New Shipping Address' end as delivery_type
,(case when json_extract_path_text(json_extract_path_text(json_extract_path_text(bec.form_data,'interior'),'cleanliness'),'level') = 10 then 'clean'
when json_extract_path_text(json_extract_path_text(json_extract_path_text(bec.form_data,'interior'),'cleanliness'),'level') = 20 then 'slightly dirty'
when json_extract_path_text(json_extract_path_text(json_extract_path_text(bec.form_data,'interior'),'cleanliness'),'level') = 30 then 'dirty' else null end) as interior_cleanliness,
(case when json_extract_path_text(json_extract_path_text(json_extract_path_text(bec.form_data,'exterior'),'cleanliness'),'level') = 10 then 'clean'
when json_extract_path_text(json_extract_path_text(json_extract_path_text(bec.form_data,'exterior'),'cleanliness'),'level') = 20 then 'slightly dirty'
when json_extract_path_text(json_extract_path_text(json_extract_path_text(bec.form_data,'exterior'),'cleanliness'),'level') = 30 then 'dirty' else null end) as exterior_cleanliness


from wkda_retail_purchase_fr.retail_order as ro
left join wkda_retail_purchase_fr.branch_entry_check as bec on bec.order_id = ro.id
left join wkda_retail_purchase_fr.branch_entry_check as bec2 on bec2.order_id = ro.id and bec2.started_on > bec.started_on
left join wkda_retail_purchase_fr.branches as bra on bra.id = bec.branch_id
left join wkda_retail_purchase_fr.retail_refurbishment_exit_checks as ec on ec.stock_number = ro.stock_number
left join wkda_retail_purchase_fr.retail_refurbishment_exit_checks as ec2 on ec2.stock_number = ro.stock_number and ec2.created_on > ec.created_on
left join wkda_retail_purchase_fr.branches as brec on brec.id = ec.location_id
left join wkda_retail_purchase_fr.retail_ad as ra on ro.stock_number = ra.stock_number 
left join finalsi as finalsi on finalsi.stock_number = ra.stock_number
left join wkda_retail_purchase_fr.car_document_packages as cdp on cdp.order_id = ro.id and cdp.status <> 'canceled'
left join wkda_retail_purchase_fr.car_document_packages as cdp2 on cdp2.order_id = ro.id and cdp2.status <> 'canceled' and cdp2.created_on > cdp.created_on
left join wkda_retail_purchase_fr.car_leads as cl on cl.stock_number = ro.stock_number
left join wkda_retail_purchase_fr.branches as location on location.id =cl.location_id
left join wkda_retail_purchase_fr.retail_order_address as rod on rod.order_id = ro.id and rod.address_type = 'SHIPPING'
left join wkda_retail_purchase_fr.retail_address as sra on sra.id = rod.address_id
left join wkda_retail_purchase_fr.branches as bad on bad.id = rod.branch_id
left join wkda_retail_purchase_fr.branch_properties as bp on bp.branch_id = location.id
left join wkda_retail_purchase_fr.ref_branch_properties as rbp on rbp.id = bp.property_id

where ro.retail_country = 'FR'
and bec2.id is null
and ec2.id is null
--and ro.stock_number = 'GB80563'
and ro.state in ('CONTRACT_SIGNED', 'PENDING_VERIFICATION', 'VERIFIED')
and lower(location.name) not like '%showroom%' and lower(location.name) not like '%hub%'

)





, main as (

select distinct
ro.order_number
,ro.state
,ro.stock_number
,cd.vin
,cd.license_plate
,ref.manufacturer
,ref.main_type||' '||ref.subtype as model
,(rrc.first_name + ' ' + rrc.last_name) as customer_name
,roh.branch_planned_car_handover_on as handover_date


from wkda_retail_purchase_fr.retail_order as ro
left join wkda_retail_purchase_fr.car_leads as cl on cl.stock_number = ro.stock_number
left join wkda_retail_purchase_fr.car_details cd on cd.id = cl.id
left join wkda_retail_purchase_fr.ref_dat_types ref on ref.dat_ecode = cl.dat_ecode
left join wkda_retail_purchase_fr.retail_customer as rrc on rrc.order_id = ro.id and rrc.type = 'PRIMARY'
left join wkda_retail_purchase_fr.retail_order_handover roh on roh.order_id = ro.id

where ro.retail_country = 'FR'
and ro.state in ('CONTRACT_SIGNED', 'PENDING_VERIFICATION', 'VERIFIED')
)





select 

distinct

main.order_number
,main.handover_date
,main.stock_number
,entry_check.current_location
,finalsi.final_hub
,entry_check.at_final_hub 
,entry_check.bec_status
,entry_check.latest_bec_started_on
,entry_check.latest_bec_submitted_on
,entry_check.latest_bec_passed_on
,entry_check.interior_cleanliness as interior_cleanliness
,entry_check.exterior_cleanliness as exterior_cleanliness
,main.vin
,main.license_plate
,main.manufacturer
,main.model
,main.customer_name
,case when lsi.delivery_date is null then lsi.expected_delivery_date else lsi.delivery_date end as arrive_branch

from main
left join entry_check on entry_check.stock_number = main.stock_number
left join finalsi on finalsi.stock_number = main.stock_number
left join wkda_retail_purchase_fr.logistics_shipping_items lsi on lsi.car_id = finalsi.car_id and lsi.delivery_location_id = finalsi.location_id and lsi.status <> '900'


where entry_check.delivery_type = 'Pickup From Branch'
