��    )      d  ;   �     �  p   �     "     >     \     o  
   w     �  (   �     �     �  Q   �  ?   K    �  6   �  :   �  f        l  
   �  ?   �     �     �     �       Q   #  I   u  7   �  5   �     -     D     [     g     {     �  �  �  !   �  .   �     �     �  
              4  t   U     �  '   �          #     *  !   =  +   _     �     �  ?   �  !   �  �    +   �  9     L   I     �  	   �  0   �     �     �            D   '  4   l  $   �  1   �     �           ,      9      S      g   �  t      W#  !   m#     �#     �#  	   �#     �#      #                                  (   $                    !       )   '             &              	   
                                                            "                   %                	 [ %s ]	 unknown error!  -------------------------------------------  Remaining %s refresh  -------------------------------------------- %s
Template file not found! Account PHA is less than 0.1! Apt update failed! Choices Clean data Enter your gas account mnemonic Enter your node name(not contain spaces) Enter your pool address Insufficient balance! Intel IAS certification has not passed, please check your motherboard or network! Not registered, please wait for the synchronization to complete Phala Status:
--------------------------------------------- Script version %s [ %s ] --------------------------------------
	service name		service status			local node block height
------------------------------------------------------------------------------------------------------------------
	khala-node			%s				%s / %s
	kusama-node			%s				%s / %s
	phala-pruntime			%s
	phala-pherry			%s				khala %s / kusama %s
------------------------------------------------------------------------------------------------------------------
	Status check							result
------------------------------------------------------------------------------------------------------------------
	khala chain synchronization status		%s, difference is %s
	kusama chain synchronization status		%s, difference is %s
	pherry synchronizes khala chain status		%s, difference is %s
	pherry syncs kusama chain status  		%s, difference is %s
------------------------------------------------------------------------------------------------------------------
	account information		content
------------------------------------------------------------------------------------------------------------------
	node name           		%s
	cores     			%s
	GAS account address      	%s
	GAS account balance      	%s
	stake pool account address	%s
	miner/worker public key 	%s
	miner registration status	%s
	miner score			%s
------------------------------------------------------------------------------------------------------------------
Please wait for the miner registration status to change to %s before proceeding on-chain operations
If the chain synchronization is completed, but the pherry height is empty, please enter the group and ask
----------------------------------- last refresh time [ %s ] ------------------------------------ Please enter a legal mnemonic, and it cannot be empty! Please enter a legal pool address, and it cannot be empty! Please enter an integer greater than 1 and less than %s, and your enter is incorrect, please re-enter! Please first run [ sudo %s ]! Refreshing Registered, you can use the miner’s public key to add a miner Set Language Set success Synchronization completed Synchronizing, please wait Test confidenceLevel, waiting for Intel to issue IAS remote certification report! The driver file was not found, please check the driver installation logs! The node is not configured, start configuring the node! The node name cannot contain spaces, please re-enter! Unsupported Kernel! %s Unsupported system! %s Update Fail Update phala images Update phala script Update success Usage:
	phala [OPTION]...

Options:
	help					display help information
	install					install your phala node
	uninstall				uninstall your phala scripts
	start					start mining
		<node | pruntime | pherry>
	stop					stop mining
		<node | pruntime | pherry>
	config
		<show>				display all configuration of your node
		<testnet | locale>
	status					display the running status of all components
	update					update all container,and don't clean up the container data
		<clean>				update all container,and clean up the container data
		<script>			update the script
	logs					print all container logs information
		<node | pruntime | pherry>
		<clean>				clean log
	sgx-test				start the mining test program
	version					display script version
 Waiting for the miner to register You use several cores to participate in mining Your confidenceLevel is：%s log type or msg not found!!! registered version [ %s ] is up to date 	 [ %s ]	 发生未知的错误!  ----------------------------------------------  剩余 %s 刷新 -------------------------------------------------- %s
模板文件未找到! 账户PHA小于0.1，请重新输入！ 系统源更新失败! 选择 删除节点数据 输入你的GAS费账号助记词 请输入节点名称（不能包含空格) 输入抵押池账户地址 余额不足! Intel IAS认证没有通过，请检查您的主板或网络！ 未注册，请等待同步完成 Phala 状态:
------------------------------------------- 脚本版本 %s [ %s ] ----------------------------------------------
        服务名称                服务状态                本地节点区块高度
------------------------------------------------------------------------------------------------------------------
        khala-node              %s                      %s / %s
        kusama-node             %s                      %s / %s
        phala-pruntime          %s
        phala-pherry            %s                      khala %s / kusama %s
------------------------------------------------------------------------------------------------------------------
        状态检查                        结果
------------------------------------------------------------------------------------------------------------------
        khala链同步状态                 %s, 差值为 %s
        kusama链同步状态                %s, 差值为 %s
        pherry同步khala链状态           %s, 差值为 %s
        pherry同步kusama链状态          %s, 差值为 %s
------------------------------------------------------------------------------------------------------------------
        账户信息                        内容
------------------------------------------------------------------------------------------------------------------
        节点名称                        %s
        计算机使用核心                  %s
        GAS费账户地址                   %s
        GAS费账户余额                   %s
        抵押池账户地址                  %s
        矿工公钥                        %s
        矿工注册状态                    %s
        矿工评分                        %s
------------------------------------------------------------------------------------------------------------------
------------------------------- 请等待矿工注册状态变为「%s」再进行链上操作 -----------------------------------
-------------------------------  如果链同步完成，但pherry高度为空，请进群询问 ------------------------------------
------------------------------------  上次更新时间 [ %s ] --------------------------------------- 请输入合法助记词,且不能为空！ 请输入合法抵押池账户地址，且不能为空！ 请输入大于1小于%s 的整数，该数据不正确，请重新输入！ 请先运行 [ sudo %s ]! 刷新中 已注册，可以使用矿工公钥添加矿机 设置语言 设置成功 同步完成 同步中, 请等待 测试信用等级，正在等待Intel下发IAS远程认证报告！ 未找到驱动文件，请检查驱动安装日志! 节点未配置，开始配置节点 节点名称不能包含空格，请重新输入! 不受支持的内核! %s 不受支持的系统! %s 更新失败 更新 phala 套件镜像 更新 phala 脚本 更新成功 Usage:
	phala [OPTION]...

Options:
	help					展示帮助信息
	install					安装Phala挖矿套件
	uninstall				卸载phala脚本
	start					启动挖矿(debug参数允许输出挖矿套件日志信息)
		<node | pruntime | pherry>
	stop					停止挖矿程序
		<node | pruntime | pherry>
	config					配置
		<show>				查看配置信息（直接看到配置文件所有信息）
		<testnet | locale>
	status					查看挖矿套件运行状态
	update					不清理容器数据，更新容器
		<clean>				清理容器数据，更新容器
		<script>			更新脚本
	logs					打印所有容器日志信息
		<clean>				清理日志
		<node | pruntime | pherry>
	sgx-test				运行挖矿测试程序
	version					打印脚本版本
 等待矿机注册中 您使用几个核心参与挖矿 您的信任等级是：%s logtype 或 msg 为空!!! 已注册 [ %s ] 版本已是最新 