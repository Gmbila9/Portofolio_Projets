
-- Créer la table 
CREATE TABLE Nashville_Housing_Data(
	UniqueID NUMERIC,
	ParcelID VARCHAR(255),
	LandUse VARCHAR(255),
	PropertyAddress VARCHAR(255),
	SaleDate DATE,
	SalePrice NUMERIC,
	LegalReference VARCHAR(255),
	SoldAsVacant VARCHAR(255),
	OwnerName VARCHAR(255),
	OwnerAddress VARCHAR(255),
	Acreage NUMERIC,
	TaxDistrict VARCHAR(255),
	LandValue NUMERIC,
	BuildingValue NUMERIC,
	TotalValue NUMERIC,
	YearBuilt NUMERIC,
	Bedrooms NUMERIC,
	FullBath NUMERIC,
	HalfBath NUMERIC
)



-- Remplir les cellules NULL des property adress avec les adress existantes mais 
-- Unique id différent

SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, COALESCE(a.propertyaddress,b.propertyaddress)
FROM nashville_housing_data a
JOIN nashville_housing_data b
ON a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress is null

UPDATE nashville_housing_data a
SET propertyaddress = COALESCE(a.propertyaddress, b.propertyaddress)
FROM nashville_housing_data b
WHERE a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
AND a.propertyaddress IS NULL;




-- Séparer l'adresse en chiffre, lieu et ville 
-- Méthode 1 (SUBSTRING)
SELECT *
FROM nashville_housing_data

SELECT
SUBSTRING (propertyaddress, 1, POSITION(',' IN propertyaddress) -1) as Address,
SUBSTRING (propertyaddress, POSITION(',' IN propertyaddress) +1, LENGTH(propertyaddress))as Address
FROM nashville_housing_data

ALTER TABLE nashville_housing_data
ADD Propertysplitadress VARCHAR(255)

ALTER TABLE nashville_housing_data
ADD PropertyCityadress VARCHAR(255)

UPDATE nashville_housing_data
SET Propertysplitadress = SUBSTRING (propertyaddress, 1, POSITION(',' IN propertyaddress) -1)

UPDATE nashville_housing_data
SET PropertyCityadress = SUBSTRING (propertyaddress, POSITION(',' IN propertyaddress) +1, LENGTH(propertyaddress))

-- Méthode 2 (SPLIT_PART)

SELECT owneraddress
FROM nashville_housing_data

SELECT 
SPLIT_PART(owneraddress, ',',1) AS ownersplitaddress,
SPLIT_PART(owneraddress, ',',2) as ownercity,
SPLIT_PART(owneraddress, ',',3) as ownerstate
FROM nashville_housing_data

ALTER TABLE nashville_housing_data
ADD ownersplitaddress VARCHAR(255)

ALTER TABLE nashville_housing_data
ADD ownercity VARCHAR(255)

ALTER TABLE nashville_housing_data
ADD ownerstate VARCHAR(255)

UPDATE nashville_housing_data
SET ownersplitaddress = SPLIT_PART(owneraddress, ',',1)

UPDATE nashville_housing_data
SET ownercity = SPLIT_PART(owneraddress, ',',2)

UPDATE nashville_housing_data
SET ownerstate = SPLIT_PART(owneraddress, ',',3)

SELECT *
FROM nashville_housing_data

-- changer les Y et N en Yes et No dans soldasvacant

SELECT DISTINCT soldasvacant, COUNT(soldasvacant)
FROM nashville_housing_data
GROUP BY soldasvacant
ORDER BY COUNT(soldasvacant)

SELECT soldasvacant,
CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	WHEN soldasvacant = 'N' THEN 'No'
	ELSE soldasvacant
	END
FROM nashville_housing_data

UPDATE nashville_housing_data
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	WHEN soldasvacant = 'N' THEN 'No'
	ELSE soldasvacant
	END

-- Retirer les doublons 
-- compter le nombre de ligne identiques en fonction des critères dans la fonction PARTITION BY
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference
		ORDER BY uniqueid
	) as row_num
FROM nashville_housing_data
ORDER BY parcelid

-- utiliser un CTE pour faire des requetes dans la requete précedente, pour ressortir 
-- les row_num > 1 et les supprimer 
WITH RowNUMCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference
		ORDER BY uniqueid
	) as row_num
FROM nashville_housing_data
--ORDER BY parcelid
)
SELECT *
FROM RowNUMCTE
WHERE row_num > 1


WITH RowNUMCTE AS (
    SELECT uniqueid
    FROM (
        SELECT uniqueid,
               ROW_NUMBER() OVER(
                   PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference
                   ORDER BY uniqueid
               ) as row_num
        FROM nashville_housing_data
    ) subquery
    WHERE row_num > 1
)
DELETE FROM nashville_housing_data
WHERE uniqueid IN (SELECT uniqueid FROM RowNUMCTE);

-- Supprimer les colonnes qui ne servent à rien 
SELECT*
FROM nashville_housing_data

ALTER TABLE nashville_housing_data
DROP COLUMN propertyaddress,
DROP COLUMN taxdistrict,
DROP COLUMN owneraddress;

