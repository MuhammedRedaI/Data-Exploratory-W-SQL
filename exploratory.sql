SELECT *
FROM layoffs_staging2;

SELECT MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP by company
ORDER BY 2 DESC;

SELECT MIN(date), MAX(date)
FROM layoffs_staging2;

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP by industry
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP by country
ORDER BY 2 DESC;

SELECT YEAR(date), SUM(total_laid_off)
FROM layoffs_staging2
GROUP by YEAR(date)
ORDER BY 1 DESC;

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP by stage
ORDER BY 2 DESC;

SElECT SUBSTRING(date, 1,7) AS `month` , SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(date, 1,7) iS NOT NULL
GROUP BY `month`
ORDER BY `month`;

WITH Rolling_Total AS
(
SElECT SUBSTRING(date, 1,7) AS `month` , SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(date, 1,7) iS NOT NULL
GROUP BY `month`
ORDER BY `month`
)
 SELECT `month` ,total_off,  SUM(total_off) OVER(ORDER BY `month`) AS rolling_total
 FROM Rolling_Total;
 
 SELECT company , YEAR(`date`) AS year, SUM(total_laid_off) AS total_laid_off
 FROM layoffs_staging2
 GROUP BY company , year
 ORDER BY 3 DESC;
 
 WITH company_years AS
 (
 SELECT company , YEAR(`date`) AS year, SUM(total_laid_off) AS total_laid_off
 FROM layoffs_staging2
 GROUP BY company , year
 ), company_years_ranks AS (
 SELECT *, dense_rank() OVER(PARTITION BY `year` ORDER BY total_laid_off DESC)  AS Ranks
 FROM company_years
 WHERE year IS NOT NULL
 )
 SELECT *
 FROM company_years_ranks
 WHERE Ranks <= 5;