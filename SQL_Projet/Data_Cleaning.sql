-- Data Cleaning 

-- 1. Supprimer les doublons
-- 2. Standardiser les données
-- 3. Gérer les valeurs nulles ou vides
-- 4. Supprimer les colonnes non nécessaires

-- Étape 1 : Créer une table de staging
SELECT *
FROM layoffs;

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs; 

-- Étape 2 : Identifier les doublons
SELECT *, 
row_number() OVER (PARTITION BY company, location, industry, total_laid_off,
                   percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging;

WITH duplicate_cte AS (
    SELECT *, 
    row_number() OVER (PARTITION BY company, location, industry, total_laid_off,
                       percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte 
WHERE row_num > 1;

-- Étape 3 : Créer une nouvelle table de staging sans doublons
CREATE TABLE layoffs_staging2 (
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
row_number() OVER (PARTITION BY company, location, industry, total_laid_off,
                   percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging;

-- Supprimer les doublons
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2
ORDER BY company;

-- Étape 4 : Standardisation des données
-- Supprimer les espaces en trop dans la colonne company
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Uniformiser les valeurs de la colonne industry
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Supprimer les points à la fin des noms de pays
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Formatage de la colonne date
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Étape 5 : Gestion des valeurs nulles ou vides
-- Vérifier les colonnes avec des valeurs nulles
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = ''; 

-- Rechercher les valeurs vides dans la colonne industry
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
   AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Mise à jour de la colonne industry avec les valeurs nulles
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry 
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Changer les valeurs vides en null
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Vérifier les changements de la colonne industry
SELECT * 
FROM layoffs_staging2;

-- Suppression des données inutiles
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Supprimer la colonne row_num ajoutée au début
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
