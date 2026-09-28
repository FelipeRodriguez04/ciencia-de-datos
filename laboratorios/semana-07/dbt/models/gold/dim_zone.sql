select location_id as zone_key, borough, zone_name, service_zone
from {{ ref('taxi_zones') }}
union all
select -1, 'Unknown', 'Unknown', 'Unknown'
