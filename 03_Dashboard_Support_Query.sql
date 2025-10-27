-- AI Talent App & Dashboard --

WITH top10 AS (
  SELECT employee_id,
         final_competency_match
  FROM employee_competency_final
  ORDER BY final_competency_match DESC
  LIMIT 10
),

-- Menghitung avg score per employee × pillar dua tahun terakhir
epa AS (
  SELECT
    employee_id,
    pillar_code,
    AVG(score)::numeric(6,3) AS avg_score
  FROM competencies_yearly
  WHERE year IN (2024, 2025)
  GROUP BY employee_id, pillar_code
),

pillar_rank AS (
  SELECT
    t.employee_id,
    epa.pillar_code,
    epa.avg_score,
    ROW_NUMBER() OVER (
      PARTITION BY t.employee_id
      ORDER BY epa.avg_score DESC
    ) AS rnk
  FROM top10 t
  JOIN epa ON epa.employee_id = t.employee_id
),

key_strengths AS (
  SELECT
    employee_id,
    STRING_AGG(pillar_code, ', ' ORDER BY rnk) AS top_pillars
  FROM pillar_rank
  WHERE rnk <= 3
  GROUP BY employee_id
)

SELECT
  t.employee_id,
  e.fullname,
  ROUND(t.final_competency_match::numeric,2) AS final_score,
  ks.top_pillars AS key_strengths
FROM top10 t
LEFT JOIN key_strengths ks USING (employee_id)
LEFT JOIN employees e USING (employee_id)
ORDER BY final_score DESC;
