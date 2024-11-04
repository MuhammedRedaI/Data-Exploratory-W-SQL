-- creating a branch from the original table to avoid mistakes
CREATE TABLE layoffs_staging
LIKE layoffs;

insert layoffs_staging
SELECT *
FROM layoffs;

-- dermining the duplicates from the table by giving 'row_num  = 1' to unique rows and 'row_num = 2' to duplicated rows
WITH duplicate_cte AS
(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date , stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)

-- selecting duplicated values
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;

-- creating another table with the content of the CTE to be able to modify and update it 
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *, 
-- ROW_NUMBER(): Generates a unique number for each row within a partition, starting from 1
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date , stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- deleting duplicated Rows
DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging2;

-- standardizing the data

-- removing unwanted spaces
SELECT DISTINCT(TRIM(company)) 
FROM layoffs_staging2;

-- updating the table
UPDATE layoffs_staging2
SET company = TRIM(company);

-- changing 'Crypto Currency' to 'Crypto' 
SELECT DISTINCT industry
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


-- changing 'United States.' to 'United States'
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

/*
this also works 
UPDATE layoffs_staging2
SET country = TRIM (TRAILING '.' FROM country)
WHERE country LIKE 'United States%' 
*/

SELECT date
FROM layoffs_staging2;

-- changing 'date' to a DATE column rather than TEXT
ALTER TABLE layoffs_staging2
MODIFY COLUMN date DATE;

-- cleaning/ populating if possible Nulls and blanks
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- converting blanks to Nulls for easier population
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- trying to figuring out missing industry
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL  
AND t2.industry IS NOT NULL;

-- populating NULL values with its approximated values

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL  
AND t2.industry IS NOT NULL;

-- deleting completely blank thus useless rows

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- removing row_num col
SELECT * 
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
