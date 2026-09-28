with dates as (
    select pickup_at::date as calendar_date from {{ ref('silver_yellow_trips') }}
    union
    select dropoff_at::date from {{ ref('silver_yellow_trips') }}
)
select to_number(to_char(calendar_date, 'YYYYMMDD')) as date_key,
    calendar_date, year(calendar_date) as year_number,
    quarter(calendar_date) as quarter_number,
    month(calendar_date) as month_number, day(calendar_date) as day_number,
    dayofweekiso(calendar_date) as iso_weekday,
    dayofweekiso(calendar_date) in (6, 7) as is_weekend
from dates
