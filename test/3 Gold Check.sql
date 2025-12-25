--To check Duplicates
select cst_id, count(*) from(
	select 
		ci.cst_id,
		ci.cst_key,
		ci.cst_firstname,
		ci.cst_lastname,
		ci.cst_marital_status,
		ci.cst_gndr,
		ci.cst_create_date,
		ca.bdate,
		ca.gen,
		la.cntry
	from silver.crm_cust_info ci
	left join silver.erp_cust_az12 ca
	on		ci.cst_key=ca.cid
	left join silver.erp_loc_a101 la
	on		ci.cst_key=la.cid
)t group by cst_id
having count(*)>1;

-- To check Data Integrity
select distinct
	ci.cst_gndr,
	ca.gen,
	case when ci.cst_gndr !='n/a' then ci.cst_gndr --CRM is the Master for gender Info
		else coalesce(ca.gen, 'n/a')
	end as new_gen
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on		ci.cst_key=ca.cid
left join silver.erp_loc_a101 la
on		ci.cst_key=la.cid
order by 1,2

-- Check View
Select * from gold.dim_customers;

-- Check Product
Select
pn.prd_id,
pn.cat_id,
pn.prd_key,
pn.prd_nm,
pn.prd_cost,
pn.prd_line,
pn.prd_start_dt,
pn.prd_end_dt
from silver.crm_prd_info pn
where prd_end_dt is Null --Filter Out all historica data;


Select
	pn.prd_id as product_id,
	pn.prd_key,
	pn.prd_nm as product_name,
	pn.cat_id as category_id,
	pc.cat as category,
	pc.subcat as subcategory,
	pc.maintenance,
	pn.prd_cost as codt,
	pn.prd_line as product_line,
	pn.prd_start_dt as start_date
from silver.crm_prd_info pn
Left join silver.erp_px_cat_g1v2 pc
on pn.cat_id=pc.id
where prd_end_dt is NULL --Filter out all historical data


Select * from gold.dim_products;

-- Sales Fact Check
Select * 
from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
left join gold.dim_products p
on p.product_key=f.product_key
where c.customer_key is NULL


Select * 
from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
left join gold.dim_products p
on p.product_key=f.product_key
where f.product_key is NUll