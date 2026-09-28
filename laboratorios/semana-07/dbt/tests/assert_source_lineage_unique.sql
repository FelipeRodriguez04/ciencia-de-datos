select source_file, source_row
from {{ ref('bronze_yellow_trips') }}
group by source_file, source_row
having count(*) > 1
