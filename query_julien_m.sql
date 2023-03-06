WITH 
    extra_infos as (select  cl.stock_number ,rt5.created_on,
sum(CASE WHEN rpc.type = 'technical-inspection'                         THEN rpc.amount ELSE NULL END)/100 AS "technical_inspection", 
u.firstname || ' ' || u.name AS purchaser_by,
u2.firstname || ' ' || u2.name AS priced_by,
u3.first_name || ' ' || u3.last_name as entry_check_by,
rp.autohero_bonus/100 as "bonus",
bap.brand || ' ' || bap.model as model,
b.name as branch_name


from wkda_retail_purchase_fr.car_leads cl 
left join wkda_retail_purchase_fr.retail_ad ra on ra.stock_number=cl.stock_number
LEFT JOIN wkda_retail_purchase_fr.car_evaluations ce ON cl.id = ce.id
LEFT JOIN wkda_retail_purchase_fr.users as u ON ce.evaluation_by = u.id
LEFT JOIN wkda_retail_purchase_fr.users AS u2 ON u2.id = ce.pricing_platform_priced_by
left join wkda_retail_purchase_fr.retail_pricing_costs rpc on   cl.id=rpc.car_id 
left join wkda_retail_purchase_fr.retail_pricing rp  on rp.car_id=cl.id
left join wkda_retail_purchase_fr.retail_refurbishment as r on r.retail_ad_id=ra.id
left join wkda_retail_purchase_fr.retail_refurbishment_transition as rt5 on rt5.refurbishment_id = r.id and rt5.state_to ='REFURBISHMENT_FEEDBACK_RECEIVED'
left join wkda_retail_purchase_fr.retail_refurbishment_transition as rt5b on rt5b.refurbishment_id = rt5.refurbishment_id and rt5b.state_to ='REFURBISHMENT_FEEDBACK_RECEIVED' and rt5b.created_on > rt5.created_on 
left join wkda_retail_purchase_fr.refurbishment_user as u3 on u3.id = rt5.created_by
left join wkda_retail_purchase_fr.ba_retail_purchase as bap on bap.stock_number = ra.stock_number
LEFT JOIN wkda_retail_purchase_fr.branches as b ON cl.branch_id = b.id

where  rt5b.id is null 
 and rt5b.created_on is null
group by 1,2,4,5,6,7,8,9)


SELECT ra.stock_number,
       extra.purchaser_by,
       extra.priced_by,
       extra.entry_check_by,
      extra.bonus,
       extra.technical_inspection,
       to_char(autohero_purchase_on, 'YYMM') as YYMM,
       to_char(autohero_purchase_on, 'YYIW') as YYWW,
       ra.auto1buy_price/100 as a1buy_price,
       ra.net_price_minor_units/100 as sell_price,
      extra.model,
      extra.branch_name
       
       
FROM wkda_retail_purchase_fr.retail_ad ra
left join extra_infos as extra on extra.stock_number=ra.stock_number
left join extra_infos as extra1 on extra.stock_number=extra1.stock_number and extra.created_on < extra1.created_on 



WHERE 1=1
  AND ra.retail_ready_date >= dateadd(month, -6, current_date)
 -- AND rc.retail_ready_date >= '2022-01-01%'
 -- AND rc.retail_ready_date < '2022-06-01%'
  AND ra.stock_number IS NOT NULL
  AND ra.retail_country = 'FR'
  --  and extra1.created_on is null
