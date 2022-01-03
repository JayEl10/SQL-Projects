/*
Cleaning Data in SQL Queries
*/


SELECT *
FROM ProjectsPortfolio..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM ProjectsPortfolio..NashvilleHousing

UPDATE ProjectsPortfolio..NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE	ProjectsPortfolio..NashvilleHousing
ADD SaleDateConverted Date

UPDATE ProjectsPortfolio..NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjectsPortfolio..NashvilleHousing a
JOIN ProjectsPortfolio..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjectsPortfolio..NashvilleHousing a
JOIN ProjectsPortfolio..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM ProjectsPortfolio..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM ProjectsPortfolio..NashvilleHousing

ALTER TABLE	ProjectsPortfolio..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE ProjectsPortfolio..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE	ProjectsPortfolio..NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE ProjectsPortfolio..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



SELECT *
FROM ProjectsPortfolio..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM ProjectsPortfolio..NashvilleHousing


ALTER TABLE	ProjectsPortfolio..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE ProjectsPortfolio..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE	ProjectsPortfolio..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE ProjectsPortfolio..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE	ProjectsPortfolio..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE ProjectsPortfolio..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
FROM ProjectsPortfolio..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM ProjectsPortfolio..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
	,CASE
		WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
	END
FROM ProjectsPortfolio..NashvilleHousing


UPDATE ProjectsPortfolio..NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS
	(
	SELECT *, ROW_NUMBER()
		OVER (PARTITION BY
			ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY UniqueID
			) row_num
	FROM ProjectsPortfolio..NashvilleHousing
	)
SELECT *
--DELETE
FROM RowNumCTE
WHERE row_num > 1


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM ProjectsPortfolio..NashvilleHousing

ALTER TABLE ProjectsPortfolio..NashvilleHousing
DROP COLUMN SaleDate, PropertyAddress, OwnerAddress
