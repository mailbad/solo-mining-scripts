#!/usr/bin/env bash

# source 
. ${phala_scripts_dir}/scripts/utils.sh
. ${phala_scripts_dir}/scripts/log.sh
. ${phala_scripts_dir}/scripts/config.sh
. ${phala_scripts_dir}/scripts/check.sh
. ${phala_scripts_dir}/scripts/install.sh


function phala_scripts_help(){
phala_scripts_utils_gettext "Usage:\n"\
"	phala [OPTION]...\n"\
"\n"\
"Options:\n"\
"	help					display help information\n"\
"	install					install your phala node\n"\
"		<dcap>				install DCAP driver\n"\
"		<isgx>				install isgx driver\n"\
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

function phala_scripts_case() {
  case "$1" in
    install)
      install $2
    ;;
    config)
      config $2
    ;;
    start)
        check_version
        start
    ;;
    presync)
        local node_name
        while true ; do
            read -p "$(phala_scripts_utils_gettext 'Enter your node name (no spaces)'): " node_name
            if [[ "$node_name" =~ \ |\' ]] || [ -z "$node_name" ]; then
                printf "$(phala_scripts_utils_gettext The node name cannot contain spaces, please re-enter!)\n"
            else
                sed -i "7c NODE_NAME=$node_name" $installdir/.env
                break
            fi
        done
        cd $installdir
        docker-compose up -d
    ;;
    stop)
        stop $2
    ;;
    status)
        status $2
    ;;
    update)
        update $2
    ;;
    logs)
        logs $2
    ;;
    uninstall)
        uninstall
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

  # check 
  phala_scripts_check

  # config
  phala_scripts_config

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