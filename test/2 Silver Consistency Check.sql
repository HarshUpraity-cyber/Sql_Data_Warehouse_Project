 --1. CRM_cust_info
 --Check for Nulls or Duplicates in Primary Key
 --Expectation: No Result
 Select cst_id, count(*) 
 from silver.crm_cust_info 
 group by cst_id having count(*)>1 or cst_id is NULL;

 --Check for unwanted spaces
 --Expectation: No Results
 select cst_firstname
 from silver.crm_cust_info
 where cst_firstname != TRIM(cst_firstname)

 select cst_lastname
 from silver.crm_cust_info
 where cst_lastname != TRIM(cst_lastname)

 select cst_gndr
 from silver.crm_cust_info
 where cst_gndr != TRIM(cst_gndr)

 --Data Standardization & Consistency
 select distinct cst_gndr
 from silver.crm_cust_info;

 select distinct cst_marital_status
 from silver.crm_cust_info;


 --2. CRM_prd_info
  --Check for Nulls or Duplicates in Primary Key
  --Expectation: No Result
  Select prd_cost from silver.crm_prd_info
  where prd_cost<0 or prd_cost is null

  --Data Standardization & Consistency
  Select Distinct prd_line from silver.crm_prd_info

  --Check for Invalid Data Orders
  Select * from silver.crm_prd_info
  where prd_end_dt < prd_start_dt



--3. CRM_sales_details

select * from silver.crm_sales_details
 where sls_order_dt> sls_ship_dt or sls_order_dt>sls_due_dt

 
 --check data consistency: between sales, quantity, and price
 -- >> Sales = Quantity * Price
 -- >> Values must not be Null, zero or negative
 select sls_sales,
 sls_quantity, sls_price from silver.crm_sales_details
 where sls_sales != sls_quantity * sls_price
 or sls_sales is null or sls_quantity is null or sls_price is null
 or sls_sales <=0 or sls_quantity <=0 or sls_price<=0
 order by sls_sales, sls_quantity, sls_price


 --4. ERP_cust_az12
 --Identify out-of-range dates
 select distinct bdate from silver.erp_cust_az12
 where bdate<'1924-01-01' or bdate>getDATE();

 -- Data Standardization & Consistency
 select distinct gen
 from silver.erp_cust_az12;


 --5. ERP_loc_a101
 --Data Standardization & Consistency
 Select Distinct cntry 
 from silver.erp_loc_a101
 order by cntry


--6.ERP_px_cat_g1v2
select * from silver.erp_px_cat_g1v2;