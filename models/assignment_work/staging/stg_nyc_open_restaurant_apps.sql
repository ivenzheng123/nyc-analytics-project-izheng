-- Clean and standardize NYC open restaurant applications data
-- One row per application

WITH source AS (
    SELECT *
    FROM {{ source('raw', 'source_nyc_open_restaurant_apps') }}
),

cleaned AS (
    SELECT
        -- remove originals we will recast
        * EXCEPT (
            objectid,
            restaurant_name,
            borough,
            zip,
            time_of_submission,
            latitude,
            longitude
        ),

        -- identifiers
        CAST(objectid AS STRING) AS application_id,

        -- basic info
        CAST(restaurant_name AS STRING) AS restaurant_name,

        -- time
        CAST(time_of_submission AS TIMESTAMP) AS time_of_submission,

        -- location
        UPPER(TRIM(CAST(borough AS STRING))) AS borough,

        CASE
            WHEN LENGTH(CAST(zip AS STRING)) = 5 THEN CAST(zip AS STRING)
            ELSE NULL
        END AS zip,

        CAST(latitude AS DECIMAL) AS latitude,
        CAST(longitude AS DECIMAL) AS longitude,

        -- metadata
        CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source

    WHERE objectid IS NOT NULL

    -- deduplicate
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY objectid 
        ORDER BY time_of_submission DESC
    ) = 1
)

SELECT * FROM cleaned