-- permet d'avoir l'ID -> qui est égal au hash qui se trouve dans l'URL Carol, exemple : 'https://www.carol.autohero.com/en-GB/refurbishment/311ea5cd-4943-4a90-9af4-53704182768c'

select stock_number,
id
from wkda_retail_fr_2.retail_refurbishment
order by created_on desc
limit 10000
