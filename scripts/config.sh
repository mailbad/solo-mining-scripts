#!/usr/bin/env bash
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

phala_scripts_tools_dir="${phala_scripts_dir}/tools"
phala_scripts_conf_dir="${phala_scripts_dir}/conf"
phala_scripts_tmp_dir="${phala_scripts_dir}/tmp"
[ -d "${phala_scripts_tmp_dir}" ] || mkdir ${phala_scripts_tmp_dir}

phala_scripts_temp_ymlf="${phala_scripts_conf_dir}/docker-compose.yml.template"
phala_scripts_docker_ymlf="${phala_scripts_conf_dir}/phala-docker.yml"


function phala_scripts_config_sgxdevice() {
  # check and install
  phala_scripts_check_sgxdevice
  local _phala_docker_yml=""
  for d in "${phala_scripts_sgx_device_path[@]}";do
    _phala_docker_yml="${_phala_docker_yml}\n    - ${d}"
  done
  sed "s#phala_template_value#${_phala_docker_yml}#g" ${phala_scripts_temp_ymlf} > ${phala_scripts_docker_ymlf}
  rm -f ${phala_scripts_dir}/docker-compose.yml
  ln -s ${phala_scripts_docker_ymlf} ${phala_scripts_dir}/docker-compose.yml
}

function phala_scripts_config_show() {
    :
}

function phala_scripts_config_set() {
  #sed "s#phala_template_value#/dev/sgx_enclave:/dev/sgx/enclave\n    - /dev/sgx_provision:/dev/sgx/provision#g" docker-compose.yml.template
    :
}

function phala_scripts_config_init() {
    :
}

function phala_scripts_config() {
  phala_scripts_config_sgxdevice
}