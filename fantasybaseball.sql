--Create two CTEs

WITH topn_points AS (
    SELECT 
        full_name,
        Total_Points,
        Average_Points,
        Pos
    FROM major_hitters
    WHERE year = 2023
    ORDER BY Total_Points DESC
    LIMIT 135
),
medians AS (
    SELECT
        Pos,
        ROUND(AVG(Average_Points),2) AS median_avg_points
    FROM (
        SELECT 
            Pos,
            Average_Points,
            ROW_NUMBER() OVER (PARTITION BY Pos ORDER BY Average_Points) AS rn,
            COUNT(*) OVER (PARTITION BY Pos) AS total_count
        FROM topn_points
    ) AS ranked
    WHERE rn IN ((total_count + 1) / 2, (total_count + 2) / 2)
    GROUP BY Pos
)

--Write a query using a left join two retrieve data from both CTEs
SELECT 
    t.full_name,
    t.Pos,
    t.Total_Points,
	ROUND(AVG(t.Total_Points) OVER (PARTITION BY t.Pos), 2) AS position_total,
    ROUND(t.Average_Points, 2) AS avg_points,
    ROUND(AVG(t.Average_Points) OVER (PARTITION BY t.Pos), 2) AS position_avg,
    ROUND(ROUND(t.Average_Points, 2) - ROUND(AVG(t.Average_Points) OVER (PARTITION BY t.Pos), 2), 2) AS points_above_avg,
    COUNT(*) OVER (PARTITION BY t.Pos) AS p_count,
    m.median_avg_points
FROM 
    topn_points AS t
LEFT JOIN 
    medians AS m ON t.Pos = m.Pos
ORDER BY 
    t.Pos;