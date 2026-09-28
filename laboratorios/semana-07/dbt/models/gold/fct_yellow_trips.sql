select
    t.trip_key,
    to_number(to_char(t.pickup_at, 'YYYYMMDD')) as pickup_date_key,
    to_number(to_char(t.dropoff_at, 'YYYYMMDD')) as dropoff_date_key,
    hour(t.pickup_at) as pickup_hour_key,
    hour(t.dropoff_at) as dropoff_hour_key,
    coalesce(pu.zone_key, -1) as pickup_zone_key,
    coalesce(dz.zone_key, -1) as dropoff_zone_key,
    coalesce(v.vendor_key, -1) as vendor_key,
    coalesce(r.rate_key, -1) as rate_key,
    coalesce(p.payment_key, -1) as payment_key,
    t.pickup_at, t.dropoff_at, t.passenger_count, t.store_and_fwd_flag,
    1 as trip_count, t.trip_distance, t.duration_seconds,
    t.fare_amount, t.extra, t.mta_tax, t.tip_amount, t.tolls_amount,
    t.improvement_surcharge, t.total_amount, t.congestion_surcharge,
    t.airport_fee, t.cbd_congestion_fee,
    t.period_mismatch, t.duration_outlier, t.zero_distance,
    t.negative_adjustment, t.amount_mismatch,
    t.source_file, t.source_period, t.source_row, t.loaded_at
from {{ ref('silver_yellow_trips') }} t
left join {{ ref('dim_zone') }} pu on t.pickup_location_id = pu.zone_key
left join {{ ref('dim_zone') }} dz on t.dropoff_location_id = dz.zone_key
left join {{ ref('dim_vendor') }} v on t.vendor_id = v.vendor_key
left join {{ ref('dim_rate') }} r on t.rate_code_id = r.rate_key
left join {{ ref('dim_payment') }} p on t.payment_type_id = p.payment_key
