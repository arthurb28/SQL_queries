with url_table as (
 select  distinct 
 eci.entry_check_id,
json_extract_path_text(eciv.proposed_value, 'imageUrl', true)  as url_image
from  wkda_retail_purchase_fr.refurbishment_entry_check_item as eci 
 left join wkda_retail_purchase_fr.refurbishment_entry_check_item_value as eciv on eci.id = eciv.entry_check_item_id and json_extract_path_text(eciv.proposed_value, 'payloadType', true) = 'DAMAGE_IMAGE'
where  eciv.id is not null
 ),
 
service_name_table as (
 select  distinct 
 eci.entry_check_id,
json_extract_path_text(eciv.proposed_value, 'name', true)  as name
from  wkda_retail_purchase_fr.refurbishment_entry_check_item as eci 
 left join wkda_retail_purchase_fr.refurbishment_entry_check_item_value as eciv on eci.id = eciv.entry_check_item_id and json_extract_path_text(eciv.proposed_value, 'payloadType', true) = 'DAMAGE_SERVICE_NAME'
where  eciv.id is not null
 ),
 
budget_table as (
 select  distinct 
 eci.entry_check_id,
json_extract_path_text(eciv.proposed_value, 'budgetMinorUnits', true)  as budget
from  wkda_retail_purchase_fr.refurbishment_entry_check_item as eci 
 left join wkda_retail_purchase_fr.refurbishment_entry_check_item_value as eciv on eci.id = eciv.entry_check_item_id and json_extract_path_text(eciv.proposed_value, 'payloadType', true) = 'SERVICE_BUDGET'
where  eciv.id is not null
 ),
 
damage_table as (
 select  distinct 
 eci.entry_check_id,
json_extract_path_text(eciv.proposed_value, 'area', true)  as zone,
json_extract_path_text(eciv.proposed_value, 'subArea', true)  as sous_zone,
json_extract_path_text(eciv.proposed_value, 'partName', true)  as partie,
json_extract_path_text(eciv.proposed_value, 'quantity', true)  as quantite,
json_extract_path_text(eciv.proposed_value, 'typeName', true)  as typo,
json_extract_path_text(eciv.proposed_value, 'attribute1Name', true)  as nom_attribut,
json_extract_path_text(eciv.proposed_value, 'attribute1Value', true)  as valeur_attribut
from  wkda_retail_purchase_fr.refurbishment_entry_check_item as eci 
 left join wkda_retail_purchase_fr.refurbishment_entry_check_item_value as eciv on eci.id = eciv.entry_check_item_id and json_extract_path_text(eciv.proposed_value, 'payloadType', true) = 'DAMAGE_TYPE'
where  eciv.id is not null
 ), 
 
 comment_table as (
 select  distinct 
 eci.entry_check_id,
json_extract_path_text(eciv.proposed_value, 'comment', true)  as commentaire
from  wkda_retail_purchase_fr.refurbishment_entry_check_item as eci 
 left join wkda_retail_purchase_fr.refurbishment_entry_check_item_value as eciv on eci.id = eciv.entry_check_item_id and json_extract_path_text(eciv.proposed_value, 'payloadType', true) = 'SERVICE_COMMENT'
where  eciv.id is not null
 )
 

select distinct
td1.url_image as url_image,
td2.name as name,
td3.budget as budget,
td4.zone as zone,
td4.sous_zone as sous_zone,
td4.partie as partie,
td4.quantite as quantite,
td4.typo as typo,
td4.nom_attribut as nom_attribut,
td4.valeur_attribut as valeur_attribut,
td5.commentaire as commentaire
from wkda_retail_purchase_fr.refurbishment_entry_check as ec
left join wkda_retail_purchase_fr.retail_refurbishment_service as rs on rs.refurbishment_id = ec.refurbishment_id
left join wkda_retail_purchase_fr.refurbishment_entry_check_item as eci on ec.id = eci.entry_check_id
left join url_table as td1 on td1.entry_check_id = eci.entry_check_id
left join service_name_table as td2 on td2.entry_check_id = eci.entry_check_id
left join budget_table as td3 on td3.entry_check_id = eci.entry_check_id
left join damage_table as td4 on td4.entry_check_id = eci.entry_check_id
left join comment_table as td5 on td5.entry_check_id = eci.entry_check_id
where ec.refurbishment_id = '9d5314ce-bf94-40b7-9f27-2af2955222fd'
group by 1,2,3,4,5,6,7,8,9,10,11
limit 100
