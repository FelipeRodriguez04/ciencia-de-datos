select column1::integer as rate_key, column2::varchar as rate_name
from values
    (-1, 'Unknown'),
    (1, 'Standard rate'),
    (2, 'JFK'),
    (3, 'Newark'),
    (4, 'Nassau or Westchester'),
    (5, 'Negotiated fare'),
    (6, 'Group ride'),
    (99, 'Null/unknown')
