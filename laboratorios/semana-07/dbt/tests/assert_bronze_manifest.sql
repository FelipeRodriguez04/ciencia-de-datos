with raw_counts as (
    select source_period,
        count(*) as actual_rows,
        count(distinct source_row) as distinct_source_rows
    from {{ source('tlc', 'raw_yellow_taxi') }}
    group by source_period
), manifest as (
    select source_period, row_count as expected_rows
    from {{ source('tlc', 'yellow_taxi_loads') }}
)
select coalesce(r.source_period, m.source_period) as source_period
from raw_counts r
full outer join manifest m on r.source_period = m.source_period
where r.source_period is null
   or m.source_period is null
   or r.actual_rows <> m.expected_rows
   or r.actual_rows <> r.distinct_source_rows
