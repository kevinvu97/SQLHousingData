SELECT * 
FROM [Project Portfolio].dbo.[Housing Data]


---- Standardize Sale Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM [Project Portfolio].dbo.[Housing Data]

Update [Housing Data]
SET SaleDate=CONVERT(Date, SaleDate)

---- Populate missing Property Address based on Parcel ID

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Project Portfolio].dbo.[Housing Data] a
JOIN [Project Portfolio].dbo.[Housing Data] b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null


---- Breaking the Property Address into seperate data fields

ALTER TABLE [Housing Data]
ADD PropertyAddressSplit Nvarchar(255);
UPDATE [Housing Data]
SET PropertyAddressSplit=SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE [Housing Data]
ADD PropertyAddressCity Nvarchar(255);
UPDATE [Housing Data]
SET PropertyAddressCity=SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


---- Normalize SoldAsVacant from Y/N to Yes/No

UPDATE [Housing Data]
SET SoldAsVacant=
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	WHEN SoldAsVacant='N' THEN 'No'
	ELSE SoldAsVacant
	END


---- Remove Duplicates
WITH RowNumCTE AS(
SELECT*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				ParcelID) row_num
FROM [Project Portfolio].dbo.[Housing Data])

DELETE
from RowNumCTE
WHERE row_num>1


---- Delete unused columns

ALTER TABLE [Project Portfolio].dbo.[Housing Data]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress