--Cleaning Data in SQL Queries

Select*
From PortfolioProject..NashvilleHousing

--Standardize Date Format

Select SaleDateConverted, 
CONVERT (Date,SaleDate)
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate);

ALTER TABLE PortfolioProject..NashvilleHousing
add SaleDateConverted Date;

Update PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT (Date,SaleDate)

Select*
From PortfolioProject..NashvilleHousing

-- Populate Property Address data

Select*
From PortfolioProject..NashvilleHousing
Order by ParcelID

--where property address is null bring propertyAddress b

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress,b.PropertyAddress) 
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]  <> b.[UniqueID ]
Where a.PropertyAddress is null
--Order by ParcelID

Update a
SET PropertyAddress = ISNULL (a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]  <> b.[UniqueID ]
Where a.PropertyAddress is null

--Now, there is none that has null

--Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

--SUBSTRING and CHARINDEX - Will search for specific caracter, word

---Colum with Index position 

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
From PortfolioProject..NashvilleHousing

-- exclude ","  
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
From PortfolioProject..NashvilleHousing

-- exclude ","  and bring new column with number the position where comma is 

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
	CHARINDEX(',', PropertyAddress)
From PortfolioProject..NashvilleHousing

--Separate "," and all after what is City and show it in a different column name Address
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN (PropertyAddress)) as Address

From PortfolioProject..NashvilleHousing

--We need to bring this to the table

ALTER TABLE PortfolioProject..NashvilleHousing
add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject..NashvilleHousing
add PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN (PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing

Select OwnerAddress
From PortfolioProject..NashvilleHousing

--Need to split OwnerAddress -we need again split  ",", city and state from address but we will not use SUBSTRING now

--PARSENAME
--Just  TN -State 
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing 

--All  Address / City / State

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject..NashvilleHousing 

ALTER TABLE PortfolioProject..NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE PortfolioProject..NashvilleHousing
add OwnerSplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE PortfolioProject..NashvilleHousing
add OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From PortfolioProject..NashvilleHousing

--Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant)
From PortfolioProject..NashvilleHousing

Select Distinct(SoldAsVacant), Count (SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

-- We have Y, N, Yes, No -- Need to change Y and N to Yes and No to have all the same 

Select SoldAsVacant, 
CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END
From PortfolioProject..NashvilleHousing

--NOW UPDATE this change 

Update PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END
From PortfolioProject..NashvilleHousing


--REMOVE DUPLICATES

--- Find duplicates 
Select *,
	ROW_NUMBER() over(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) Row_num
From PortfolioProject..NashvilleHousing
Order by ParcelID


---Sellect just duplicates 

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() over(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) Row_num
From PortfolioProject..NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
Where Row_num > 1
Order by PropertyAddress


--Delete all duplicates 

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() over(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) Row_num
From PortfolioProject..NashvilleHousing
--Order by ParcelID
)
DELETE
From RowNumCTE
Where Row_num > 1
--Order by PropertyAddress





--Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate
