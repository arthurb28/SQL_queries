with interior_cleaning_table as(
select distinct
rpc.car_id,
rpc.amount/100 as interior_cleaning
from wkda_retail_purchase_fr.retail_pricing_costs as rpc
where rpc.[type] = 'interior-cleaning'
),

exterior_cleaning_table as(
select distinct
rpc.car_id,
rpc.amount/100 as exterior_cleaning
from wkda_retail_purchase_fr.retail_pricing_costs as rpc
where rpc.[type] = 'exterior-cleaning'
),

photos_table as(
select distinct
rpc.car_id,
rpc.amount/100 as photos
from wkda_retail_purchase_fr.retail_pricing_costs as rpc
where rpc.[type] = 'photos'
),

workshop_handling_table as(
select distinct
rpc.car_id,
rpc.amount/100 as workshop_handling
from wkda_retail_purchase_fr.retail_pricing_costs as rpc
where rpc.[type] = 'workshop-handling'
),

exit_check_cleaning_table as(
select distinct
rpc.car_id,
rpc.amount/100 as exit_check_cleaning
from wkda_retail_purchase_fr.retail_pricing_costs as rpc
where rpc.[type] = 'exit-check-cleaning'
),

exit_check_polishing_table as(
select distinct
rpc.car_id,
rpc.amount/100 as exit_check_polishing
from wkda_retail_purchase_fr.retail_pricing_costs as rpc
where rpc.[type] = 'exit-check-polishing'
),

refueling_table as(
select distinct
rpc.car_id,
rpc.amount/100 as refueling
from wkda_retail_purchase_fr.retail_pricing_costs as rpc
where rpc.[type] = 'refueling'
),

optical_repair_table as(
select distinct
rpc.car_id,
rpc.amount/100 as optical_repair
from wkda_retail_purchase_fr.retail_pricing_costs as rpc
where rpc.[type] = 'optical-repair'
),

mechanical_repair_table as(
select distinct
rpc.car_id,
rpc.amount/100 as mechanical_repair
from wkda_retail_purchase_fr.retail_pricing_costs as rpc
where rpc.[type] = 'mechanical-repair'
),

maintenance_repair_table as(
select distinct
rpc.car_id,
rpc.amount/100 as maintenance_repair
from wkda_retail_purchase_fr.retail_pricing_costs as rpc
where rpc.[type] = 'maintenance-repair'
),

extra_work_table as(
select distinct
rpc.car_id,
rpc.amount/100 as extra_work
from wkda_retail_purchase_fr.retail_pricing_costs as rpc
where rpc.[type] = 'extra-work'
),

technical_inspection_table as(
select distinct
rpc.car_id,
rpc.amount/100 as technical_inspection
from wkda_retail_purchase_fr.retail_pricing_costs as rpc
where rpc.[type] = 'technical-inspection'
)

select distinct
cdi.stock_number,
t1.interior_cleaning,
t2.exterior_cleaning,
t3.photos,
t4.workshop_handling,
t5.exit_check_cleaning,
t6.exit_check_polishing,
t7.refueling,
t8.optical_repair,
t9.mechanical_repair,
t10.maintenance_repair,
t11.extra_work,
t12.technical_inspection,
300 as purchasing_buffer,
COALESCE(t1.interior_cleaning, 0)
    + COALESCE(t2.exterior_cleaning, 0)
    + COALESCE(t3.photos, 0)
    + COALESCE(t4.workshop_handling, 0)
    + COALESCE(t5.exit_check_cleaning, 0)
    + COALESCE(t6.exit_check_polishing, 0)
    + COALESCE(t7.refueling, 0)
    + COALESCE(t8.optical_repair, 0)
    + COALESCE(t9.mechanical_repair, 0)
    + COALESCE(t10.maintenance_repair, 0)
    + COALESCE(t11.extra_work, 0)
    + COALESCE(t12.technical_inspection, 0) 
    + COALESCE(purchasing_buffer, 0) AS total_costs
from wkda_retail_purchase_fr.retail_pricing_costs as rpc
left join wkda_retail_purchase_fr.car_document_items as cdi on cdi.car_id = rpc.car_id
left join wkda_retail_purchase_fr.retail_ad as ra on ra.stock_number = cdi.stock_number
left join interior_cleaning_table as t1 on t1.car_id = rpc.car_id
left join exterior_cleaning_table as t2 on t2.car_id = rpc.car_id
left join photos_table as t3 on t3.car_id = rpc.car_id
left join workshop_handling_table as t4 on t4.car_id = rpc.car_id
left join exit_check_cleaning_table as t5 on t5.car_id = rpc.car_id
left join exit_check_polishing_table as t6 on t6.car_id = rpc.car_id
left join refueling_table as t7 on t7.car_id = rpc.car_id
left join optical_repair_table as t8 on t8.car_id = rpc.car_id
left join mechanical_repair_table as t9 on t9.car_id = rpc.car_id
left join maintenance_repair_table as t10 on t10.car_id = rpc.car_id
left join extra_work_table as t11 on t11.car_id = rpc.car_id
left join technical_inspection_table as t12 on t12.car_id = rpc.car_id
where ra.first_purchased_on is not null
order by ra.first_purchased_on desc
limit 1500
