#!/usr/bin/env bash

# source 
. ${phala_scripts_dir}/scripts/utils.sh
. ${phala_scripts_dir}/scripts/log.sh
. ${phala_scripts_dir}/scripts/config.sh
. ${phala_scripts_dir}/scripts/check.sh
. ${phala_scripts_dir}/scripts/install.sh


function phala_scripts_help(){
# "		<dcap>				install DCAP driver\n"\
# "		<isgx>				install isgx driver\n"\
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
"	sgx-test				start the mining test program\n"\
"	score-test\n"\
"		<Parameter>			get the scores of your machine"
return 0
}

function phala_scripts_start() {
  phala_scripts_check_envf
  phala_scripts_check_ymlf
  phala_scripts_utils_docker up -d
}

function phala_scripts_stop_logs() {
  phala_scripts_check_envf
  phala_scripts_check_ymlf
  local _container_name=$(awk -F':' '/container_name/ {print $NF}' ${phala_scripts_docker_ymlf}|grep "\-${2}$")
  if [ -z "$2" ] && [ "$1" == "stop" ];then
    phala_scripts_utils_docker stop
    phala_scripts_utils_docker rm -f
  elif [[ ! -z ${_container_name} ]] && [ "$1" == "stop" ];then
    phala_scripts_utils_docker stop ${_container_name}
    phala_scripts_utils_docker rm -f ${_container_name}
  elif [ -z "$2" ] && [ "$1" == "logs" ];then
    phala_scripts_utils_docker logs -f
  elif [[ ! -z ${_container_name} ]] && [ "$1" == "logs" ];then
    phala_scripts_utils_docker logs -f ${_container_name}
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
  mv ${phala_scripts_dir} ${phala_scripts_dir}.movetest
  phala_scripts_log info "Uninstall phala node sucess" cut
}

function phala_scripts_case() {
  [ -L "/usr/local/bin/phala" ] || ln -s ${phala_scripts_dir}/phala.sh /usr/local/bin/phala
  [ $(echo $1|grep -E "^config$|^start$|^presync$|^stop$|^status$|^logs$|^sgx-test$"|wc -l) -eq 1 ] && phala_scripts_check_dependencies
  case "$1" in
    install)
      # install $2
      phala_scripts_check_dependencies
      shift
      phala_scripts_config_set $*
    ;;
    config)
      # config $2
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
      phala_scripts_stop_logs $*
    ;;
    status)
        status $2
    ;;
    update)
        update $2
    ;;
    logs)
      phala_scripts_stop_logs $*
    ;;
    uninstall)
      set +e
      phala_scripts_stop_logs stop > /dev/null 2>&1
      set -e
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
  # return 1
  # Cannot run driectly
  if [ -z "${phala_scripts_dir}" ];then
  printf "\033[0;31m Cannot run driectly \033[0m\n"
    exit 1
  fi

  # set locale lange
  phala_scripts_utils_setlocale

  
  # run main case
  [ "$1" == "debug" ] && {
    # open shell debug
    set -x
    # shift OPTION
    shift
  }

  # default config
  phala_scripts_config

  # check 
  phala_scripts_check


  phala_scripts_case $*

}
txt=$(gettext -se "Phala Status:\n"\
"------------------------------ Script version %s ----------------------------\n"\
"	service name		service status		local node block height\n"\
"--------------------------------------------------------------------------\n"\
"	khala-node		%s			%s / %s\n"\
"	kusama-node		%s			%s / %s\n"\
"	phala-pruntime		%s\n"\
"	phala-pherry		%s			khala %s / kusama %s\n"\
"--------------------------------------------------------------------------\n"\
"	Status check						result\n"\
"--------------------------------------------------------------------------\n"\
"	khala chain synchronization status		%s, difference is %s\n"\
"	kusama chain synchronization status		%s, difference is %s\n"\
"	pherry synchronizes khala chain status		%s, difference is %s\n"\
"	pherry syncs kusama chain status  		%s, difference is %s\n"\
"--------------------------------------------------------------------------\n"\
"	account information		content\n"\
"--------------------------------------------------------------------------\n"\
"	node name           		%s\n"\
"	cores     			%s\n"\
"	GAS account address      	%s\n"\
"	GAS account balance      	%s\n"\
"	stake pool account address	%s\n"\
"	miner/worker public key 	%s\n"\
"	miner registration status	%s\n"\
"	miner score			%s\n"\
"--------------------------------------------------------------------------")


# printf "$txt\n"