select
    payload, source_file, source_period, source_row,
    loaded_at, file_content_key, execution_id
from {{ source('tlc', 'raw_yellow_taxi') }}
