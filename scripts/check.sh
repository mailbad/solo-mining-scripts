#!/usr/bin/env bash

function phala_scripts_check_system() {
  if [ -f /etc/lsb-release ];then
    . /etc/lsb-release
    [[ "${phala_scripts_support_system[@]}" =~ "${DISTRIB_ID} ${DISTRIB_RELEASE}" ]] && _system_check=true
  fi
  if [ -z "$_system_check" ];then
    phala_scripts_log error "Unsupported system!"
    return 1
  fi
}

function phala_scripts_check_kernel() {
  if [[ "${phala_scripts_support_kernel[@]}" =~ "$(uname -r|cut -d '.' -f1,2 2>/dev/null)" ]];then
    :
  else
    phala_scripts_log error "Unsupported Kernel!"
    return 1
  fi
}

function phala_scripts_check() {
  phala_scripts_check_system
  phala_scripts_check_kernel
}