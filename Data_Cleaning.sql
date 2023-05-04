/*

Cleaning Data in SQL Queries
*/

select * 
from portfolio..NashvilleHousingData

---------------------------------------------------------------------------

-- Standardize Date Format

select SaleDate, Convert(Date, SaleDate)
from portfolio..NashvilleHousingData

ALTER TABLE NashvilleHousingData ALTER COLUMN SaleDate Date


-----------------------------------------------------------------------------

-- Populate Property Address data

select * 
from portfolio..NashvilleHousingData
-- where PropertyAddress is not null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from portfolio..NashvilleHousingData a
join portfolio.. NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
-- where a.PropertyAddress is null
order by 1
	 
Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from portfolio..NashvilleHousingData a
join portfolio.. NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

---------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress	
from portfolio..NashvilleHousingData

 

ALter TAble NashvilleHousingData
Add PropertySplitAddress nvarchar(255);

Update portfolio..NashvilleHousingData
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

Alter Table NashvilleHousingData
Add PropertySplitCity nvarchar(255);

Update portfolio..NashvilleHousingData
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

Select *
from portfolio..NashvilleHousingData

-- For Owner Address

select OwnerAddress
from portfolio..NashvilleHousingData

Select 
PARSENAME(replace(OwnerAddress, ',' , '.'),3), 
PARSENAME(replace(OwnerAddress, ',' , '.'),2),
PARSENAME(replace(OwnerAddress, ',' , '.'),1)
from portfolio..NashvilleHousingData


Alter Table portfolio..NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255);

update portfolio..NashvilleHousingData
Set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',' , '.'),3)

Alter Table portfolio..NashvilleHousingData
Add OwnerSplitCity Nvarchar(255);

Update portfolio..NashvilleHousingData
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',' , '.'),2)

Alter Table portfolio..NashvilleHousingData
add OwnerSplitState Nvarchar(255);

Update portfolio..NashvilleHousingData
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',' , '.'),1)



----------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from portfolio..NashvilleHousingData
group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case when SoldAsVacant = 'Y' THEN 'Yes'
     when SoldAsVacant = 'N' Then 'No'
	 else SoldAsVacant
	 end
from portfolio..NashvilleHousingData

update portfolio..NashvilleHousingData

set SoldAsVacant = Case when SoldAsVacant = 'Y' THEN 'Yes'
						when SoldAsVacant = 'N' Then 'No'
						else SoldAsVacant
						end



---------------------------------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE as (
select *,
	ROW_NUMBER() Over ( 
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) row_num
					
from portfolio..NashvilleHousingData
--Order by ParcelID
)

select * from RowNumCTE
where row_num > 1


-------------------------------------------------------------------------------------------------------

-- Removing Unused Columns

select *
from portfolio..NashvilleHousingData

Alter Table portfolio.. NashvilleHousingData
Drop Column OwnerAddress, TaxDistrict, PropertyAddress


Alter Table portfolio.. NashvilleHousingData
Drop Column SaleDate