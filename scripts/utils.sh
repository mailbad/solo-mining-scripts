#!/usr/bin/env bash

function phala_scripts_trap() {
  local _quit_code=$?
  [ ${_quit_code} -eq 0 ] && return 0
  local source_path=$(caller 0 |awk '{print $2}')
  [ "${source_path}" == "phala_scripts_status" ] && clear;exit
  if [ "${_phala_scripts_error_trap}" != "false" ];then
    export _phala_scripts_utils_printf_value="${source_path}" 
    local _trap_msg=$(phala_scripts_utils_gettext "\t [ %s ]\t unknown error!")
    local _trap_msg="----------------------------------------------------------------------------------------------------\n${_trap_msg}\n----------------------------------------------------------------------------------------------------" 
    phala_scripts_utils_red ${_trap_msg}
  fi
  return ${_quit_code}
}

function phala_scripts_utils_setlocale() {
  export TEXTDOMAINDIR=${phala_scripts_dir}/locale
  export TEXTDOMAIN=phala
  case "${PHALA_LANG}" in
    CN)
      if $(localectl list-locales 2>/dev/null |grep -i zh_CN >/dev/null 2>&1);then
        :
      else
        sudo apt -y  install language-pack-zh-hans
      fi
      export LANG="zh_CN.UTF-8"
    ;;
    US)
      export LANG="en_US.UTF-8"
    ;;
    *)
      export LANG="en_US.UTF-8"
    ;;
  esac 
  
  if [[ "$LANG" =~ "en" ]] || [[ "$LANG" =~ "zh" ]];then
    :
  else
    export LANG="en_US.UTF-8"
  fi
}

function phala_scripts_utils_gettext() {
  gettext -se "$*"
}

function phala_scripts_utils_read() {
  local _read_msg=$(phala_scripts_utils_gettext "$1")
  local _read_input
  if [ ! -z "$2" ];then
    local _default_msg="$2"
    read -p "${_read_msg} (Default: ${_default_msg}): " _read_input
    [ -z "${_read_input}" ] && _read_input=${_default_msg}
  else
    while [ -z "${_read_input}" ];do
      read -p "${_read_msg}: " _read_input
    done
  fi
  echo $_read_input
}

function _echo_c() {
  if [ "$shell_name" != "bash" ] || [[ "$2" =~ "%" ]];then
    [ -z "$_phala_scripts_utils_printf_value" ] && _phala_scripts_utils_printf_value=""
    printf "\033[0;$1m$2\033[0m\n" "${_phala_scripts_utils_printf_value[@]}"
    unset _phala_scripts_utils_printf_value

  else
    echo -en "\033[0;$1m$2\033[0m\n"
  fi
}

function phala_scripts_utils_red() {
  _echo_c 31 "$*"
}

function phala_scripts_utils_green() {
  _echo_c 32 "$*"
}

function phala_scripts_utils_yellow() {
  _echo_c 33 "$*"
}

function phala_scripts_utils_default() {
  _echo_c '' "$*"
}

function phala_scripts_utils_docker() {
  docker-compose --env-file ${phala_scripts_docker_envf} -f ${phala_scripts_dir}/docker-compose.yml $*
}

function phala_scripts_utils_docker_status() {
  exist=$(docker inspect --format '{{.State.Running}}' phala-${1} 2>/dev/null)
  if [ x"${exist}" == x"true" ]; then
    return 0
  elif [ "${exist}" == "false" ]; then
    return 2
  else
    return 1
  fi
}