{% macro raw_value(name) -%}
  get_ignore_case(payload, '{{ name }}')::varchar
{%- endmacro %}
