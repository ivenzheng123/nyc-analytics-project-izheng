-- Clean and standardize 311 Drug Activity data

WITH source AS (
    SELECT * 
    FROM {{ source('raw', 'nyc_311_drug_activity') }}
),

cleaned AS (
    SELECT
        -- identifiers
        CAST(unique_key AS STRING) AS request_id,

        -- dates
        CAST(created_date AS TIMESTAMP) AS created_date,
        CAST(closed_date AS TIMESTAMP) AS closed_date,

        -- text fields
        CAST(agency AS STRING) AS agency,
        CAST(agency_name AS STRING) AS agency_name,
        CAST(complaint_type AS STRING) AS complaint_type,
        CAST(descriptor AS STRING) AS descriptor,
        UPPER(TRIM(CAST(status AS STRING))) AS status,

        -- location
        CASE
            WHEN LENGTH(CAST(incident_zip AS STRING)) = 5 THEN CAST(incident_zip AS STRING)
            ELSE NULL
        END AS zip_code,

        CASE
            WHEN UPPER(TRIM(borough)) IN ('MANHATTAN') THEN 'Manhattan'
            WHEN UPPER(TRIM(borough)) IN ('BRONX') THEN 'Bronx'
            WHEN UPPER(TRIM(borough)) IN ('BROOKLYN') THEN 'Brooklyn'
            WHEN UPPER(TRIM(borough)) IN ('QUEENS') THEN 'Queens'
            WHEN UPPER(TRIM(borough)) IN ('STATEN ISLAND') THEN 'Staten Island'
            ELSE 'UNKNOWN'
        END AS borough,

        CAST(latitude AS FLOAT64) AS latitude,
        CAST(longitude AS FLOAT64) AS longitude,

        CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source

    WHERE unique_key IS NOT NULL
      AND created_date IS NOT NULL

    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY unique_key
        ORDER BY created_date DESC
    ) = 1
)

SELECT * FROM cleaned