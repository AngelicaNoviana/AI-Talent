-- Benchmark group: employees with rating = 5 in 2025
WITH benchmark_2025 AS (
  SELECT employee_id
  FROM performance_yearly
  WHERE year = 2025
    AND rating = 5
),

-- Competency scores for 2024 & 2025
competencies_24_25 AS (
  SELECT employee_id, pillar_code, year, score
  FROM competencies_yearly
  WHERE year IN (2024, 2025)
),

-- Competency aggregated per employee x pillar (mean across the two years if available)
employee_pillar_avg AS (
  SELECT
    employee_id,
    pillar_code,
    AVG(score)::numeric(6,3) AS avg_score
  FROM competencies_24_25
  GROUP BY employee_id, pillar_code
),

-- Benchmark baselines : median (or mean) per pillar among benchmark employees
benchmark_pillar_baseline AS (
  SELECT
    epa.pillar_code,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY epa.avg_score) AS baseline_median,
    AVG(epa.avg_score)::numeric(6,3) AS baseline_mean
  FROM employee_pillar_avg epa
  JOIN benchmark_2025 b ON b.employee_id = epa.employee_id
  GROUP BY epa.pillar_code
),

-- Full set : employee avg scores joined with baseline
employee_vs_baseline AS (
  SELECT
    epa.employee_id,
    epa.pillar_code,
    epa.avg_score,
    bp.baseline_median,
    bp.baseline_mean
  FROM employee_pillar_avg epa
  LEFT JOIN benchmark_pillar_baseline bp
    ON bp.pillar_code = epa.pillar_code
)

-- Final: sample output table (one row per employee x pillar)
SELECT *
FROM employee_vs_baseline
ORDER BY employee_id, pillar_code;


