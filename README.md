# weivid-gitbub
1.RTL CODE 该文件包含所有RTL代码 

-----RSA_TOP_WRAPPER

---------RSA_TOP

-------------RSA_MODULAR_WRAPPER	    ---RSA IP核

---------------------MM_MONT_WRAP	    ---蒙哥马利核心计算模块	

---------------------mask_exp_ctl	    ---指数掩码模块

---------------------FSM_modular_ctl  ---FSM控制模块

---------------------DATA_PATH	 	    ---数据通路

---------------------sync_fifo_wrapper---RSA内部数据缓存模块		

-----------------AXI_INTERFACE		    ---AXI 主机接口

-----------------AXI_SLVAE			      ---AXI 从机接口

----------fifo_wrapper 		            --- 用于验证将RAM中的数据存储在EXT FIFO

----------RAM_INTERFACE 			        ---用于验证仿真用的RAM  

--------------ram_instance			      ---用于验证使用，从ram模型读取数据

	
