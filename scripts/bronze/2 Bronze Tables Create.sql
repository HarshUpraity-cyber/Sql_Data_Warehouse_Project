IF OBJECT_ID ('bronze.crm_cust_info', 'U') IS NOT NULL
	Drop Table bronze.crm_cust_info;
Create Table bronze.crm_cust_info(
	cst_id INT,
	cst_key NVarchar(50),
	cst_firstname NVarchar(50),
	cst_lastname NVarchar(50),
	cst_marital_status NVarchar(50),
	cst_gndr NVarchar(50),
	cst_create_date Date
);

IF OBJECT_ID ('bronze.crm_prd_info', 'U') IS NOT NULL
	Drop Table bronze.crm_prd_info;
Create Table bronze.crm_prd_info(
	prd_id Int,
	prd_key NVarchar(50),
	prd_nm NVarchar(50),
	prd_cost Int,
	prd_line NVarchar(50),
	prd_start_dt DateTime,
	prd_end_dt DateTime
);

IF OBJECT_ID ('bronze.crm_sales_details', 'U') IS NOT NULL
	Drop Table bronze.crm_sales_details;
Create Table bronze.crm_sales_details(
	sls_ord_num NVarchar(50),
	sls_prd_key NVarchar(50),
	sls_cust_id Int,
	sls_order_dt Int,
	sls_ship_dt Int,
	sls_due_dt Int,
	sls_sales Int,
	sls_quantity Int,
	sls_price NVarchar(50)
);

IF OBJECT_ID ('bronze.erp_loc_a101', 'U') IS NOT NULL
	Drop Table bronze.erp_loc_a101;
Create Table bronze.erp_loc_a101 (
	cid NVarchar(50),
	cntry NVarchar(50)
);

IF OBJECT_ID ('bronze.erp_cust_az12', 'U') IS NOT NULL
	Drop Table bronze.erp_cust_az12;
Create Table bronze.erp_cust_az12 (
	cid NVarchar(50),
	bdate Date,
	gen NVarchar(50)
);

IF OBJECT_ID ('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
	Drop Table bronze.erp_px_cat_g1v2;
Create Table bronze.erp_px_cat_g1v2 (
	id NVarchar(50),
	cat NVarchar(50),
	subcat NVarchar(50),
	maintenance NVarchar(50)
);