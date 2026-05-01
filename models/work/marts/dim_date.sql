-- models/work/marts/core/dim_date.sql

WITH all_dates AS (

    SELECT DISTINCT CAST(created_date AS DATE) AS full_date
    FROM {{ ref('stg_nyc_311_dot') }}

    UNION DISTINCT

    SELECT DISTINCT CAST(occur_date AS DATE) AS full_date
    FROM {{ ref('stg_shooting_combined') }}

),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['full_date']) }} AS date_key,
        full_date,
        EXTRACT(YEAR FROM full_date) AS year,
        EXTRACT(MONTH FROM full_date) AS month,
        EXTRACT(DAY FROM full_date) AS day,
        EXTRACT(DAYOFWEEK FROM full_date) AS day_of_week
    FROM all_dates
)

SELECT * FROM final