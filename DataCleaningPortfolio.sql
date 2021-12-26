--Cleaning Data in SQL

Select *
From PortfolioProject..Housing

--1.Standardize Date Format
Select 
	SaleDate, Convert(Date,SaleDate)
From PortfolioProject..Housing

Update PortfolioProject..Housing 
Set SaleDate = Convert(Date,SaleDate)

	--Create new column for formatted date
Alter table Housing
Add Formated_SaleDate Date
	--Add the formatted date to the added column
Update PortfolioProject..Housing 
Set Formated_SaleDate = Convert(Date,SaleDate)

--2. Check if the UniqueID column is actually unique

Select	
	[UniqueID ],
	Count([UniqueID ])
From 
	PortfolioProject..Housing
Group by [UniqueID ]
Having Count([UniqueID ]) > 2
--> There is no dublicate values

--3. Some values of PropertyAddress is missing which need populating

Select *
From PortfolioProject..Housing
--Where PropertyAddress is Null
Order by ParcelID

Select 
	a.ParcelID, 
	a.PropertyAddress, 
	b.ParcelID, 
	b.PropertyAddress,
	ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..Housing a
Join PortfolioProject..Housing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..Housing a
Join PortfolioProject..Housing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null


--4. Break out PropertyAddress into seperate columns (Address, City, State)

Select PropertyAddress
From PortfolioProject..Housing
--Where PropertyAddress is Null

Select 
	SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1) as Address,
	SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1,len(PropertyAddress)) as City
From PortfolioProject..Housing

Alter table Housing
Add PropertySplitAddress Nvarchar(100)

Update PortfolioProject..Housing 
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1) 

Alter table Housing
Add PropertySplitCity Nvarchar(100)

Update PortfolioProject..Housing 
Set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1,len(PropertyAddress))

--5. Break out OwnerAddress into seperate columns (Address, City, State) using other function

Select OwnerAddress
From PortfolioProject..Housing

Select 
	PARSENAME(Replace(OwnerAddress,',','.'),3),
	PARSENAME(Replace(OwnerAddress,',','.'),2),
	PARSENAME(Replace(OwnerAddress,',','.'),1)
From PortfolioProject..Housing
	

Alter table Housing
Add OwnerSplitAddress Nvarchar(100)

Update PortfolioProject..Housing 
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter table Housing
Add OwnerSplitCity Nvarchar(100)

Update PortfolioProject..Housing 
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter table Housing
Add OwnerSplitState Nvarchar(100)

Update PortfolioProject..Housing 
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

--6. Change Y and N to Yes and No in 'SoldAsVacant' column

Select Distinct SoldAsVacant
From PortfolioProject..Housing

Select 
	SoldAsVacant,
	Case when SoldAsVacant = 'Y' Then 'Yes'
		 when SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant End
From PortfolioProject..Housing

Update PortfolioProject..Housing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
		 when SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant End

--7. Remove Duplicates
With RowNumCTE as (
Select *,
	Row_Number() Over(
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID) row_num
From PortfolioProject..Housing )
Delete 
From RowNumCTE
Where row_num > 1

--8. Remove Unused Columns

Select *
From PortfolioProject..Housing

Alter Table PortfolioProject..Housing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject..Housing
Drop Column SaleDate