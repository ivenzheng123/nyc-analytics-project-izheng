WITH source AS (
    SELECT *
    FROM {{ source('raw', 'nyc_shooting_incidents') }}
),

cleaned AS (
    SELECT
        -- rename here
        CAST(incident_key AS STRING) AS incident_id,

        CAST(occur_date AS TIMESTAMP) AS occur_date,

        UPPER(TRIM(boro)) AS borough,

        CAST(latitude AS FLOAT64) AS latitude,
        CAST(longitude AS FLOAT64) AS longitude,

        CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source

    WHERE incident_key IS NOT NULL
      AND occur_date IS NOT NULL

    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY incident_key   -- ✅ FIXED HERE
        ORDER BY occur_date DESC
    ) = 1
)

SELECT * FROM cleaned