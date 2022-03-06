#!/usr/bin/env bash
phala_scripts_version=v0.2.0

phala_scripts_support_system=(
  "Ubuntu 20.04"
  "Ubuntu 21.10"
)
phala_scripts_support_kernel=(
  "5.4"
  "5.13"
)

phala_scripts_dependencies_default_soft=(
  jq curl wget unzip zip
)

phala_scripts_dependencies_other_soft=(
  docker docker-compose node
)

phala_scripts_config_default() {

  phala_scripts_sgxtest_image=phalanetwork/phala-sgx_detect
  phala_node_image=phalanetwork/khala-node
  phala_node_dev_image=phalanetwork/khala-pt3-node
  phala_pruntime_image=phalanetwork/phala-pruntime
  phala_pherry_image=phalanetwork/phala-pherry

  phala_scripts_public_ws="wss://khala.api.onfinality.io/public-ws"

  khala_data_path_default="/var/khala"

  phala_scripts_tools_dir="${phala_scripts_dir}/tools"
  phala_scripts_conf_dir="${phala_scripts_dir}/conf"
  phala_scripts_temp_dir="${phala_scripts_dir}/temp"
  phala_scripts_tmp_dir="${phala_scripts_dir}/tmp"
  [ -d "${phala_scripts_conf_dir}" ] || mkdir ${phala_scripts_conf_dir}
  [ -d "${phala_scripts_tmp_dir}" ] || mkdir ${phala_scripts_tmp_dir}

  phala_scripts_temp_ymlf="${phala_scripts_temp_dir}/docker-compose.yml.template"
  phala_scripts_docker_ymlf="${phala_scripts_conf_dir}/phala-docker.yml"
  phala_scripts_temp_envf="${phala_scripts_temp_dir}/phala-env.template"
  phala_scripts_docker_envf="${phala_scripts_conf_dir}/phala-env"
  
  export phala_scripts_sgxtest_image \
         phala_node_image \
         phala_node_dev_image \
         phala_pruntime_image \
         phala_pherry_image \
         phala_scripts_public_ws \
         khala_data_path_default \
         phala_scripts_tools_dir \
         phala_scripts_conf_dir \
         phala_scripts_temp_dir \
         phala_scripts_tmp_dir \
         phala_scripts_temp_ymlf \
         phala_scripts_docker_ymlf \
         phala_scripts_temp_envf \
         phala_scripts_docker_envf
}

function phala_scripts_config_dockeryml() {
  # check and install
  phala_scripts_check_sgxdevice
  local _phala_docker_yml=""
  for d in "${phala_scripts_sgx_device_path[@]}";do
    _phala_docker_yml="${_phala_docker_yml}\n    - ${d}"
  done
  sed "s#phala_template_ymlvalue#${_phala_docker_yml}#g" ${phala_scripts_temp_ymlf} > ${phala_scripts_docker_ymlf}
  if [ -f "${phala_scripts_dir}/docker-compose.yml" ] && [ -L "${phala_scripts_dir}/docker-compose.yml" ];then
    unlink ${phala_scripts_dir}/docker-compose.yml
  elif [ -f "${phala_scripts_dir}/docker-compose.yml" ] && [ ! -L "${phala_scripts_dir}/docker-compose.yml" ];then
    _bak_time=$(date +%s)
    phala_scripts_log info "move ${phala_scripts_dir}/docker-compose.yml ${phala_scripts_dir}/docker-compose.yml.${_bak_time}.bak" cut
    mv ${phala_scripts_dir}/docker-compose.yml ${phala_scripts_dir}/docker-compose.yml.${_bak_time}.bak
  fi

  ln -s ${phala_scripts_docker_ymlf} ${phala_scripts_dir}/docker-compose.yml
}

function phala_scripts_config_show() {
    :
}

