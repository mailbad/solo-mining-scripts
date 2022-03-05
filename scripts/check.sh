#!/usr/bin/env bash

function phala_scripts_check_system() {

  if [ -f /etc/lsb-release ];then
    . /etc/lsb-release
    [[ "${phala_script_support_system[@]}" =~ "${DISTRIB_ID} ${DISTRIB_RELEASE}" ]] && _system_check=true
  fi
  if [ -z "$_system_check" ];then
    phala_scripts_log error "Unsupported system!"
    return 1
  fi
}