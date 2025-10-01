/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'silver.crm_cust_info'
-- ====================================================================

-- check for nulls or duplicates in primary key
-- expectation: no result

select cst_id,
count(*)
from silver.crm_cust_info
group by cst_id
having count(*) > 1 or cst_id is null;

-- check for unwanted space
-- expectation: no result

select cst_firstname
from silver.crm_cust_info
where cst_firstname != trim(cst_firstname);

-- data standardization & consistency

select distinct cst_gndr
from silver.crm_cust_info;

select distinct cst_marital_status
from silver.crm_cust_info;


-- ====================================================================
-- Checking 'silver.crm_prd_info'
-- ====================================================================

-- check for nulls or duplicates in primary key
-- expectation: no result

select prd_id,
count(*)
from silver.crm_prod_info
group by prd_id
having count(*) > 1 or prd_id is null;

-- check for unwanted spaces
-- expectation: no results
select 
    prd_nm 
from silver.crm_prd_info
where prd_nm != TRIM(prd_nm);

-- check for nulls or negaive numbers
-- expectation: no results
select prd_nm
from silver.crm_prod_info
where prd_nm != trim(prd_nm);

-- check for nulls or negaive numbers
-- expectation: no results
select prd_cost
from silver.crm_prod_info
where prd_cost < 0 or prd_cost is null;

--data standardization and consistency
select distinct prd_line 
from silver.crm_prod_info;

-- check for invalid date orders
select *
from silver.crm_prod_info
where prd_end_dt < prd_start_dt;

-- ====================================================================
-- Checking 'silver.crm_sales_details'
-- ====================================================================

-- check for invalid dates
-- Expectation: No Invalid Dates
select nullif(sls_order_dt,0) sls_order_dt
from bronze.crm_sales_info
where sls_order_dt <= 0
or len(sls_order_dt) != 8
or sls_order_dt > 20500101
or sls_order_dt < 19000101
 
-- check for invalid date orders

select *
from silver.crm_sales_info
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt

-- check data consistencies between sales, quantity and price
-- >> sales = quantity * price
-- >> values  ust not be zero,null or negative
-- Expectation: No Results

select distinct
sls_sales as old_sls_sales,
sls_quantity,	
sls_price as old_sls_price,
case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs(sls_price)
	then sls_quantity * abs(sls_price)
	else sls_sales
end as sls_sales,
case when sls_price is null or sls_price <= 0 
	then sls_sales/nullif(sls_quantity,0)
	else sls_price
end as sls_price
from bronze.crm_sales_info
where sls_sales != sls_quantity * sls_price
or sls_sales is null or sls_quantity is null or sls_price is null
or sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0
order by sls_sales,sls_quantity,sls_price 

select distinct
sls_sales as old_sls_sales,
sls_quantity,	
sls_price as old_sls_price
from silver.crm_sales_info
where sls_sales != sls_quantity * sls_price
or sls_sales is null or sls_quantity is null or sls_price is null
or sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0
order by sls_sales,sls_quantity,sls_price 

select * from silver.crm_sales_info;

-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================

-- identify out of range dates

select distinct 
bdate 
from silver.erp_cust_az12
where bdate < '1924-01-01' or bdate < getdate();

-- date standardization & consistency

select distinct gen,
case when upper(trim(gen)) in ('F','FEMALE') then 'Female'
	 when upper(trim(gen)) in ('M','MALE') then 'Male'
	 else 'n/a'
end as gen
from silver.erp_cust_az12;

select * from silver.erp_cust_az12;

-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================

-- data standardization & consistency

select distinct cntry as old_cntry,
case when trim(cntry) = 'DE' then 'Germany'
	 when trim(cntry) in ('US','USA') then 'United States'
	 when trim(cntry) = '' or cntry is null then 'n/a'
	 else trim(cntry)
end as cntry
from silver. erp_loc_a101
order by cntry;

select * from silver.erp_loc_a101;

-- ====================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================

-- check for unwanted spaces

select * from bronze.erp_px_cat_g1v2
where cat != trim(cat) 
or subcat != trim(subcat)
or maintenance != trim(maintenance);

-- data standardization & consistency

select distinct cat
from bronze.erp_px_cat_g1v2;

select distinct subcat
from bronze.erp_px_cat_g1v2;

select distinct maintenance
from bronze.erp_px_cat_g1v2;

select * from silver.erp_px_cat_g1v2;

