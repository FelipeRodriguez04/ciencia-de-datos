with report as (
    select source_period, bronze_rows, rejected_rows, duplicate_rows, accepted_rows
    from {{ ref('quality_by_month') }}
), facts as (
    select source_period, count(*) as fact_rows
    from {{ ref('fct_yellow_trips') }}
    group by source_period
)
select report.source_period
from report left join facts using (source_period)
where report.bronze_rows <> report.rejected_rows + report.duplicate_rows + report.accepted_rows
   or report.accepted_rows <> coalesce(facts.fact_rows, 0)
