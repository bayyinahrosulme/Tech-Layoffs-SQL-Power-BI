SELECT company, location_hq, industry, date_layoffs, country,
COUNT(*) as duplicate_count
FROM layoffs_staging
GROUP BY company, location_hq, industry, date_layoffs, country
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


WITH duplicate_cte AS (
    SELECT *,
    ROW_NUMBER() OVER(
        PARTITION BY company, location_hq, industry, date_layoffs, country
        ORDER BY nr
    ) AS row_num
    FROM layoffs_staging
)
SELECT * FROM duplicate_cte
WHERE row_num > 1;