#!/usr/bin/env bash

# source 
. ${phala_scripts_dir}/scripts/utils.sh
. ${phala_scripts_dir}/scripts/log.sh
. ${phala_scripts_dir}/scripts/config.sh
. ${phala_scripts_dir}/scripts/check.sh
. ${phala_scripts_dir}/scripts/install.sh
. ${phala_scripts_dir}/scripts/status.sh

function phala_scripts_help(){
# "		<dcap>				install DCAP driver\n"\
# "		<isgx>				install isgx driver\n"\
# "	score-test\n"\
# "		<Parameter>			get the scores of your machine"
phala_scripts_utils_gettext "Usage:\n"\
"	phala [OPTION]...\n"\
"\n"\
"Options:\n"\
"	help					display help information\n"\
"	install					install your phala node\n"\
"	uninstall				uninstall your phala scripts\n"\
"	start					start mining\n"\
"		<khala>				start khala-node\n"\
"	stop					stop mining\n"\
"		<node>				stop phala-node container\n"\
"		<pruntime>			stop phala-pruntime container\n"\
"		<pherry>			stop phala-pherry container\n"\
"		<bench>				stop phala-pruntime-bench container\n"\
"	config\n"\
"		<show>				display all configuration of your node\n"\
"		<set>				set all configuration\n"\
"	status					display the running status of all components\n"\
"	update					update all container,and don't clean up the container data\n"\
"		<clean>				update all container,and clean up the container data\n"\
"		<script>			update the script\n"\
"	logs					print all container logs information\n"\
"		<node>				print phala-node logs information\n"\
"		<pruntime>			print phala-pruntime logs information\n"\
"		<pherry>			print phala-pherry logs information\n"\
"		<bench>				print phala-pruntime-bench logs information\n"\
"	sgx-test				start the mining test program\n"

}

function phala_scripts_start() {
  phala_scripts_check_envf
  # phala_scripts_check_ymlf
  phala_scripts_config_dockeryml
  phala_scripts_utils_docker up -d
}

# function phala_scripts_stop_logs() {
#   phala_scripts_check_envf
#   phala_scripts_check_ymlf
#   local _container_name=$(awk -F':' '/container_name/ {print $NF}' ${phala_scripts_docker_ymlf}|grep "\-${2}$")
#   if [ -z "$2" ] && [ "$1" == "stop" ];then
#     phala_scripts_utils_docker stop
#     phala_scripts_utils_docker rm -f
#   elif [[ ! -z ${_container_name} ]] && [ "$1" == "stop" ];then
#     phala_scripts_utils_docker stop ${_container_name}
#     phala_scripts_utils_docker rm -f ${_container_name}
#   elif [ -z "$2" ] && [ "$1" == "logs" ];then
#     phala_scripts_utils_docker logs -f --tail 50
#   elif [[ ! -z ${_container_name} ]] && [ "$1" == "logs" ];then
#     phala_scripts_utils_docker logs -f --tail 50 ${_container_name}
#   elif [ -z "$2" ] && [ "$1" == "ps" ];then
#     phala_scripts_utils_docker ps
#   elif [[ ! -z ${_container_name} ]] && [ "$1" == "ps" ];then
#     phala_scripts_utils_docker ps ${_container_name}
#   else
#     phala_scripts_help
#   fi
# }

function phala_scripts_ps_container() {
  phala_scripts_check_envf
  phala_scripts_check_ymlf
  local _container_name=$(awk -F':' '/container_name/ {print $NF}' ${phala_scripts_docker_ymlf}|grep "\-${1}$")
  if [ -z "$1" ];then
    phala_scripts_utils_docker ps
  elif [ ! -z "${_container_name}" ];then
    phala_scripts_utils_docker ps ${_container_name}
  else
    phala_scripts_help
  fi
}

function phala_scripts_stop_container() {
  # [ "$1" == "uninstall" ] || {
  #   phala_scripts_check_envf
  #   phala_scripts_check_ymlf
  #   shift
  # }
  local _container_name=$(awk -F':' '/container_name/ {print $NF}' ${phala_scripts_docker_ymlf} 2>/dev/null|grep "\-${1}$")
  if [ -z "$1" ];then
    phala_scripts_utils_docker stop
    phala_scripts_utils_docker rm -f
  elif [ ! -z "${_container_name}" ];then
    phala_scripts_utils_docker stop ${_container_name}
    phala_scripts_utils_docker rm -f ${_container_name}
  else
    phala_scripts_help
  fi
}

function phala_scripts_logs_container() {
  set +e
  phala_scripts_check_envf
  phala_scripts_check_ymlf
  local _container_name=$(awk -F':' '/container_name/ {print $NF}' ${phala_scripts_docker_ymlf}|grep "\-${1}$")
  if [ -z "$1" ];then
    phala_scripts_utils_docker logs -f --tail 50
  elif [ ! -z "${_container_name}" ];then
    phala_scripts_utils_docker logs -f --tail 50 ${_container_name}
  else
    phala_scripts_help
  fi
}

