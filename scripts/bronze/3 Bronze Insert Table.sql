
Create or Alter Procedure bronze.load_bronze As
Begin
	Declare @start_time Datetime, @end_time Datetime, @batch_start_time Datetime, @batch_end_time Datetime;
	Begin Try
		SET @batch_start_time = GETDATE();
		Print '===============================================================';
		Print 'Loading Bronze Layer';
		Print '===============================================================';
	
		Print '---------------------------------------------------------------';
		Print 'Loading CRM Tables';
		Print '---------------------------------------------------------------';

		SET @start_time=GETDATE();
		Print '>> Truncating Table: bronze.crm_cust_info'
		Truncate Table bronze.crm_cust_info;

		Print '>> Insert Data Into: bronze.crm_cust_info'
		BULK Insert bronze.crm_cust_info
		From 'C:\Users\hu374\OneDrive\Desktop\SQL\datasets\source_crm\cust_info.csv'
		With (
		Firstrow = 2,
		Fieldterminator = ',' ,
		Tablock
		);
		SET @end_time=GETDATE();
		Print '>> Load Duration: ' + Cast(Datediff(second, @start_time, @end_time) as NVarchar) + ' seconds';
		Print '---------------------------------------------------------------------'

		SET @start_time=GETDATE();
		Print '>> Truncating Table: bronze.crm_prd_info'
		Truncate Table bronze.crm_prd_info;

		Print '>> Insert Data Into: bronze.crm_prd_info'
		BULK Insert bronze.crm_prd_info
		From 'C:\Users\hu374\OneDrive\Desktop\SQL\datasets\source_crm\prd_info.csv'
		With (
		Firstrow = 2,
		Fieldterminator = ',' ,
		Tablock
		);
		SET @end_time=GETDATE();
		Print '>> Load Duration: ' + Cast(Datediff(second, @start_time, @end_time) as NVarchar) + ' seconds';
		Print '---------------------------------------------------------------------'


		SET @start_time=GETDATE();
		Print '>> Truncating Table: bronze.crm_sales_details'
		Truncate Table bronze.crm_sales_details;

		Print '>> Insert Data Into: bronze.crm_sales_details'
		BULK Insert bronze.crm_sales_details
		From 'C:\Users\hu374\OneDrive\Desktop\SQL\datasets\source_crm\sales_details.csv'
		With (
		Firstrow = 2,
		FieldTerminator = ',',
		Tablock
		);
		SET @end_time=GETDATE();
		Print '>> Load Duration: ' + Cast(Datediff(second, @start_time, @end_time) as NVarchar) + ' seconds';
		Print '---------------------------------------------------------------------'


		Print '---------------------------------------------------------------';
		Print 'Loading ERP Tables';
		Print '---------------------------------------------------------------';
	
		SET @start_time=GETDATE();
		Print '>> Truncating Table: bronze.erp_cust_az12'
		Truncate Table bronze.erp_cust_az12;

		Print '>> Insert Data Into: bronze.erp_cust_az12'
		BULK Insert bronze.erp_cust_az12
		From 'C:\Users\hu374\OneDrive\Desktop\SQL\datasets\source_erp\cust_az12.csv'
		With (
		Firstrow = 2,
		FieldTerminator = ',',
		Tablock
		);
		SET @end_time=GETDATE();
		Print '>> Load Duration: ' + Cast(Datediff(second, @start_time, @end_time) as NVarchar) + ' seconds';
		Print '---------------------------------------------------------------------'


		SET @start_time=GETDATE();
		Print '>> Truncating Table: bronze.erp_loc_a101'
		Truncate Table bronze.erp_loc_a101;

		Print '>> Insert Data Into: bronze.erp_loc_a101'
		BULK Insert bronze.erp_loc_a101
		From 'C:\Users\hu374\OneDrive\Desktop\SQL\datasets\source_erp\loc_a101.csv'
		With (
		Firstrow = 2,
		FieldTerminator = ',',
		Tablock
		);
		SET @end_time=GETDATE();
		Print '>> Load Duration: ' + Cast(Datediff(second, @start_time, @end_time) as NVarchar) + ' seconds';
		Print '---------------------------------------------------------------------'


		SET @start_time=GETDATE();
		Print '>> Truncating Table: bronze.erp_px_cat_g1v2'
		Truncate Table bronze.erp_px_cat_g1v2;

		Print '>> Insert Data Into: bronze.erp_px_cat_g1v2'
		BULK Insert bronze.erp_px_cat_g1v2
		From 'C:\Users\hu374\OneDrive\Desktop\SQL\datasets\source_erp\px_cat_g1v2.csv'
		With (
		Firstrow = 2,
		FieldTerminator = ',',
		Tablock
		);
		SET @end_time=GETDATE();
		Print '>> Load Duration: ' + Cast(Datediff(second, @start_time, @end_time) as NVarchar) + ' seconds';
		Print '---------------------------------------------------------------------'
		
		SET @batch_end_time = GETDATE();
		Print '==============================================================='
		Print 'Loading Bronze Layer is Completed';
		Print '     -Total Load Duration: ' + cast(datediff(second, @batch_start_time, @batch_end_time) as NVarchar) + ' seconds';
		Print '==============================================================='

	End TRY
	Begin Catch
		Print '===============================================================';
		Print 'Error Occured During Loading Bronze Layer';
		Print 'Error Message' + Error_message();
		Print 'Error Message' + CAST (Error_Number() as NVarchar);
		Print 'Error Message' + CAST (Error_State() as NVarchar);
		Print '===============================================================';
	End Catch
End


--Execute the command after previous commands run
Exec bronze.load_bronze;
