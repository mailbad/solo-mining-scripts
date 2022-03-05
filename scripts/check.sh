#!/usr/bin/env bash

function phala_script_checks_support() {
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
    _phala_scripts_utils_printf_value="$(phala_script_checks_support)"
    phala_scripts_log error "Unsupported system! %s" cut
    return 1
  fi
}

function phala_scripts_check_kernel() {
  if [[ "${phala_scripts_support_kernel[@]}" =~ "$(uname -r|cut -d '.' -f1,2 2>/dev/null)" ]];then
    :
  else
    _phala_scripts_utils_printf_value="$(phala_script_checks_support)"
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
  _default_soft="jq curl wget unzip zip docker docker-compose node"
  if ! type $_default_soft >/dev/null 2>&1;then
    phala_scripts_log info "Apt update" cut
    apt update
    if [ $? -ne 0 ]; then
		  phala_scripts_log error "Apt update failed."
	  fi
  else
    return 0
  fi

  phala_scripts_log info "Installing dependencies" cut
  for _package in $_default_soft;do
    if ! type $_package >/dev/null 2>&1;then
      case $_package in
        jq|curl|wget|unzip|zip|dkms)
          apt install -y $_package
        ;;
        docker)
          if [ ! -f "${phala_scripts_tools_dir}/get-docker.sh" ];then
            curl -fsSL get.docker.com -o ${phala_scripts_tools_dir}/get-docker.sh
          fi
          sh get-docker.sh --mirror Aliyun
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

function phala_scripts_check() {
  phala_scripts_check_system
  phala_scripts_check_kernel
  phala_scripts_check_sgxenable
  phala_scripts_check_dependencies
}