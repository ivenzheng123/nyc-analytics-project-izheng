WITH source AS (
    SELECT *
    FROM {{ source('raw', 'nyc_shooting_victims') }}
),

cleaned AS (
    SELECT
        -- 
        CAST(incident_key AS STRING) AS incident_id,

        -- 
        CAST(victim_id AS STRING) AS victim_id,

        -- 
        CAST(victim_age_group AS STRING) AS age_group,
        CAST(victim_sex AS STRING) AS gender,
        CAST(victim_race AS STRING) AS race,

        CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source

    WHERE incident_key IS NOT NULL

    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY incident_key, victim_id
        ORDER BY incident_key
    ) = 1
)

SELECT * FROM cleaned