function phala_scripts_config_set() {
  if [ "$1" == "show" ];then
    phala_scripts_config_show
    return 0
  fi

  # get cpu level
  phala_scripts_log info "Test confidenceLevel, waiting for Intel to issue IAS remote certification report!" cut
  local _confidenceLevel=$(phala_scripts_check_sgxtest | awk '/confidenceLevel =/{ print $3 }' | tr -cd "[0-9]")
  if [ -z ${_confidenceLevel} ];then
    phala_scripts_log error "Intel IAS certification has not passed, please check your motherboard or network!"
  # 1 => level <= 5
  elif [ "${_confidenceLevel}" -ge 1 ] && [ "${_confidenceLevel}" -le 5 ];then
    _phala_scripts_utils_printf_value=${_confidenceLevel}
    phala_scripts_log info "Your confidenceLevel is：%s" cut
  fi

  # set core
  local _my_cpu_core_number=$(awk -F':' '/cpu cores/ {print $2;exit}' /proc/cpuinfo)

  set +e
  while true ; do
    local _cores=$(phala_scripts_utils_read "You use several cores to participate in mining")
    expr ${_cores} + 0 > /dev/null 2>&1
    if [ $? -eq 0 ] && [ $_cores -ge 1 ] && [ $_cores -le ${_my_cpu_core_number} ]; then
      export phala_scripts_config_input_cores=${_cores}
      break
    else
      _phala_scripts_utils_printf_value=${_my_cpu_core_number}
      phala_scripts_log warn "Please enter an integer greater than 1 and less than %s, and your enter is incorrect, please re-enter!"  cut
    fi
  done
  set -e

  # set nodename
  while true ; do
    local _node_name=$(phala_scripts_utils_read "Enter your node name(not contain spaces)")
    if [[ "${_node_name}" =~ \ |\' ]]; then
      phala_scripts_log warn "The node name cannot contain spaces, please re-enter!" cut
    else
      export phala_scripts_config_input_nodename=${_node_name}
      # sed -i "7c NODE_NAME=$node_name" $installdir/.env
      break
    fi
  done

  # set mnemonic gas_account_address
  local _mnemonic=""
  local _gas_adress=""
  local _balance=""
  while true ; do
    _mnemonic=$(phala_scripts_utils_read "Enter your gas account mnemonic")
    if [ -z "${_mnemonic}" ] || [ "$(node ${phala_scripts_tools_dir}/console.js utils verify "$_mnemonic")" == "Cannot decode the input" ]; then
      phala_scripts_log warn "Please enter a legal mnemonic, and it cannot be empty!" cut
    else
      _gas_adress=$(node ${phala_scripts_tools_dir}/console.js utils verify "$_mnemonic")
      _balance=$(node  ${phala_scripts_tools_dir}/console.js --substrate-ws-endpoint "${phala_scripts_public_ws}" chain free-balance $_gas_adress 2>&1)
      _balance=$(echo $_balance | awk -F " " '{print $NF}')
      _balance=$(echo "$_balance / 1000000000000"|bc)
      if [ `echo "$_balance > 0.1"|bc` -eq 1 ]; then
        export phala_scripts_config_input_mnemonic=${_mnemonic}
        export phala_scripts_config_gas_account_address=${_gas_adress}
        # sed -i "8c MNEMONIC=$mnemonic" $installdir/.env
        # sed -i "9c GAS_ACCOUNT_ADDRESS=$gas_adress" $installdir/.env
        break
      else
        phala_scripts_log warn "Account PHA is less than 0.1!" cut
      fi
    fi
  done
  
  # set operator
  local _pool_addr=""
  while true ; do
    local _pool_addr=$(phala_scripts_utils_read "Enter your pool address")
    if [ -z "${_pool_addr}" ] || [ "$(node ${phala_scripts_tools_dir}/console.js utils verify "$_pool_addr")" == "Cannot decode the input" ]; then
      phala_scripts_log warn "Please enter a legal pool address, and it cannot be empty!"
    else
      export phala_scripts_config_input_operator=${_pool_addr}
      # sed -i "10c OPERATOR=$pool_addr" $installdir/.env
      break
    fi
  done

  # set custom datadir
  khala_data_path_default=$(phala_scripts_utils_read "Enter your Khala DATA PATH"  "${khala_data_path_default}")
  
  # save conf as env file
  sed -e "s#NODE_IMAGE=.*#NODE_IMAGE=${phala_node_image}#g" \
      -e "s#PRUNTIME_IMAGE=.*#PRUNTIME_IMAGE=${phala_pruntime_image}#g" \
      -e "s#PHERRY_IMAGE=.*#PHERRY_IMAGE=${phala_pherry_image}#g" \
      -e "s#CORES=.*#CORES=${phala_scripts_config_input_cores}#g" \
      -e "s#NODE_NAME=.*#NODE_NAME=${phala_scripts_config_input_nodename}#g" \
      -e "s#MNEMONIC=.*#MNEMONIC=${phala_scripts_config_input_mnemonic}#g" \
      -e "s#GAS_ACCOUNT_ADDRESS=.*#GAS_ACCOUNT_ADDRESS=${phala_scripts_config_gas_account_address}#g" \
      -e "s#OPERATOR=.*#OPERATOR=${phala_scripts_config_input_operator}#g" \
      -e "s#phala_template_data_value#${khala_data_path_default}#g" ${phala_scripts_temp_envf} > ${phala_scripts_docker_envf}

  if [ -f "${phala_scripts_dir}/.env" ] && [ -L "${phala_scripts_dir}/.env" ];then
    unlink ${phala_scripts_dir}/.env
  elif [ -f "${phala_scripts_dir}/.env" ] && [ ! -L "${phala_scripts_dir}/.env" ];then
    _bak_time=$(date +%s)
    phala_scripts_log info "move ${phala_scripts_dir}/.env ${phala_scripts_dir}/.env.${_bak_time}.bak" cut
    mv ${phala_scripts_dir}/.env ${phala_scripts_dir}/.env.${_bak_time}.bak
  fi
  ln -s ${phala_scripts_docker_envf} ${phala_scripts_dir}/.env

}

function phala_scripts_config_init() {
    :
}


function phala_scripts_config() {
  phala_scripts_config_default
  phala_scripts_config_dockeryml
}
