#!/usr/bin/env bash

function phala_scripts_utils_setlocale() {
  export TEXTDOMAINDIR=${phala_script_dir}/locale
  export TEXTDOMAIN=phala
  
  if [[ "$LANG" =~ "en" ]] || [[ "$LANG" =~ "zh" ]];then
    # test run
    if $(localectl list-locales >/dev/null 2>&1 |grep -i zh_CN );then
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
  if [ "$shell_name" != "bash" ];then
    printf "\033[0;$1m$2\033[0m\n"
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