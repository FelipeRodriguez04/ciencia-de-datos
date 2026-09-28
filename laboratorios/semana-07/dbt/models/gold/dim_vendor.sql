select column1::integer as vendor_key, column2::varchar as vendor_name
from values
    (-1, 'Unknown'),
    (1, 'Creative Mobile Technologies LLC'),
    (2, 'Curb Mobility LLC'),
    (6, 'Myle Technologies Inc'),
    (7, 'Helix')
