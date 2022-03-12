#!/usr/bin/env bash

function phala_scripts_update_container() {
  phala_scripts_log info "Update phala images" cut
  phala_scripts_check_envf
  phala_scripts_config_dockeryml
  local _container_name=$(awk -F':' '/container_name/ {print $NF}' ${phala_scripts_docker_ymlf} 2>/dev/null|grep "\-${1}$")
  if [ -z "$1" ];then
    phala_scripts_utils_docker pull
  elif [ ! -z "${_container_name}" ];then
    phala_scripts_utils_docker pull ${_container_name}
  else
    phala_scripts_help
    return 0
  fi
#   phala_scripts_stop_container $*
  phala_scripts_start $*
  phala_scripts_log info "Update success" cut
}

function phala_scripts_update_script() {
  type dig || apt install -y dnsutils
  local _update_txt_domain=""
  local _get_new_vesion="$(dig txt ${_update_txt_domain} +short | sed 's#"##g')"
  if [ "${_get_new_vesion}" == "${phala_scripts_version}" ] && [ "$1" != "now" ];then
    return 0
  fi
  phala_scripts_log info "Update phala script" cut
  local _update_tmp_dir="${phala_scripts_tmp_dir}/phala_update_$(date +%s)"
  curl -fsSL ${phala_scripts_update_url} -o ${phala_scripts_tmp_dir}/update_phala-main.zip && \
  unzip ${phala_scripts_tmp_dir}/update_phala-main.zip -d ${_update_tmp_dir}
  local _get_update_dir=$(find ${_update_tmp_dir} -maxdepth 1 -type d |sed 1d)
  echo cp -arf ${_get_update_dir}/* ${phala_scripts_dir}
  phala_scripts_log info "Update success" cut
}

function phala_scripts_update() {
  case in $1
    script)
      phala_scripts_update_script $*
    ;;
    clean)
      :
    ;;
    *)
      phala_scripts_update_container $*
    ;;
  esac
}