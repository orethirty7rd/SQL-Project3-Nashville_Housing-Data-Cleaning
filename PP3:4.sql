SELECT *
FROM Portfolio_Project.Nashville_Housing;

-- Standardise sale date -- already converted
SELECT SaleDate
FROM Portfolio_Project.Nashville_Housing;

-- 2. Populate Property Address Data
SELECT*
FROM Portfolio_Project.Nashville_Housing
WHERE PropertyAddress IS NULL;
   
UPDATE Portfolio_Project.Nashville_Housing
SET PropertyAddress = NULL
WHERE PropertyAddress IS NULL 
   OR PropertyAddress = '';

SET SQL_SAFE_UPDATES = 0;

UPDATE Portfolio_Project.Nashville_Housing
SET 
    PropertyAddress = NULLIF(PropertyAddress, ''),
    OwnerName       = NULLIF(OwnerName, ''),
	OwnerAddress     = NULLIF(OwnerAddress, ''),
    TaxDistrict =  NULLIF(TaxDistrict, ''),
    LegalReference  = NULLIF(LegalReference, '');
    
SELECT *
FROM Portfolio_Project.Nashville_Housing
ORDER BY ParcelID;

-- null property address could be populated if we had a ref point, hence we look at parcelid
-- sometimes we see the same parcelid twice, with exact same address
-- Hence what we will do is take addresses from partcelids to populate emtpy property addresses

-- We have to do a self join to get  parrcelid=parcelid then propertyid = propertyid along w unique id
-- IFNULL(a.PropertyAddress, 'no addresss') as Cleaned_address)
SELECT a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio_Project.Nashville_Housing a
JOIN Portfolio_Project.	Nashville_Housing b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;


UPDATE Portfolio_Project.Nashville_Housing a
JOIN Portfolio_Project.Nashville_Housing b
    ON a.ParcelID = b.ParcelID
   AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

-- cross check
SELECT*
FROM Portfolio_Project.Nashville_Housing;

-- 3. Separating PropertyAddress into streets and cities
SELECT
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1)   AS City
FROM Portfolio_Project.Nashville_Housing;

-- we cant separate 2 values from one columns w/o adding 2 new columns

ALTER TABLE Portfolio_Project.Nashville_Housing
Add Street varchar(255);

ALTER TABLE Portfolio_Project.Nashville_Housing
Add City varchar(255);

UPDATE Portfolio_Project.Nashville_Housing
SET Street = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);

UPDATE Portfolio_Project.Nashville_Housing
SET City =  SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1);

ALTER TABLE Portfolio_Project.Nashville_Housing
MODIFY COLUMN Street varchar(255) AFTER PropertyAddress;
ALTER TABLE Portfolio_Project.Nashville_Housing
MODIFY COLUMN City varchar(255) AFTER Street;

ALTER TABLE Portfolio_Project.Nashville_Housing
RENAME COLUMN Street TO PropertyStreet;
ALTER TABLE Portfolio_Project.Nashville_Housing
RENAME COLUMN City TO PropertyCity;

-- 4. Now we move on to ownersAddress
SELECT OwnerAddress
FROM Portfolio_Project.Nashville_Housing;

-- PARSENAME DOESNT WORK ON MYSQL, STILL HAVE TO USE WHAT WE HAVE ABOVE, HOWEVER WE CAN DO A STORED FUNCTION
SELECT
  TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1)) AS Street,
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)) AS City,
  TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1)) AS State
FROM Portfolio_Project.Nashville_Housing;

ALTER TABLE Portfolio_Project.Nashville_Housing
Add OwnerStreet varchar(255);

ALTER TABLE Portfolio_Project.Nashville_Housing
Add OwnerCity varchar(255);

ALTER TABLE Portfolio_Project.Nashville_Housing
Add OwnerState varchar(255);

UPDATE Portfolio_Project.Nashville_Housing
SET OwnerStreet = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1));

UPDATE Portfolio_Project.Nashville_Housing
SET OwnerCity =  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1));

UPDATE Portfolio_Project.Nashville_Housing
SET OwnerState =  TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1));

SELECT *
FROM Portfolio_Project.Nashville_Housing;

ALTER TABLE Portfolio_Project.Nashville_Housing
MODIFY COLUMN OwnerStreet varchar(255) AFTER OwnerAddress;
ALTER TABLE Portfolio_Project.Nashville_Housing
MODIFY COLUMN OwnerCity varchar(255) AFTER OwnerStreet;
ALTER TABLE Portfolio_Project.Nashville_Housing
MODIFY COLUMN OwnerState varchar(255) AFTER OwnerCity;

-- 5. change Y and N to Yes and No
SELECT DISTINCT(SoldAsVacant)
FROM Portfolio_Project.Nashville_Housing;
-- find the one most used
SELECT SoldAsVacant, COUNT(*) AS CountVacant
FROM Portfolio_Project.Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY CountVacant;

-- we run case statements
SELECT SoldAsVacant,
       CASE 
           WHEN SoldAsVacant = 'Y' THEN 'Yes'
           WHEN SoldAsVacant = 'N' THEN 'No'
           ELSE SoldAsVacant
       END AS SoldAsVacant_Cleaned
FROM Portfolio_Project.Nashville_Housing;

UPDATE Portfolio_Project.Nashville_Housing
SET SoldAsVacant =  CASE 
           WHEN SoldAsVacant = 'Y' THEN 'Yes'
           WHEN SoldAsVacant = 'N' THEN 'No'
           ELSE SoldAsVacant
       END;

-- 6. Removing duplicates
-- Using a CTE



WITH RowNumCTE AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM Portfolio_Project.Nashville_Housing
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

WITH RowNumCTE AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM Portfolio_Project.Nashville_Housing
)
DELETE FROM Portfolio_Project.Nashville_Housing
WHERE UniqueID IN (
    SELECT UniqueID 
    FROM RowNumCTE
    WHERE row_num > 1
);


-- 7. Delete unused columns
ALTER TABLE Portfolio_Project.Nashville_Housing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;

SELECT *
FROM Portfolio_Project.Nashville_Housing;
