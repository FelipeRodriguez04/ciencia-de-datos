select source_period,
    count(*) as bronze_rows,
    count_if(not is_valid) as rejected_rows,
    count_if(is_valid and duplicate_rank > 1) as duplicate_rows,
    count_if(is_valid and duplicate_rank = 1) as accepted_rows
from {{ ref('int_trip_quality') }}
group by source_period
