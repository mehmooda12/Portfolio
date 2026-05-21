--Cleaning data using SQL
SELECT * FROM NashvilleHousing



--standardize Date Format
ALTER TABLE NashvilleHousing
ADD SalesDateConverted date;

UPDATE NashvilleHousing
SET SalesDateConverted=CONVERT(Date,SaleDate)

Select SalesDateConverted,SaleDate FROM NashvilleHousing




---populate property address data
SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) FROM 
NashvilleHousing a JOIN NashvilleHousing b
ON a.ParcelID =b.ParcelID
AND a.[UniqueID ] <>b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a 
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress) FROM 
NashvilleHousing a JOIN NashvilleHousing b
ON a.ParcelID =b.ParcelID
AND a.[UniqueID ] <>b.[UniqueID ]
where a.PropertyAddress is null



---breaking out Address info into individual columns
SELECT PropertyAddress FROM NashvilleHousing
SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address FROM NashvilleHousing
SELECT SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress) )FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress= SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity= SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress) )

SELECT * FROM NashvilleHousing
SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
 PARSENAME(REPLACE(OwnerAddress,',','.'),2),
 PARSENAME(REPLACE(OwnerAddress,',','.'),1)
 FROM NashvilleHousing

 
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--change Y and N to Yes or No in 'sold as vacant' column
SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant;



SELECT CASE
WHEN SoldAsVacant='Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No'
ELSE SoldAsVacant
END
FROM NashvilleHousing 
UPDATE NashvilleHousing 
SET SoldAsVacant=CASE
WHEN SoldAsVacant='Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No'
ELSE SoldAsVacant
END


---	Remove Duplicates
WITH RowNumCTE AS(
SELECT *,ROW_NUMBER() OVER(
PARTITION BY
ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference order by 
UniqueID
) row_num FROM NashvilleHousing)

DELETE FROM RowNumCTE WHERE row_num>1



--DELETE unused columns
SELECT * FROM NashvilleHousing;
Alter table NashvilleHousing 
drop column TaxDistrict,PropertyAddress,OwnerAddress,SaleDate;
