-- DATA CLEANING --
SELECT * 
FROM layoffs;

-- REMOVE DUPLICATES--
-- STANDARIZE THE DATA--
-- REMOVE NULLS OR BLANKS--
-- REMOVE ANY UNNECESSARY COLUMNS--


CREATE TABLE layoffs_stagging
LIKE layoffs;

SELECT *
FROM layoffs_stagging;


INSERT layoffs_stagging
SELECT * 
FROM layoffs;

SELECT *,
row_number() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS number_id
FROM layoffs_stagging;

WITH DUPLICATE_CTE AS
 (
SELECT *,
row_number() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS number_id
FROM layoffs_stagging
)
SELECT *
FROM DUPLICATE_CTE
WHERE number_id > 1;


SELECT * 
FROM layoffs_stagging
WHERE company = 'Casper';



CREATE TABLE `layoffs_stagging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL, 
  `number_id` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT *
FROM layoffs_stagging2;


INSERT INTO layoffs_stagging2
SELECT *,
row_number() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS number_id
FROM layoffs_stagging;


-- making sure what our selection is before deleting the duplicates--
SELECT *
FROM layoffs_stagging2
WHERE number_id > 1;

//REMOVING SAFE UPDATE MODE//
SET SQL_SAFE_UPDATES = 0;

-- DELETING DUPLICATES--

DELETE 
FROM layoffs_stagging2
WHERE number_id > 1;



-- Checking to ensure rowa where deleted -- 

SELECT *
FROM layoffs_stagging2
WHERE number_id > 1;

-- Standarizing 'data'
SELECT DISTINCT TRIM(company)
FROM layoffs_stagging2;

SELECT trim(company), company
from layoffs_stagging2;
-- Update company column to remove spaces using trim
update layoffs_stagging2
set company = trim(company);

SELECT *
FROM layoffs_stagging2
WHERE industry like 'crypto%';

-- update industry column as we found crypto had different variants and typos but belong to the same category

update layoffs_stagging2
set industry = 'crypto'
where industry like 'crypto%';

-- verify update was done correctly
SELECT distinct industry
FROM layoffs_stagging2;


-- United stated appears to be twice due to a trailing .
SELECT DISTINCT country
FROM layoffs_stagging2
WHERE country like 'United States%';
-- we need to standarize this to avoid duplicated

update layoffs_stagging2
set country = 'United States'
where country like 'United States%';
-- now lets look at the date column so we can change its data type to date format 

describe layoffs_stagging2;

SELECT `date`, 
str_to_date(`date`, '%m/%d/%Y') new_date
FROM layoffs_stagging2;

-- now lets update our table with new date format 
UPDATE layoffs_stagging2
SET `date` = str_to_date(`date`, '%m/%d/%Y') 

-- VERIFY RESULTS
SELECT *
FROM layoffs_stagging2;
-- ALTER TABLE TO CHANGE DATA TYPE FROM TEXT TO DATE--

ALTER TABLE layoffs_stagging2
MODIFY COLUMN `date` DATE;

-- CHECK FOR NULLS IN INDUSTRY 
SELECT *
FROM layoffs_stagging2
WHERE industry is null or industry = '';

-- airbnb, Bally's Interactive, Carvana,Juul all show null industries
SELECT *
FROM layoffs_stagging2
WHERE company = 'Airbnb';

-- determined that airbnb has another row where insutry is travel, so we need to replace null for travel 
SELECT *
FROM layoffs_stagging2 t1
join layoffs_stagging2 t2 
	on t1.company = t2.company
WHERE 	t1.industry is null 
and t2.industry is not null;

-- we need to set '' to null 
update layoffs_stagging2 
set industry = null
where industry = '';

-- '' have been replaced by nulls, now lets update the table 
update layoffs_stagging2 t1
join layoffs_stagging2  t2 
	on t1.company = t2.company
set t1.industry = t2.industry
WHERE t1.industry is null 
and t2.industry is not null;
-- check update 
SELECT *
FROM layoffs_stagging2
WHERE company = 'Airbnb'; -- updated complete

-- check for nulls in total_laid_off and percetage_laid_off and if both are null then delete 

select *
FROM layoffs_stagging2
Where total_laid_off is null and percentage_laid_off is null;

-- NOW DELET
Delete 
FROM layoffs_stagging2
Where total_laid_off is null and percentage_laid_off is null;

-- finally lets drop number_id as is no longer needed 

ALTER TABLE layoffs_stagging2
DROP column number_id;
