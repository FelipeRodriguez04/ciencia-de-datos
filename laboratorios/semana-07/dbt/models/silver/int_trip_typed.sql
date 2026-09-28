{{ config(materialized='view') }}
select
    sha2(to_json(payload), 256) as trip_key,
    source_file, source_period, source_row, loaded_at,
    file_content_key, execution_id,
    try_to_timestamp_ntz({{ raw_value('tpep_pickup_datetime') }}) as pickup_at,
    try_to_timestamp_ntz({{ raw_value('tpep_dropoff_datetime') }}) as dropoff_at,
    try_to_number({{ raw_value('VendorID') }}, 10, 0)::integer as vendor_id,
    try_to_number({{ raw_value('RatecodeID') }}, 10, 0)::integer as rate_code_id,
    try_to_number({{ raw_value('payment_type') }}, 10, 0)::integer as payment_type_id,
    try_to_number({{ raw_value('PULocationID') }}, 10, 0)::integer as pickup_location_id,
    try_to_number({{ raw_value('DOLocationID') }}, 10, 0)::integer as dropoff_location_id,
    try_to_number({{ raw_value('passenger_count') }}, 10, 0)::integer as passenger_count_raw,
    upper(trim({{ raw_value('store_and_fwd_flag') }})) as store_and_fwd_raw,
    try_to_decimal({{ raw_value('trip_distance') }}, 18, 3) as trip_distance,
    {% for field in ['fare_amount', 'extra', 'mta_tax', 'tip_amount', 'tolls_amount',
       'improvement_surcharge', 'total_amount', 'congestion_surcharge', 'airport_fee',
       'cbd_congestion_fee'] %}
    try_to_decimal({{ raw_value(field) }}, 18, 2) as {{ field }}{{ ',' if not loop.last }}
    {% endfor %}
from {{ ref('bronze_yellow_trips') }}