function phala_scripts_uninstall() {
  phala_scripts_install_aptdependencies uninstall "${phala_scripts_dependencies_default_soft[@]}"
  phala_scripts_install_otherdependencies uninstall "${phala_scripts_dependencies_other_soft[@]}"
  phala_scripts_install_sgx uninstall
  # test delete
  [ -L "/usr/local/bin/phala" ] && unlink /usr/local/bin/phala
  # mv ${phala_scripts_dir} ${phala_scripts_dir}.movetest
  chattr -i -R ${phala_scripts_conf_dir} ${phala_scripts_temp_dir} >/dev/null 2>&1
  phala_scripts_log info "Uninstall phala node sucess" cut
  phala_scripts_log info "\t\t\t\t\t Delete(rm -rf)\n \t\t\t\t\t Script Dir: [ ${phala_scripts_dir} ]\n \t\t\t\t\t Phala Data Dir: [ ${khala_data_path_default} ]" cut
}

function phala_scripts_clear_logs() {
  local _container_name=$(awk -F':' '/container_name/ {print $NF}' ${phala_scripts_docker_ymlf}|grep "\-${1}$")
  if [ -z "$1" ];then
    _container_name=$(awk -F':' '/container_name/ {print $NF}' ${phala_scripts_docker_ymlf})
  elif [ ! -z "${_container_name}" ];then
    :
  else
    phala_scripts_help
    return 1
  fi

  for _cname in ${_container_name[@]};do
    _phala_scripts_utils_printf_value="${_cname}"
    phala_scripts_log info "clear [ %s ] log." cut
    truncate -s 0 $(docker inspect --format='{{.LogPath}}' ${_cname});
  done
}

function phala_scripts_case() {
  if [ ! -L "/usr/local/bin/phala" ];then
    ln -s ${phala_scripts_dir}/phala.sh /usr/local/bin/phala
  elif [ ! -f "/usr/local/bin/phala" ] && [ -L "/usr/local/bin/phala" ];then
    unlink /usr/local/bin/phala
    ln -s ${phala_scripts_dir}/phala.sh /usr/local/bin/phala
  fi
  [ $(echo $1|grep -E "^start$|^presync$|^stop$|^status$|^logs$|^ps$|^sgx-test$"|wc -l) -eq 1 ] && phala_scripts_check_dependencies
  case "$1" in
    install|config)
      # if [ "$1" == "install" ];then
      #   if [ -f "${phala_scripts_docker_envf}" ] && [ -L "${phala_scripts_dir}/docker-compose.yml" ];then
      #     phala_scripts_log info "Skip Install..."
      #     return 0
      #   fi
      # fi
      shift
      phala_scripts_config_set $*
    ;;
    version)
      printf "Phala Scripts Version: %s\n" ${phala_scripts_version}
    ;;
    start)
      phala_scripts_start
    ;;
    presync)
      if [ -f ${phala_scripts_docker_envf} ];then
        local phala_scripts_config_input_nodename=$(phala_scripts_config_set_nodename)
        sed -i "s#NODE_NAME=.*#NODE_NAME=${phala_scripts_config_input_nodename}#g" ${phala_scripts_docker_envf}
        phala_scripts_utils_docker up -d
      else
        phala_scripts_start
      fi
    ;;
    stop)
      shift
      phala_scripts_stop_container $*
    ;;
    status)
      set +e
      phala_scripts_status
    ;;
    update)
      :
    ;;
    logs)
      export _phala_scripts_error_trap=false
      shift
      if [ "$1" == "clear" ];then
        shift
        phala_scripts_clear_logs $*
      else
        phala_scripts_logs_container $*
      fi
    ;;
    ps)
      shift
      phala_scripts_ps_container
    ;;
    uninstall)
      phala_scripts_stop_container
      phala_scripts_uninstall
    ;;
    sgx-test)
      phala_scripts_check_sgxtest
    ;;
    *)
      phala_scripts_help
    ;;
  esac
}

function phala_scripts_main() {
  # Error Quit
  set -e
  trap "phala_scripts_trap" EXIT INT
  export _phala_scripts_error_trap=true

  # return 1
  # Cannot run driectly
  if [ -z "${phala_scripts_dir}" ];then
  printf "\033[0;31m Cannot run driectly \033[0m\n"
    exit 1
  fi
  
  # run main case
  [ "$1" == "debug" ] && {
    # open shell debug
    set -x
    # shift OPTION
    shift
  }

  # default config [ first run ]
  phala_scripts_config

  # set locale lange
  phala_scripts_utils_setlocale

  # check 
  phala_scripts_check

  phala_scripts_case $*

}
