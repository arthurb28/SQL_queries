with price_online as (
 select
ra.stock_number
,max(cc.new_value/100)                                                                                                                     as  last_ad_price
from wkda_retail_ad.retail_ad ra
left join wkda_retail_ad.changelog as cc ON ra.ad_id=cc.parent_id
where 1
and cc.field = 'grossPriceMinorUnits'
and ra.stock_number is not null
and (ra.is_test = 'false' or ra.is_test is null)
and auto1buy_price is not null
group by 1
)


select
distinct ra.stock_number
,ra.state
,ra.first_purchased_on                                                                                                                     as autohero_purchase_on
,b.name                                                                                                                                    as branch_name
,ca.first_published_at                                                                                                                     as published_date
,case when json_extract_path_text(ca.
vehicle, 'registration', true)!=''
      then json_extract_path_text(ca.vehicle, 'registration', true) else null end                                                          as registration_date
,json_extract_path_text(ca.vehicle,'modelApi','make',true)                                                                                 as brand
,json_extract_path_text(ca.vehicle,'modelApi','model',true)                                                                                as model
,json_extract_path_text(ca.vehicle,'modelApi','subModel',true)                                                                             as sub_type
,json_extract_path_text(ca.vehicle,'kw',true)                                                                                              as horse_power
,case when json_extract_path_text(ca.vehicle,'fuelType',true)=1039 then 'Benzin'      
      when json_extract_path_text(ca.vehicle, 'fuelType',true)=1040 then 'Diesel'          

      else 'Other' end                                                                                                                     as fuel_type
,json_extract_path_text(ca.
vehicle,'mileage','distance',true)                                                                              as mileage
,json_extract_path_text(ca.vehicle,'builtYear',true)                                                                                       as build_year

,case when oc.country is null then ra.retail_country else oc.country end                                                                   as country_of_origin

,count(distinct(case when opp_created_date is not null and is_lead_archived = 0 then opp_id else null end))                                as total_opps

,nvl(ra.auto1buy_price/100,0)                                                                                                              as auto1buy_price
,refurbishment_car_gp                                                                                                                      as refurbishment
,case when json_extract_path_text(ca.
vehicle, 'gearType') = 1138 then 'Manual'
      when json_extract_path_text(ca.vehicle, 'gearType') = 1139 then 'Automatic'
      when json_extract_path_text(ca.vehicle, 'gearType') = 1140 then 'Semi-Automatic'
      when json_extract_path_text(ca.vehicle, 'gearType') = 1141 then 'Duplex' else 'Other' end                                             as gear_type

,ra.vin                                                                                                                                     as vin
,cd.license_plate                                                                                                                           as license_plate
,doc.name                                                                                                                                   as document_location
,ro.contract_signed_on                                                                                                                      as signed_date
,ra.net_price_minor_units/100                                                                                                               as ad_last_price
--,last_ad_price
,b.country                                                                                                                                 as sourcing_country
,b2.name                                                                                                                                   as workshop_name    

from wkda_retail_ad.retail_ad as ra
left join price_online as po on po.stock_number = ra.stock_number

left join ba_kr_retail_margins as rm on rm.stock_number=ra.stock_number
left join wkda_classifieds.ad as ca on ca.id=ra.ad_id
left join wkda_retail.v_ah_eds_hero_table as hero on hero.stock_number = ra.stock_number
left join wkda.car_leads as cl on cl.stock_number = ra.stock_number
left join wkda.car_purchases as cp on cl.id = cp.id
left join wkda.branches as b on b.id = cl.branch_id
left join wkda.branches as doc on doc.id = cp.document_location_id
left join wkda_retail.country_of_origin_retail as oc on oc.stock_number=ra.stock_number
left join wkda_dm_retail_logistics.car_details as cd on cd.id = cl.id
left join wkda_retail_refurbishment.refurbishment as r on r.retail_ad_id = ra.id
left join wkda_dm_retail_logistics.branches as b2 on b2.id = r.branch_id
left join wkda_dm_retail_logistics.refurbishment as r2 on r2.retail_ad_id = ra.id and r2.created_on > r.created_on

left join wkda_retail.retail_order as ro on ro.stock_number=ra.stock_number
and ro.state not in ('CANCELED', 'CANCELLED')
and ro.contract_signed_on is not null
and ro.canceled_on is null
and (ro.is_test = 'false' or ro.is_test is null)

left join wkda_retail.retail_order_item as roi on ro.id = roi.order_id
and roi.order_id = ro.id
and roi.external_type=0
and ro.state not in ('CANCELED', 'CANCELLED')
and ro.contract_signed_on is not null
and ro.canceled_on is null
and (ro.is_test = 'false' or ro.is_test is null)

left join ba_kr_retail_clm as bro on bro.stock_number = ra.stock_number


where 1
and (ra.is_test = 'false' or ra.is_test is null)
and r2.id is null
and ra.retail_country = 'FR'
and ra.first_purchased_on is not null
and ra.first_purchased_on >= '2021-01-01'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,21,22,23,24,25
