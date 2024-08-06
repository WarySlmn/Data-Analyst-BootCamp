-- Exploration des données de licenciements

-- 1. Les 10 premières compagnies qui ont eu le plus de licenciements
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY SUM(total_laid_off) DESC
LIMIT 5;

-- 2. Date minimale et maximale dans les données
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- 3. Industrie qui a eu le plus de licenciements
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY SUM(total_laid_off) DESC;

-- 4. Pays qui a eu le plus de licenciements
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY SUM(total_laid_off) DESC;

-- 5. Année qui a eu le plus de licenciements
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY YEAR(`date`) DESC;

-- 6. Mois qui a eu le plus de licenciements
SELECT SUBSTRING(`date`, 6, 2) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `MONTH`
ORDER BY SUM(total_laid_off) DESC;

-- 7. Mois (année et mois) qui a eu le plus de licenciements
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY `MONTH` ASC;

-- 8. Accumulation des licenciements par mois
WITH Rolling_total AS (
    SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS total_off
    FROM layoffs_staging2
    WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
    GROUP BY `MONTH`
    ORDER BY `MONTH` ASC
)
SELECT `MONTH`, SUM(total_off) OVER (ORDER BY `MONTH`) AS rolling_total
FROM Rolling_total;

-- 9. Les compagnies qui ont eu le plus de licenciements par année
SELECT company, YEAR(`date`) AS years, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY SUM(total_laid_off) DESC;

-- 10. Classement annuel des entreprises ayant eu le plus de licenciements
WITH Company_Years AS (
    SELECT company, YEAR(`date`) AS years, SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY company, YEAR(`date`)
)
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Years
WHERE years IS NOT NULL
ORDER BY Ranking ASC;

-- 11. Classement des 5 premières entreprises ayant eu le plus de licenciements par année
WITH Company_Years AS (
    SELECT company, YEAR(`date`) AS years, SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY company, YEAR(`date`)
),
Company_Year_Rank AS (
    SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
    FROM Company_Years
    WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;

-- 12. Industrie ayant eu le plus de licenciements par année
SELECT industry, YEAR(`date`) AS years, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY industry, YEAR(`date`)
ORDER BY SUM(total_laid_off) DESC;

-- 13. Classement annuel des industries ayant eu le plus de licenciements
WITH industry_years AS (
    SELECT industry, YEAR(`date`) AS years, SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    WHERE total_laid_off IS NOT NULL
    GROUP BY industry, YEAR(`date`)
)
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM industry_years
WHERE years IS NOT NULL
ORDER BY Ranking ASC;

-- 14. Classement des 5 premières industries ayant eu le plus de licenciements par année
WITH industry_years AS (
    SELECT industry, YEAR(`date`) AS years, SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    WHERE total_laid_off IS NOT NULL
    GROUP BY industry, YEAR(`date`)
),
industry_rank AS (
    SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
    FROM industry_years
    WHERE years IS NOT NULL
)
SELECT *
FROM industry_rank
WHERE Ranking <= 5;

-- 15. Les 10 premières localisations ayant eu le plus de licenciements
SELECT location, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY location
ORDER BY SUM(total_laid_off) DESC
LIMIT 10;

-- 16. Les pays ayant eu le plus de licenciements
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY SUM(total_laid_off) DESC;
