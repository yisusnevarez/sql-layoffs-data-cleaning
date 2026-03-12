# sql-layoffs-data-cleaning
SQL data cleaning project where a global layoffs dataset was cleaned and standardized using window functions, CTEs, and data transformation techniques.

SQL Data Cleaning Project – Layoffs Dataset
Project Overview

This project focuses on cleaning and preparing a raw layoffs dataset for analysis using SQL.
The objective was to transform messy data into a structured and analysis-ready dataset.

Dataset

Global layoffs dataset containing information about:

company

location

industry

layoffs

funding stage

date

funds raised

Data Cleaning Steps
1. Created Staging Tables

A staging table was created to preserve the original dataset and perform cleaning operations safely.

2. Removed Duplicate Records

Duplicates were identified using a ROW_NUMBER() window function and removed.

Example:

ROW_NUMBER() OVER(
PARTITION BY company, location, industry,
total_laid_off, percentage_laid_off, date,
stage, country, funds_raised_millions
)
3. Standardized Text Fields

Standardized company names and industry values.

Examples:

Removed trailing spaces using TRIM()

Standardized industry values such as crypto variants

Corrected country inconsistencies such as United States.

4. Converted Date Format

Converted the date column from text format into a proper SQL DATE datatype.

Example:

STR_TO_DATE(date,'%m/%d/%Y')
5. Handled Missing Values

Replaced blank values with NULL

Used self joins to populate missing industry values where possible

Example:

UPDATE layoffs_stagging2 t1
JOIN layoffs_stagging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;
6. Removed Irrelevant Records

Rows where both total_laid_off and percentage_laid_off were NULL were removed.

Tools Used

SQL

Window Functions

CTEs

Data Cleaning Techniques

Final Result

The dataset was successfully transformed into a clean and structured dataset suitable for analysis.
