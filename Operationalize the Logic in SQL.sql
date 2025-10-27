-- STEP 2: Competency Match Score Calculation 

WITH benchmark_2025 AS (
  SELECT employee_id
  FROM performance_yearly
  WHERE year = 2025
    AND rating = 5
),

competencies_24_25 AS (
  SELECT employee_id, pillar_code, year, score
  FROM competencies_yearly
  WHERE year IN (2024, 2025)
),

employee_pillar_avg AS (
  SELECT
    employee_id,
    pillar_code,
    AVG(score)::numeric(6,3) AS avg_score
  FROM competencies_24_25
  GROUP BY employee_id, pillar_code
),

benchmark_pillar_baseline AS (
  SELECT
    epa.pillar_code,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY epa.avg_score) AS baseline_median
  FROM employee_pillar_avg epa
  JOIN benchmark_2025 b ON b.employee_id = epa.employee_id
  GROUP BY epa.pillar_code
),

pillar_match_rate AS (
  SELECT
    epa.employee_id,
    epa.pillar_code,
    (epa.avg_score / bp.baseline_median) * 100 AS match_pct
  FROM employee_pillar_avg epa
  JOIN benchmark_pillar_baseline bp ON bp.pillar_code = epa.pillar_code
)

SELECT
  pm.employee_id,
  ROUND(AVG(pm.match_pct)::numeric, 2) AS competency_match_pct,
  COUNT(*) AS pillars_evaluated
FROM pillar_match_rate pm
GROUP BY pm.employee_id
ORDER BY competency_match_pct DESC
LIMIT 20;


-- Menghitung GAP Per Pillar --
WITH perf_2025 AS (
  SELECT employee_id, rating
  FROM performance_yearly
  WHERE year = 2025
),

competencies_24_25 AS (
  SELECT employee_id, pillar_code, year, score
  FROM competencies_yearly
  WHERE year IN (2024, 2025)
),

employee_pillar_avg AS (
  SELECT
    employee_id,
    pillar_code,
    AVG(score)::numeric(6,3) AS avg_score
  FROM competencies_24_25
  GROUP BY employee_id, pillar_code
),

grouped AS (
  SELECT
    epa.pillar_code,
    AVG(epa.avg_score) FILTER (WHERE p.rating = 5) AS hp_mean,
    AVG(epa.avg_score) FILTER (WHERE p.rating <> 5 OR p.rating IS NULL) AS ohp_mean
  FROM employee_pillar_avg epa
  LEFT JOIN perf_2025 p ON p.employee_id = epa.employee_id
  GROUP BY epa.pillar_code
)

SELECT
  pillar_code,
  ROUND(hp_mean,2) AS hp_mean,
  ROUND(ohp_mean,2) AS ohp_mean,
  ROUND(((hp_mean - ohp_mean) / hp_mean) * 100, 2) AS gap_pct
FROM grouped
ORDER BY gap_pct DESC;


-- Mengkonversi GAP menjadi Bobot Pillar --
WITH perf_2025 AS (
  SELECT employee_id, rating
  FROM performance_yearly
  WHERE year = 2025
),

competencies_24_25 AS (
  SELECT employee_id, pillar_code, year, score
  FROM competencies_yearly
  WHERE year IN (2024, 2025)
),

employee_pillar_avg AS (
  SELECT
    employee_id,
    pillar_code,
    AVG(score)::numeric(6,3) AS avg_score
  FROM competencies_24_25
  GROUP BY employee_id, pillar_code
),

grouped AS (
  SELECT
    epa.pillar_code,
    AVG(epa.avg_score) FILTER (WHERE p.rating = 5) AS hp_mean,
    AVG(epa.avg_score) FILTER (WHERE p.rating <> 5 OR p.rating IS NULL) AS ohp_mean
  FROM employee_pillar_avg epa
  LEFT JOIN perf_2025 p ON p.employee_id = epa.employee_id
  GROUP BY epa.pillar_code
),
gap_calc AS (
  SELECT
    pillar_code,
    ((hp_mean - ohp_mean) / hp_mean) * 100 AS gap_pct
  FROM grouped
),
total_gap AS (
  SELECT SUM(gap_pct) AS total_gap
  FROM gap_calc
)

SELECT
  g.pillar_code,
  ROUND(g.gap_pct, 2) AS gap_pct,
  ROUND((g.gap_pct / t.total_gap)::numeric, 4) AS weight
FROM gap_calc g
CROSS JOIN total_gap t
ORDER BY weight DESC;


-- Final Competency Score --    
CREATE OR REPLACE VIEW employee_competency_final AS
WITH benchmark_2025 AS (
  SELECT employee_id
  FROM performance_yearly
  WHERE year = 2025
    AND rating = 5
),

competencies_24_25 AS (
  SELECT employee_id, pillar_code, year, score
  FROM competencies_yearly
  WHERE year IN (2024, 2025)
),

employee_pillar_avg AS (
  SELECT
    employee_id,
    pillar_code,
    AVG(score)::numeric(6,3) AS avg_score
  FROM competencies_24_25
  GROUP BY employee_id, pillar_code
),

benchmark_pillar_baseline AS (
  SELECT
    epa.pillar_code,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY epa.avg_score) AS baseline_median
  FROM employee_pillar_avg epa
  JOIN benchmark_2025 b ON b.employee_id = epa.employee_id
  GROUP BY epa.pillar_code
),

pillar_weights AS (
  SELECT 'LIE' AS pillar_code, 0.1365 AS weight UNION ALL
  SELECT 'SEA', 0.1272 UNION ALL
  SELECT 'STO', 0.1223 UNION ALL
  SELECT 'CSI', 0.1199 UNION ALL
  SELECT 'VCU', 0.1149 UNION ALL
  SELECT 'QDD', 0.0877 UNION ALL
  SELECT 'IDS', 0.0822 UNION ALL
  SELECT 'FTC', 0.0799 UNION ALL
  SELECT 'CEX', 0.0795 UNION ALL
  SELECT 'GDR', 0.0500
),

pillar_match AS (
  SELECT
    epa.employee_id,
    epa.pillar_code,
    epa.avg_score,
    bp.baseline_median,
    (epa.avg_score / bp.baseline_median) * 100 AS match_pct,
    pw.weight
  FROM employee_pillar_avg epa
  JOIN benchmark_pillar_baseline bp USING (pillar_code)
  JOIN pillar_weights pw USING (pillar_code)
)

SELECT
  pm.employee_id,
  ROUND((SUM(pm.match_pct * pm.weight) / SUM(pm.weight))::numeric, 2) AS final_competency_match,
  COUNT(*) AS pillars_evaluated
FROM pillar_match pm
GROUP BY pm.employee_id;
