-- =====================
-- DATA CLEANING
-- =====================

-- Create staging table
CREATE TABLE layoffs_staging AS
SELECT * FROM layoffs;

-- Check for duplicates
SELECT company, location_hq, industry, date_layoffs, country,
COUNT(*) AS duplicate_count
FROM layoffs_staging
GROUP BY company, location_hq, industry, date_layoffs, country
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Identify duplicates with ROW_NUMBER()
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

-- Delete duplicates
WITH duplicate_cte AS (
    SELECT *,
    ROW_NUMBER() OVER(
        PARTITION BY company, location_hq, industry, date_layoffs, country
        ORDER BY nr
    ) AS row_num
    FROM layoffs_staging
)
DELETE FROM layoffs_staging
WHERE nr IN (
    SELECT nr FROM duplicate_cte
    WHERE row_num > 1
);

-- Trim extra spaces from company names
UPDATE layoffs_staging
SET company = TRIM(company);

-- Standardize industry names
UPDATE layoffs_staging
SET industry = 'AI'
WHERE industry IN (
    'AI chip startup',
    'AI companion app',
    'AI startup',
    'AI transcription and captioning',
    'AI. made in India. for the world.',
    'Conversational chatbot tools'
);

UPDATE layoffs_staging
SET industry = 'Electronics'
WHERE industry = 'Appliances. Electrical. and Electronics Manufacturing';

UPDATE layoffs_staging
SET industry = 'Transportation'
WHERE industry = 'Autonomous-driving vehicles';

UPDATE layoffs_staging
SET industry = 'Food'
WHERE industry = 'Business catering';

UPDATE layoffs_staging
SET industry = 'Cloud'
WHERE industry IN ('cloud', 'Cloud technology');

UPDATE layoffs_staging
SET industry = 'Hardware'
WHERE industry IN ('Computer games', 'Computer memory');

UPDATE layoffs_staging
SET industry = 'Consumer'
WHERE industry IN ('e-commerce', 'E-sport');

UPDATE layoffs_staging
SET industry = 'IT Management'
WHERE industry = 'Enterprise Apple device management';

UPDATE layoffs_staging
SET industry = 'Finance'
WHERE industry IN ('EV financing platform', 'Venture capital fund');

UPDATE layoffs_staging
SET industry = 'HR'
WHERE industry IN (
    'Freelance services marketplace',
    'HR and payroll software',
    'Worker skills intelligence startup'
);

UPDATE layoffs_staging
SET industry = 'Gaming'
WHERE industry IN (
    'Game studio',
    'Online gaming',
    'Video-sharing social network'
);

UPDATE layoffs_staging
SET industry = 'Social Media'
WHERE industry IN (
    'Social media management',
    'Social media startup',
    'Social posting site'
);

UPDATE layoffs_staging
SET industry = 'Travel'
WHERE industry = 'Online travel agency and search engine';

-- Remove rows with no layoff data
DELETE FROM layoffs_staging
WHERE laid_off IS NULL
AND percentage IS NULL;