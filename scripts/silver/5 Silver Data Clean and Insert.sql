Create or alter procedure silver.load_silver AS
Begin
	Declare @start_time Datetime, @end_time Datetime, @batch_start_time Datetime, @batch_end_time Datetime;
	Begin Try
		SET @batch_start_time = GETDATE();
		Print '===============================================================';
		Print 'Loading Silver Layer';
		Print '===============================================================';
	
		Print '---------------------------------------------------------------';
		Print 'Loading CRM Tables';
		Print '---------------------------------------------------------------';

		--Loading CRM_cust_info
		SET @start_time=GETDATE()
		print '>> Truncating Table: silver.crm_cust_info';
		Truncate Table silver.crm_cust_info
		print '>> Inserting Data Into: silver.crm_cust_info';

		
		Insert into silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date)

		select cst_id, 
		cst_key,
		TRIM(cst_firstname) as cst_firstname,
		TRIM(cst_lastname) as cst_lastname,
		CASE When upper(trim(cst_marital_status))='S' Then 'Single'
			 When upper(trim(cst_marital_status))='M' Then 'Married'
			 Else 'N/A'
		END cst_marital_status,

		CASE When upper(trim(cst_gndr))='F' Then 'Female'
			 When upper(trim(cst_gndr))='M' Then 'Male'
			 Else 'N/A'
		END cst_gndr,

		cst_create_date
		from (
		select *,
		ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as flag_last
		from bronze.crm_cust_info
		where cst_id is not null
		)t where flag_last=1;

		SET @end_time=GETDATE();
		Print '>> Load Duration: ' + Cast(Datediff(second, @start_time, @end_time) as NVarchar) + ' seconds';
		Print '---------------------------------------------------------------------'


		--Loading CRM_prd_info
		SET @start_time=GETDATE()
		print '>> Truncating Table: silver.crm_prd_info';
		Truncate Table silver.crm_prd_info
		print '>> Inserting Data Into: silver.crm_prd_info';
		
		--create cat_id (erp_px_cat_g1v2) and prd_key (crm_sales_details) from prd_key 
		Insert into silver.crm_prd_info(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)

		  select prd_id,
		  replace(substring(prd_key,1,5),'-','_') as cat_id, --from prd_key make the cat_id which is in erp_px_cat_g1v2
		  substring(prd_key,7,len(prd_key)) as prd_key, --from prd_key make the prd_key which is in crm_sales_details
		  prd_nm, 
		  isnull(prd_cost,0),
		  case upper(trim(prd_line))
			  when 'M' then 'Mountain'
			  when 'R' then 'Road'
			  when 'S' then 'Other Sales'
			  when 'T' then 'Touring'
			  else 'N/A'
		  end as prd_line,
		  cast(prd_start_dt as date) as prd_start_dt, 
		  cast(lead(prd_end_dt) over (partition by prd_key order by prd_start_dt) -1 as date)as prd_end_dt
		  from bronze.crm_prd_info;

		  SET @end_time=GETDATE();
		Print '>> Load Duration: ' + Cast(Datediff(second, @start_time, @end_time) as NVarchar) + ' seconds';
		Print '---------------------------------------------------------------------'



		  -- Loading CRM_sales_details
		SET @start_time=GETDATE()
		print '>> Truncating Table: silver.crm_sales_details';
		Truncate Table silver.crm_sales_details
		print '>> Inserting Data Into: silver.crm_sales_details';
		  
		  insert into silver.crm_sales_details(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
			)
		  select 
		  sls_ord_num, 
		  sls_prd_key, 
		  sls_cust_id,
		  case when sls_order_dt =0 or len(sls_order_dt)!=8 then null
			   else cast(cast(sls_order_dt as varchar) as date)
		  end as sls_order_dt,

		  case when sls_ship_dt =0 or len(sls_ship_dt)!=8 then null
			   else cast(cast(sls_ship_dt as varchar) as date)
		  end as sls_ship_dt,

		  case when sls_due_dt =0 or len(sls_due_dt)!=8 then null
			   else cast(cast(sls_due_dt as varchar) as date)
		  end as sls_due_dt,
  
		  case when sls_sales is null or sls_sales<=0 or sls_sales != sls_quantity * abs(sls_price)
								then sls_quantity * abs(sls_price)
			   else sls_sales
		  end as sls_sales,

		  sls_quantity,

		  case when sls_price is null or sls_price<=0
					then sls_sales/ nullif(sls_quantity,0)
			   else sls_price
		  end as sls_price

		  from bronze.crm_sales_details;

		  SET @end_time=GETDATE();
		Print '>> Load Duration: ' + Cast(Datediff(second, @start_time, @end_time) as NVarchar) + ' seconds';
		Print '---------------------------------------------------------------------'



		--Loading ERP_cust_az12
		SET @start_time=GETDATE()
		print '>> Truncating Table: silver.erp_cust_az12';
		Truncate Table silver.erp_cust_az12
		print '>> Inserting Data Into: silver.erp_cust_az12';
		  
		Insert into silver.erp_cust_az12 (cid,bdate, gen)
		select
		case when cid like 'NAS%' then substring(cid,4,len(cid))
			else cid
		end as cid,
		case when  bdate>GETDATE() then Null
			else bdate
		end as bdate,
		case when upper(trim(gen)) in ('F','FEMALE') Then 'Female'
			when upper(trim(gen)) in ('M','MALE') Then 'Male'
			else 'N/A'
		end as gen
		from bronze.erp_cust_az12;

		SET @end_time=GETDATE();
		Print '>> Load Duration: ' + Cast(Datediff(second, @start_time, @end_time) as NVarchar) + ' seconds';
		Print '---------------------------------------------------------------------'



		--Loading ERP_loc_a101
		SET @start_time=GETDATE()
		print '>> Truncating Table: silver.erp_loc_a101';
		Truncate Table silver.erp_loc_a101
		print '>> Inserting Data Into: silver.erp_loc_a101';
		 
		insert into silver.erp_loc_a101 (cid,cntry)
		 select 
		 replace(cid,'-','') cid,
		 case when trim(cntry)='DE' then 'Germany'
			when trim(cntry) in ('US','USA') then 'United States'
			when trim(cntry) = '' or cntry is NULL then 'N/A'
			else trim(cntry)
		 end as cntry
		 from bronze.erp_loc_a101;

		 SET @end_time=GETDATE();
		Print '>> Load Duration: ' + Cast(Datediff(second, @start_time, @end_time) as NVarchar) + ' seconds';
		Print '---------------------------------------------------------------------'


		--Loading ERP_px_cat_g1v2
		SET @start_time=GETDATE()
		print '>> Truncating Table: silver.erp_px_cat_g1v2';
		Truncate Table silver.erp_px_cat_g1v2
		print '>> Inserting Data Into: silver.erp_px_cat_g1v2';
		
		 insert into silver.erp_px_cat_g1v2 (id,cat,subcat,maintenance)
		 select
		 id,
		 cat,
		 subcat,
		 maintenance
		 from bronze.erp_px_cat_g1v2;

		 SET @end_time=GETDATE();
		Print '>> Load Duration: ' + Cast(Datediff(second, @start_time, @end_time) as NVarchar) + ' seconds';
		Print '---------------------------------------------------------------------'

		SET @batch_end_time = GETDATE();
		Print '==============================================================='
		Print 'Loading Silver Layer is Completed';
		Print '     -Total Load Duration: ' + cast(datediff(second, @batch_start_time, @batch_end_time) as NVarchar) + ' seconds';
		Print '==============================================================='
	
	End TRY
	Begin Catch
		Print '===============================================================';
		Print 'Error Occured During Loading Silver Layer';
		Print 'Error Message' + Error_message();
		Print 'Error Message' + CAST (Error_Number() as NVarchar);
		Print 'Error Message' + CAST (Error_State() as NVarchar);
		Print '===============================================================';
	End Catch
END


--At last run the procedure which is stored in programmability
EXEC silver.load_silver