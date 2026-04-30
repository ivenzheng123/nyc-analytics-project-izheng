-- Combine incidents + victims (final staging before facts)

WITH incidents AS (
    SELECT
        incident_id,
        occur_date,
        borough,
        latitude,
        longitude
    FROM {{ ref('stg_shooting_incidents') }}
),

victims AS (
    SELECT
        incident_id,
        victim_id,
        age_group,
        gender,
        race
    FROM {{ ref('stg_shooting_victims') }}
),

joined AS (
    SELECT
        i.incident_id,
        i.occur_date,
        i.borough,
        i.latitude,
        i.longitude,

        v.victim_id,
        v.age_group,
        v.gender,
        v.race

    FROM incidents i
    LEFT JOIN victims v
        ON i.incident_id = v.incident_id
)

SELECT * FROM joined