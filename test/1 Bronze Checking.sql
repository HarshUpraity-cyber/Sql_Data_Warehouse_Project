--1. crm_cust_info

 --Check for Nulls or Duplicates in Primary Key
 --Expectation: No Result
 Select cst_id, count(*) 
 from bronze.crm_cust_info 
 group by cst_id having count(*)>1 or cst_id is NULL;

 --Check for unwanted spaces
 --Expectation: No Results
 select cst_firstname
 from bronze.crm_cust_info
 where cst_firstname != TRIM(cst_firstname)

 select cst_lastname
 from bronze.crm_cust_info
 where cst_lastname != TRIM(cst_lastname)

 select cst_gndr
 from bronze.crm_cust_info
 where cst_gndr != TRIM(cst_gndr)

 --Data Standardization & Consistency
 select distinct cst_gndr
 from bronze.crm_cust_info;

 select distinct cst_marital_status
 from bronze.crm_cust_info;



--2. crm_prd_info
  
  --Check for Nulls or Duplicates in Primary Key
  --Expectation: No Result
  select prd_id, count(*) from bronze.crm_prd_info 
  group by prd_id having COUNT(*)>1 or prd_id is Null;

  -- check cat_id  which is not in erp_px_cat_g1v2
   select prd_id, prd_key,
  replace(substring(prd_key,1,5),'-','_') as cat_id, --from prd_key make the cat_id which is in erp_px_cat_g1v2
  prd_nm, prd_cost, prd_line,
  prd_start_dt, prd_end_dt
  from bronze.crm_prd_info
  where replace(substring(prd_key,1,5),'-','_') not in 
  (select distinct id from bronze.erp_px_cat_g1v2);
 
  -- check prd_key which is not in crm_sales_details 
  select prd_id, prd_key,
  replace(substring(prd_key,1,5),'-','_') as cat_id, --from prd_key make the cat_id which is in erp_px_cat_g1v2
  substring(prd_key,7,len(prd_key)) as prd_key, 
  prd_nm, prd_cost, prd_line,
  prd_start_dt, prd_end_dt
  from bronze.crm_prd_info
  where substring(prd_key,7,len(prd_key)) not in 
  (select sls_prd_key from bronze.crm_sales_details);

 --Check for unwanted spaces
 --Expectation: No Results
 select prd_nm from bronze.crm_prd_info
 where prd_nm!=trim(prd_nm)

 --check for nulls or negative numbers 
 --Expectation: No Results
 select prd_cost from bronze.crm_prd_info
 where prd_cost<0 or prd_cost is null;

 --Data Standardization & Consistency
 select distinct prd_line 
 from bronze.crm_prd_info;

 --check for Invalid Date Orders
 Select * from bronze.crm_prd_info
 where prd_end_dt< prd_start_dt



 --3. crm_sales_details

 select sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt,
 sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
 from bronze.crm_sales_details
 where sls_prd_key not in (select prd_key from silver.crm_prd_info);

 select sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt,
 sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
 from bronze.crm_sales_details
 where sls_cust_id not in (select cst_id from silver.crm_cust_info);

 --check for invalid dates
 select 
 nullif(sls_order_dt,0) as sls_order_dt
 from bronze.crm_sales_details
 where sls_order_dt<=0 
 or len(sls_order_dt)!=8 
 or sls_order_dt>20500101
 or sls_order_dt<19000101

 --check for invalid date orders
 select * from bronze.crm_sales_details
 where sls_order_dt> sls_ship_dt or sls_order_dt>sls_due_dt

 --check data consistency: between sales, quantity, and price
 -- >> Sales = Quantity * Price
 -- >> Values must not be Null, zero or negative
 select sls_sales,
 sls_quantity, sls_price from bronze.crm_sales_details
 where sls_sales != sls_quantity * sls_price
 or sls_sales is null or sls_quantity is null or sls_price is null
 or sls_sales <=0 or sls_quantity <=0 or sls_price<=0
 order by sls_sales, sls_quantity, sls_price



 --4. ERP_cust_az12

 select
 case when cid like 'NAS%' then substring(cid,4,len(cid))
	else cid
end as cid,
bdate,
gen
from bronze.erp_cust_az12
where  case when cid like 'NAS%' then substring(cid,4,len(cid))
	else cid
	end  not in (select distinct cst_key from silver.crm_cust_info);

--Identify out-of-range dates
 select distinct bdate from bronze.erp_cust_az12
 where bdate<'1924-01-01' or bdate>getDATE();

 -- Data Standardization & Consistency
 select distinct gen
 from bronze.erp_cust_az12;



 --5. ERP_loc_a101

 select cid,cntry
 from bronze.erp_loc_a101 where cid not in
 (select cst_key from silver.crm_cust_info)

 --Data Standardization & Consistency
 Select Distinct cntry 
 from bronze.erp_loc_a101
 order by cntry


 --6.ERP_px_cat_g1v2
 select * from 
 bronze.erp_px_cat_g1v2
 
 --check for unwanted spaces
 select * from bronze.erp_px_cat_g1v2
 where cat!= trim(cat) or subcat!= trim(subcat) or maintenance!=trim(maintenance);

 --Data Standardization & Consistency
 select distinct cat
 from bronze.erp_px_cat_g1v2

 select distinct subcat
 from bronze.erp_px_cat_g1v2

 select distinct maintenance
 from bronze.erp_px_cat_g1v2