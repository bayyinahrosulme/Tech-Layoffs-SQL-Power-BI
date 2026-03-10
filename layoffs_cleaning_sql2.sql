-- =====================
-- EXPLORATORY ANALYSIS
-- =====================

-- Total layoffs by industry
SELECT industry,
SUM(laid_off) AS total_laid_off
FROM layoffs_staging
WHERE laid_off IS NOT NULL
GROUP BY industry
ORDER BY total_laid_off DESC;


-- Top 10 companies by total layoffs
SELECT company,
SUM(laid_off) AS total_laid_off
FROM layoffs_staging
WHERE laid_off IS NOT NULL
GROUP BY company
ORDER BY total_laid_off DESC
LIMIT 10;

-- Total layoffs by year
SELECT year,
SUM(laid_off) AS total_laid_off
FROM layoffs_staging
WHERE laid_off IS NOT NULL
AND year IS NOT NULL
GROUP BY year
ORDER BY total_laid_off DESC;


-- Top 5 companies by layoffs per year
WITH company_year AS (
    SELECT company,
    year,
    SUM(laid_off) AS total_laid_off
    FROM layoffs_staging
    WHERE laid_off IS NOT NULL
    AND year IS NOT NULL
    GROUP BY company, year
),
company_year_rank AS (
    SELECT *,
    DENSE_RANK() OVER(
        PARTITION BY year
        ORDER BY total_laid_off DESC
    ) AS ranking
    FROM company_year
)
SELECT * FROM company_year_rank
WHERE ranking <= 5
ORDER BY year, ranking;


-- Monthly rolling total of layoffs
WITH monthly_totals AS (
    SELECT 
    DATE_TRUNC('month', date_layoffs) AS month,
    SUM(laid_off) AS total_laid_off
    FROM layoffs_staging
    WHERE laid_off IS NOT NULL
    AND date_layoffs IS NOT NULL
    GROUP BY DATE_TRUNC('month', date_layoffs)
    ORDER BY month
)
SELECT month,
total_laid_off,
SUM(total_laid_off) OVER(
    ORDER BY month
) AS rolling_total
FROM monthly_totals
ORDER BY month;


-- Monthly rolling total of layoffs
WITH monthly_totals AS (
    SELECT 
    CAST(DATE_TRUNC('month', date_layoffs) AS DATE) AS month,
    SUM(laid_off) AS total_laid_off
    FROM layoffs_staging
    WHERE laid_off IS NOT NULL
    AND date_layoffs IS NOT NULL
    GROUP BY DATE_TRUNC('month', date_layoffs)
    ORDER BY month
)
SELECT month,
total_laid_off,
SUM(total_laid_off) OVER(
    ORDER BY month
) AS rolling_total
FROM monthly_totals
ORDER BY month;

-- Total layoffs by country
SELECT country,
SUM(laid_off) AS total_laid_off
FROM layoffs_staging
WHERE laid_off IS NOT NULL
GROUP BY country
ORDER BY total_laid_off DESC
LIMIT 10;



