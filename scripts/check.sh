#!/usr/bin/env bash

function phala_scripts_checks_support() {
  _support_msg="\n\nSystem:\t"
  local IFS=$','
  for s in ${phala_scripts_support_system[@]}; do
    _support_msg="${_support_msg}\t$s "
  done
  _support_msg="${_support_msg}\n\nKernel:\t"
  for k in ${phala_scripts_support_kernel[@]};do
    _support_msg="${_support_msg}\t$k"
  done
  echo -e $_support_msg
}

function phala_scripts_check_system() {
  if [ -f /etc/lsb-release ];then
    . /etc/lsb-release
    [[ "${phala_scripts_support_system[@]}" =~ "${DISTRIB_ID} ${DISTRIB_RELEASE}" ]] && _system_check=true
  fi
  if [ -z "$_system_check" ];then
    _phala_scripts_utils_printf_value="$(phala_scripts_checks_support)"
    phala_scripts_log error "Unsupported system! %s" cut
    return 1
  fi
}

function phala_scripts_check_kernel() {
  if [[ "${phala_scripts_support_kernel[@]}" =~ "$(uname -r|cut -d '.' -f1,2 2>/dev/null)" ]];then
    :
  else
    _phala_scripts_utils_printf_value="$(phala_scripts_checks_support)"
    phala_scripts_log error "Unsupported Kernel! %s" cut
    return 1
  fi
}

function phala_scripts_check_sgxenable() {
  _sgx_enable=${phala_scripts_tools_dir}/sgx_enable
  if ! $($_sgx_enable -s|grep -i 'already enabled' >/dev/null 2>&1);then
    export _phala_scripts_utils_printf_value="$_sgx_enable"
    phala_scripts_log error "Please first run [ sudo %s ]!" 
  fi
}

function phala_scripts_check_dependencies(){
  # check and install
  # _default_soft="jq curl wget unzip zip"
  # _other_soft="docker docker-compose node"
  _default_soft=${phala_scripts_dependencies_default_soft}
  _other_soft=${phala_scripts_dependencies_other_soft}
  if ! type $_default_soft >/dev/null 2>&1;then
    phala_scripts_log info "Apt update" cut
    # modify cn 
    sed -i 's#http://archive.ubuntu.com#https://mirrors.ustc.edu.cn#g' /etc/apt/sources.list
    apt update
    if [ $? -ne 0 ]; then
		  phala_scripts_log error "Apt update failed."
	  fi
    phala_scripts_log info "Installing Apt dependencies" cut
    apt install -y ${_default_soft}
  fi

  if type $_other_soft > /dev/null 2>&1;then
    return 0
  fi

  phala_scripts_log info "Installing other dependencies" cut
  for _package in ${_other_soft};do
    if ! type $_package >/dev/null 2>&1;then
      case $_package in
        docker|docker-compose)
          if [ ! -f "${phala_scripts_tools_dir}/get-docker.sh" ];then
            curl -fsSL get.docker.com -o ${phala_scripts_tools_dir}/get-docker.sh
          fi

          [ ! type docker >/dev/null 2>&1 ] && sh ${phala_scripts_tools_dir}/get-docker.sh --mirror Aliyun
          apt install -y docker-compose
        ;;
        node)
          curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
          apt-get install -y nodejs
        ;;
      esac
    fi
  done
}

function phala_scripts_check_sgxdevice() {
  _sgx_msg_file=${phala_scripts_tmp_dir}/sgx-detect.msg
  ${phala_scripts_tools_dir}/sgx-detect > ${_sgx_msg_file}
  _sgx_cpu_support_number=$(awk '/CPU support/ {print $1}' ${_sgx_msg_file}|wc -l)
  _sgx_libsgx_encalve=$(awk '/libsgx_enclave_common/ {print $1}' ${_sgx_msg_file})
  _sgx_aems_service=$(awk '/AESM service/ {print $1}' ${_sgx_msg_file})
  if [ ${_sgx_cpu_support_number} -gt 1 ] && [ "${_sgx_libsgx_encalve}" == "yes" ];then
    :
  else
    # install
    phala_scripts_install_sgx
  fi

  if [ "${_sgx_aems_service}" == "yes" ];then
    :
  else
    dpkg --list|grep -i sgx-aesm-service >/dev/null 2>&1
    [ $? -eq 0 ] && systemctl start aesmd || phala_scripts_install_sgx
  fi
  # _sgx_detect_msg=$(${_sgx_detec})
  # phala_scripts_log debug "${_sgx_detect_msg}"
  #phala_scripts_sgx_device_path=$(awk -F "[()]" '/SGX kernel device/ {print $2}' ${_sgx_msg_file})
  _sgx_msg_device_path=$(awk -F "[()]" '/SGX kernel device/ {print $2}' ${_sgx_msg_file})
  if [ -z "${_sgx_msg_device_path}" ];then
    phala_scripts_log error "sgx device not found"
  fi
  
  if [ "${_sgx_msg_device_path}" == "/dev/sgx_enclave" ];then
    phala_scripts_sgx_device_path=(/dev/sgx_enclave:/dev/sgx/enclave /dev/sgx_provision:/dev/sgx/provision)
  else
    phala_scripts_sgx_device_path=${_sgx_msg_device_path}
  fi
  export phala_scripts_sgx_device_path
}

function phala_scripts_check_sgxtest() {
  # check device and get device_path
  phala_scripts_check_sgxdevice
  _phala_docker_device=""
  for d in ${phala_scripts_sgx_device_path[@]};do
    _phala_docker_device="${_phala_docker_device} --device ${d}"
  done
  docker run -ti --rm --name phala-sgx_detect ${_phala_docker_device} ${phala_scripts_sgxtest_dockerimages}
}

function phala_scripts_check() {
  phala_scripts_check_system
  phala_scripts_check_kernel
  phala_scripts_check_sgxenable
  phala_scripts_check_dependencies
}