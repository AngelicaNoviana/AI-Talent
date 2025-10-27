# AI-Talent
This project aims to identify and benchmark top AI talent within the organization based on strategic competency pillars.  
It integrates data analysis, SQL scoring algorithm, and a dynamic dashboard to support data-driven talent decisions.

---

## Business Objective
To evaluate employees readiness for AI-driven roles by :
- Benchmarking individual pillar competency vs. high-performing employees
- Identifying top talent and their strongest capability pillars
- Providing leadership with clear talent insights for future workforce planning

---

## Success Pattern Discovery (Deliverable #1)
We analyze:
- Competency progression (2024–2025)  
- Pillar performance vs. benchmark (High-potential employees | 2025 Rating = 5)  
- Weighted score contribution of each strategic pillar  

Output:  
- **Final Success Formula** based on weighted match score  
- **AI Talent Benchmark** as reference for readiness level  
- **Top Pillar strengths** per employee

Full insight details are included in the **Case Study Report (PDF).**

---

## SQL Logic & Algorithm (Deliverable #2)
✔ Final competency scoring logic using:

- Median benchmark baseline per pillar
- Weighted scoring using strategic priority per pillar
- Aggregation of multi-year competency data

Main SQL file:  
📁 `final_competency_score.sql`

Output table fields:
| Column | Description |
|--------|-------------|
| employee_id | Employee identifier |
| final_competency_match | Weighted talent match score (%) |
| pillars_evaluated | Number of pillars scored |

---

## Streamlit AI Dashboard (Deliverable #3)
A dynamic talent intelligence dashboard providing:
- Top Talent Leaderboard
- Strength Pillars for each employee
- Score Distribution Analytics

🔗 Live App Deployment Link:  
*(https://ai-talent-dashboard-lkdtdhyvbcyeuwc7ojopnj.streamlit.app/)*

---

## Source Code
| File | Description |
|------|-------------|
| `app.py` | Streamlit App |
| `employee_competency_final.csv` | Scored competency output |
| `employees_rows.csv` | Employee master data |
| `strengths_rows.csv` | Top pillar mapping |
| `/sql/*.sql` | All SQL scripts used |

---
