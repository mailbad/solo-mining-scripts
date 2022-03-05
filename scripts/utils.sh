#!/usr/bin/env bash

function phala_scripts_utils_setlocale() {
  export TEXTDOMAINDIR=${phala_scripts_dir}/locale
  export TEXTDOMAIN=phala
  
  if [[ "$LANG" =~ "en" ]] || [[ "$LANG" =~ "zh" ]];then
    # test run
    if $(localectl list-locales 2>/dev/null |grep -i zh_CN >/dev/null 2>&1);then
      export LANG="zh_CN.UTF-8"
    else
      # sudo apt -y  install language-pack-zh-hans
      :
    fi
    :
  else
    export LANG="en_US.UTF-8"
  fi
}

function phala_scripts_utils_gettext() {
  gettext -se "$*"
}

function _echo_c() {
  if [ "$shell_name" != "bash" ] || [[ "$2" =~ "%" ]];then
    [ -z "$_phala_scripts_utils_printf_value" ] && _phala_scripts_utils_printf_value=""
    printf "\033[0;$1m$2\033[0m\n" "${_phala_scripts_utils_printf_value}"
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
  local env_path="${script_dir}/.env"
  local dc_yml_path="${script_dir}/docker-compose-${}.yml"
  local dc_cmd="docker-compose --env-file ${env_path} -f ${docker-compose_yml_path}"
  $dc_cmd $*
}