select column1::integer as payment_key, column2::varchar as payment_name
from values
    (-1, 'Unknown/unrecognized'),
    (0, 'Flex Fare'),
    (1, 'Credit card'),
    (2, 'Cash'),
    (3, 'No charge'),
    (4, 'Dispute'),
    (5, 'Unknown'),
    (6, 'Voided trip')
