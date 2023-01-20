with transition_dates as (
    select
        stock_number,
        min(auto1_return_flag_date) as auto1_return_flag_date,
        min(return_to_auto1_candidate_date) as return_to_auto1_candidate_date
        
    from (
        select
            ra.stock_number,
            case when state_to = 'FLAG_FOR_RETURN_TO_AUTO1' then datediff(day, '1899-12-30', transition_date) end as auto1_return_flag_date,
            case when state_to = 'RETURN_TO_AUTO1_CANDIDATE' then datediff(day, '1899-12-30', transition_date) end as return_to_auto1_candidate_date
            

        from wkda_retail_fr_2.retail_refurbishment_transition rt
        left join wkda_retail_fr_2.retail_refurbishment as r on rt.refurbishment_id = r.id
        left join wkda_retail_fr_2.retail_ad as ra on r.retail_ad_id=ra.id
        where r.cancel_reason is null
        order by transition_date
    ) group by stock_number
),


transition_dates_2 as (
    select
        stock_number,
        min(auto1_return_flag_date) as auto1_return_flag_date,
        min(return_to_auto1_candidate_date) as return_to_auto1_candidate_date
        
    from (
        select
            ra.stock_number,
            case when state_to = 'FLAG_FOR_RETURN_TO_AUTO1' then datediff(day, '1899-12-30', transition_date) end as auto1_return_flag_date,
            case when state_to = 'RETURN_TO_AUTO1_CANDIDATE' then datediff(day, '1899-12-30', transition_date) end as return_to_auto1_candidate_date
        from wkda_retail_fr_2.retail_refurbishment_transition rt
        left join wkda_retail_fr_2.retail_refurbishment as r on rt.refurbishment_id = r.id
        left join wkda_retail_fr_2.retail_ad as ra on r.retail_ad_id=ra.id
--         where r.cancel_reason is null
        order by transition_date
    ) group by stock_number
)

Select
ra.stock_number,
rpc.[type],
rpc.amount/100 as montant,
td.return_to_auto1_candidate_date



from wkda_retail_fr_2.retail_ad as ra
left join transition_dates as td on td.stock_number = ra.stock_number
left join transition_dates_2 as td2 on td2.stock_number = ra.stock_number
left join wkda_retail_fr_2.car_leads as cl on cl.stock_number = ra.stock_number
left join wkda_retail_fr_2.retail_pricing_costs as rpc on rpc.car_id = cl.id

where 
ra.state = 'IMPORTED_TO_RETAIL'
and td.auto1_return_flag_date is null
and td.return_to_auto1_candidate_date is not null
