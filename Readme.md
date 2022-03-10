```
├── locale
│   ├── en
│   │   └── LC_MESSAGES
│   └── zh_CN
│       └── LC_MESSAGES
│           ├── phala.mo
├── phala.sh
├── scripts
│   ├── check.sh
│   ├── config.sh
│   ├── install.sh
│   ├── log.sh
│   ├── main.sh
│   ├── status.sh
│   └── utils.sh
├── temp
│   ├── docker-compose.yml.template
│   └── phala-env.template
└── tools
    ├── console.js
    ├── get-docker.sh
    ├── get-node.sh
    ├── sgx-detect
    ├── sgx_enable
    └── sgx_linux_x64_driver_2.11.0_2d2b795.bin
```


Usage:
	phala <debug> [OPTION]...

Options:
	help								展示帮助信息
	install								安装Phala挖矿套件
	uninstall							卸载phala脚本
	start								启动挖矿(debug参数允许输出挖矿套件日志信息)
		< node | pruntime | pherry >
	stop								停止挖矿程序
		< node | pruntime | pherry >
	config								(default: pro)
		< dev | show | locale >
	status								查看挖矿套件运行状态
	update			 					未实现
	logs								打印所有容器日志信息
		<clear>	< node | pruntime | pherry >			清理日志
		< node | pruntime | pherry >
	sgx-test							运行挖矿测试程序