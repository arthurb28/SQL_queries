---- https://dash.prod.bi.auto1.team/queries/50428/
---> permet d'avoir l'ID de tous les refurb item français et donc d'éliminer les mauvais lead time à cause de re entry check, annulation, ajout d'imper, etc...
_____________________________
select

distinct ra.stock_number
,ra.state
,r.id

from wkda_retail_ad.retail_ad as ra
left join wkda_classifieds.ad as ca on ca.id=ra.ad_id
left join wkda_retail_refurbishment.refurbishment as r on r.retail_ad_id = ra.id

where (ra.is_test = 'false' or ra.is_test is null)
and ra.retail_country = 'FR'
and ra.first_purchased_on is not null
____________________________
