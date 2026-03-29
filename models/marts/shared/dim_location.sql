-- Location dimension

WITH all_locations AS (

   SELECT DISTINCT
       borough,
       incident_zip AS zip
   FROM {{ ref('stg_nyc_311_dot') }}
   WHERE borough IS NOT NULL

   UNION DISTINCT

   SELECT DISTINCT
       borough,
       zip
   FROM {{ ref('stg_nyc_open_restaurant_apps') }}
   WHERE borough IS NOT NULL
),

final AS (
   SELECT
       {{ dbt_utils.generate_surrogate_key(['borough','zip']) }} AS location_key,
       borough,
       zip AS zip_code
   FROM all_locations
)

SELECT * FROM final