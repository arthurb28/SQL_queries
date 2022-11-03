/*select 
ad.stock_number
,dam.retail_ad_id
,dam.photo_id
,at.image_id


from wkda_retail_ad.retail_ad as ad 
left join wkda_retail_ad.retail_ad_damage as dam on ad.id = dam.retail_ad_id
left join wkda_classifieds_image.ad_image ai on ai.photo_id = dam.photo_id
left join wkda_retail_image_tagging.image_tag at on at.image_id = ai.id
left join wkda_retail_refurbishment.refurbishment_service as serv on serv.retail_ad_damage_id = dam.id
left join wkda_retail_refurbishment.refurbishment as ref on ref.id = serv.refurbishment_id	
where 1
and dam.customer_display = 'true'
and ad.stock_number = 'EL26453'
and service_name = 'NO_REPAIR_NEEDED'
and ref.state in ('REFURBISHMENT_AUTHORIZED','REFURBISHMENT_STARTED','REFURBISHMENT_COMPLETED','QUALITY_CHECK_ORDERED','QUALITY_CHECK_COMPLETED','COMPLETED')
and dam.photo_id is not null */

create temp table selected_date as (
    SELECT
        chl.object_id,
        max(date(created_on)) as selected_date
        FROM wkda_retail_ad.changelog as chl
        WHERE object_type='RetailAdDamage'
        and field='customerDisplay'
        and chl.action='update'
        and chl.new_value in (1,'1')
        GROUP BY 1);
        
create temp table last_ref as (
Select
retail_ad_id
,id as refurbishment_id
,rank () over(partition by retail_ad_id order by created_on desc) as rk_last_is_one

from wkda_retail_refurbishment.refurbishment

where state in ('REFURBISHMENT_AUTHORIZED','REFURBISHMENT_STARTED','REFURBISHMENT_COMPLETED','QUALITY_CHECK_ORDERED','QUALITY_CHECK_COMPLETED','COMPLETED')
);

create temp table imp as (select 
ad.stock_number
,dam.retail_ad_id
,dam.photo_id
,at.image_id
,case when selected_date > first_published_at then 1 else null end as ref_shown_after_publishing


from wkda_retail_ad.retail_ad as ad 
left join wkda_retail_ad.retail_ad_damage as dam on ad.id = dam.retail_ad_id
left join wkda_classifieds_image.ad_image ai on ai.photo_id = dam.photo_id
left join wkda_retail_image_tagging.image_tag at on at.image_id = ai.id
left join wkda_retail_refurbishment.refurbishment_service as serv on serv.retail_ad_damage_id = dam.id
left join wkda_retail_refurbishment.refurbishment as ref on ref.id = serv.refurbishment_id	
left join selected_date as sd on sd.object_id = dam.id
left join wkda_classifieds.ad AS ca ON ca.id = ad.ad_id
left join last_ref on last_ref.refurbishment_id = ref.id 

where 1
and last_ref.rk_last_is_one = 1 -- take the last non cancelled refubishment
and dam.customer_display = 'true'
and serv.service_name = 'NO_REPAIR_NEEDED'
and ref.state in ('REFURBISHMENT_AUTHORIZED','REFURBISHMENT_STARTED','REFURBISHMENT_COMPLETED','QUALITY_CHECK_ORDERED','QUALITY_CHECK_COMPLETED','COMPLETED')
and dam.photo_id is not null
and (dam.is_secondary_wheel = 'false' or dam.is_secondary_wheel is null)
and dam.state in ('OPEN','NOT_FIXED')
);


create temp table galleries as  (
select ic.ad_id, case when ic.type in ('EXTERIOR_CLOSED_DOORS','HIGHLIGHT') then 'HIGHLIGHT' else ic.type end as gallery,
  count(*)
 number_of_images
from wkda_classifieds_image.ad_image ai
left join wkda_classifieds_image.image_composite ic on ic.id = ai.composite_id
where 1
and ic.type in ('EXTERIOR','INTERIOR','NEXTGEN_HIGHLIGHT','HIGHLIGHT','EXTERIOR_CLOSED_DOORS')
group by 1,2);


create temp table final as (Select 
ad.retail_country
,ad.stock_number
,ad.state
,ca.published_at::date
,ro.car_handover_on::date
,'https://www.backoffice.autohero.com/en/ad/'||ca.id as car_link
,old_HIGHLIGHT.number_of_images as old_HIGHLIGHT
,EXTERIOR.number_of_images as EXTERIOR
,INTERIOR.number_of_images as INTERIOR
,new_HIGHLIGHT.number_of_images as new_HIGHLIGHT

,count(distinct(photo_id)) as imperfections
,count(distinct(image_id)) as tags
--,count(distinct(case when ref_shown_after_publishing = 1 then photo_id else null end)) as  ref_shown_after_publishing

from wkda_retail_ad.retail_ad as ad
left join wkda_retail.retail_order as ro on ro.stock_number = ad.stock_number
            AND ro.state not in ('CANCELED','CANCELLED') 
            AND ro.contract_signed_on is not null 
            AND ro.canceled_on is null
             
left join wkda_classifieds.ad AS ca ON ca.id=ad.ad_id       
left join imp on imp.stock_number = ad.stock_number

left join galleries as old_HIGHLIGHT on old_HIGHLIGHT.ad_id = ca.id and old_HIGHLIGHT.gallery = 'HIGHLIGHT'
left join galleries as EXTERIOR on EXTERIOR.ad_id = ca.id and EXTERIOR.gallery = 'EXTERIOR'
left join galleries as INTERIOR on INTERIOR.ad_id = ca.id and INTERIOR.gallery = 'INTERIOR'
left join galleries as new_HIGHLIGHT on new_HIGHLIGHT.ad_id = ca.id and new_HIGHLIGHT.gallery = 'NEXTGEN_HIGHLIGHT'

where 
1
and ad.state not in ('RETURN_TO_AUTO1')   
and ad.is_test = 'false'
and ca.first_eligible_to_be_purchased_at is not null
    
group by 1,2,3,4,5,6,7,8,9,10);


Select 
retail_country	
,stock_number	
,state	
,published_at	
,car_handover_on	
,car_link	
,old_highlight	
,exterior	
,interior	
,new_highlight	
,imperfections	
,tags
,case when old_highlight > 0 then 1 else 0 end as has_old
,case when exterior > 0 then 1 else 0 end as has_exterior
,case when interior > 0 then 1 else 0 end as has_interior
,case when new_highlight > 0 then 1 else 0 end as has_highlight
,case when exterior > 0 and interior > 0 and new_highlight > 0 then 1 else 0 end as has_all_new
,case when (exterior > 0 or interior > 0 or new_highlight > 0) then 1 else 0 end as has_some_new
,case when imperfections = 0 then null else tags::decimal/nvl(imperfections,0) end as tagged_share


from  final 

where retail_country= 'FR'
