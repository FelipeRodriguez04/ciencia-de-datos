select row_number() over (order by seq4()) - 1 as hour_key,
    hour_key as hour_number,
    case when hour_key < 6 then 'Madrugada'
         when hour_key < 12 then 'Mañana'
         when hour_key < 18 then 'Tarde' else 'Noche' end as day_part
from table(generator(rowcount => 24))
