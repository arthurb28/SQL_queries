-- Pour le gsheet : https://docs.google.com/spreadsheets/d/1OzoyfqTQobU9beBZl8kNA-wfdzdFxRQFbnoBEmQdvdM/edit#gid=1625647583
-- Query Redash : #51340
with transition_dates as (
    select
        stock_number,
        min(open_date) as open_date,
        min(refurb_ordered_date) as refurb_ordered_date,
        min(car_in_ws_date) as car_in_ws_date,
        min(car_in_buffer_date) as car_in_buffer_date,
        min(prepared_for_ec_date) as prepared_for_ec_date,
        min(prep_start_date) as prep_start_date,
        min(ready_for_cost_calc_date) as ready_for_cost_calc_date,
        min(refurb_feedback_date) as refurb_feedback_date,
        min(refurb_auth_date) as refurb_auth_date,
        min(refurb_start_date) as refurb_start_date,
        min(refurb_completed_date) as min_refurb_completed_date,
        max(refurb_completed_date) as max_refurb_completed_date,
        max(refurb_completed_full_date) as max_refurb_completed_full_date,
        min(refurb_qa_order_date) as refurb_qa_order_date,
        min(refurb_qa_completed_date) as refurb_qa_completed_date,
        min(completed_date) as completed_date,
        max(cancelled_date) as max_cancelled_date,
        min(auto1_return_flag_date) as auto1_return_flag_date,
        min(return_to_auto1_candidate_date) as return_to_auto1_candidate_date
        
    from (
        select
            ra.stock_number,
            case when state_to = 'OPEN' then datediff(day, '1899-12-30', transition_date) end as open_date,
            case when state_to = 'REFURBISHMENT_ORDERED' then datediff(day, '1899-12-30', transition_date) end as refurb_ordered_date,
            case when state_to = 'CAR_ARRIVED_IN_WORKSHOP' then datediff(day, '1899-12-30', transition_date) end as car_in_ws_date,
            case when state_to = 'CAR_IN_BUFFER' then datediff(day, '1899-12-30', transition_date) end as car_in_buffer_date,
            case when state_to = 'PREPARED_FOR_ENTRY_CHECK' then datediff(day, '1899-12-30', transition_date) end as prepared_for_ec_date,
            case when state_to = 'PREPARATION_STARTED' then datediff(day, '1899-12-30', transition_date) end as prep_start_date,
            case when state_to = 'READY_FOR_COST_CALCULATION' then datediff(day, '1899-12-30', transition_date) end as ready_for_cost_calc_date,
            case when state_to = 'REFURBISHMENT_FEEDBACK_RECEIVED' then datediff(day, '1899-12-30', transition_date) end as refurb_feedback_date,
            case when state_to = 'REFURBISHMENT_AUTHORIZED' then datediff(day, '1899-12-30', transition_date) end as refurb_auth_date,
            case when state_to = 'REFURBISHMENT_STARTED' then datediff(day, '1899-12-30', transition_date) end as refurb_start_date,
            case when state_to = 'REFURBISHMENT_COMPLETED' then datediff(day, '1899-12-30', transition_date) end as refurb_completed_date,
            case when state_to = 'REFURBISHMENT_COMPLETED' then transition_date end as refurb_completed_full_date,
            case when state_to = 'QUALITY_CHECK_ORDERED' then datediff(day, '1899-12-30', transition_date) end as refurb_qa_order_date,
            case when state_to = 'QUALITY_CHECK_COMPLETED' then datediff(day, '1899-12-30', transition_date) end as refurb_qa_completed_date,
            case when state_to = 'COMPLETED' then datediff(day, '1899-12-30', transition_date) end as completed_date,
            case when state_to = 'CANCELLED' then datediff(day, '1899-12-30', transition_date) end as cancelled_date,
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
        min(open_date) as open_date,
        min(refurb_ordered_date) as refurb_ordered_date,
        min(car_in_ws_date) as car_in_ws_date,
        min(car_in_buffer_date) as car_in_buffer_date,
        min(prepared_for_ec_date) as prepared_for_ec_date,
        min(prep_start_date) as prep_start_date,
        min(ready_for_cost_calc_date) as ready_for_cost_calc_date,
        min(refurb_feedback_date) as refurb_feedback_date,
        min(refurb_auth_date) as refurb_auth_date,
        min(refurb_start_date) as refurb_start_date,
        min(refurb_completed_date) as min_refurb_completed_date,
        max(refurb_completed_date) as max_refurb_completed_date,
        max(refurb_completed_full_date) as max_refurb_completed_full_date,
        min(refurb_qa_order_date) as refurb_qa_order_date,
        min(refurb_qa_completed_date) as refurb_qa_completed_date,
        min(completed_date) as completed_date,
        max(cancelled_date) as max_cancelled_date,
        min(auto1_return_flag_date) as auto1_return_flag_date,
        min(return_to_auto1_candidate_date) as return_to_auto1_candidate_date
        
    from (
        select
            ra.stock_number,
            case when state_to = 'OPEN' then datediff(day, '1899-12-30', transition_date) end as open_date,
            case when state_to = 'REFURBISHMENT_ORDERED' then datediff(day, '1899-12-30', transition_date) end as refurb_ordered_date,
            case when state_to = 'CAR_ARRIVED_IN_WORKSHOP' then datediff(day, '1899-12-30', transition_date) end as car_in_ws_date,
            case when state_to = 'CAR_IN_BUFFER' then datediff(day, '1899-12-30', transition_date) end as car_in_buffer_date,
            case when state_to = 'PREPARED_FOR_ENTRY_CHECK' then datediff(day, '1899-12-30', transition_date) end as prepared_for_ec_date,
            case when state_to = 'PREPARATION_STARTED' then datediff(day, '1899-12-30', transition_date) end as prep_start_date,
            case when state_to = 'READY_FOR_COST_CALCULATION' then datediff(day, '1899-12-30', transition_date) end as ready_for_cost_calc_date,
            case when state_to = 'REFURBISHMENT_FEEDBACK_RECEIVED' then datediff(day, '1899-12-30', transition_date) end as refurb_feedback_date,
            case when state_to = 'REFURBISHMENT_AUTHORIZED' then datediff(day, '1899-12-30', transition_date) end as refurb_auth_date,
            case when state_to = 'REFURBISHMENT_STARTED' then datediff(day, '1899-12-30', transition_date) end as refurb_start_date,
            case when state_to = 'REFURBISHMENT_COMPLETED' then datediff(day, '1899-12-30', transition_date) end as refurb_completed_date,
            case when state_to = 'REFURBISHMENT_COMPLETED' then transition_date end as refurb_completed_full_date,
            case when state_to = 'QUALITY_CHECK_ORDERED' then datediff(day, '1899-12-30', transition_date) end as refurb_qa_order_date,
            case when state_to = 'QUALITY_CHECK_COMPLETED' then datediff(day, '1899-12-30', transition_date) end as refurb_qa_completed_date,
            case when state_to = 'COMPLETED' then datediff(day, '1899-12-30', transition_date) end as completed_date,
            case when state_to = 'CANCELLED' then datediff(day, '1899-12-30', transition_date) end as cancelled_date,
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
ra.state,
td.auto1_return_flag_date,
td.return_to_auto1_candidate_date



from wkda_retail_fr_2.retail_ad as ra
left join transition_dates as td on td.stock_number = ra.stock_number
left join transition_dates_2 as td2 on td2.stock_number = ra.stock_number

where 
ra.state = 'IMPORTED_TO_RETAIL'
and (td.auto1_return_flag_date is not null or td.return_to_auto1_candidate_date is not null)
