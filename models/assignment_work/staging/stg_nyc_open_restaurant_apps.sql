-- Clean and standardize Open Restaurant Applications data

WITH source AS (
    SELECT * 
    FROM {{ source('raw', 'source_nyc_open_restaurant_apps') }}
),

cleaned AS (
    SELECT
        -- Keep everything except what we clean
        * EXCEPT (
            objectid,
            restaurant_name,
            legal_business_name,
            borough,
            zip
        ),

        -- ID
        CAST(objectid AS STRING) AS application_id,

        -- Names
        TRIM(CAST(restaurant_name AS STRING)) AS restaurant_name,
        TRIM(CAST(legal_business_name AS STRING)) AS legal_business_name,

        -- Borough standardization
        INITCAP(TRIM(borough)) AS borough,

        -- Zip cleaning (simple version)
        CASE
            WHEN LENGTH(CAST(zip AS STRING)) = 5 THEN CAST(zip AS STRING)
            ELSE NULL
        END AS zip,

        -- Metadata
        CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source

    -- Basic filter
    WHERE objectid IS NOT NULL

    -- Deduplicate
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY objectid 
        ORDER BY objectid
    ) = 1
)

SELECT * FROM cleaned