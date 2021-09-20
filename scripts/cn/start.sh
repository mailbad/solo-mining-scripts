#!/bin/bash

function start()
{
	if [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ ! -c /dev/sgx_enclave ]&&[ ! -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		install
	elif ! type jq curl wget unzip zip docker docker-compose node yq dkms > /dev/null; then
		install_depenencies
	fi

	local node_name=$(cat $installdir/.env | grep 'NODE_NAME' | awk -F "=" '{print $NF}')
	local cores=$(cat $installdir/.env | grep 'CORES' | awk -F "=" '{print $NF}')
	local mnemonic=$(cat $installdir/.env | grep 'MNEMONIC' | awk -F "=" '{print $NF}')
	local pool_address=$(cat $installdir/.env | grep 'OPERATOR' | awk -F "=" '{print $NF}')
	if [ -z "$node_name" ]||[ -z "$cores" ]||[ -z "$mnemonic" ]||[ -z "$pool_address" ]; then
		log_err "----------节点未配置，开始配置节点！----------"
		config set
	fi

	local pruntime_devices=$(cat $installdir/docker-compose.yml | grep 'sgx')
	if [ -z "$pruntime_devices" ]; then
		log_err "---------- 请重新安装驱动！----------"
	fi

	cd $installdir
	docker-compose up -d
}
