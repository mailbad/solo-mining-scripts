#!/usr/bin/env bash

function phala_scripts_help(){
cat << EOF
  Usage:
	phala [OPTION]...

  Options:
	help					$(phala_scripts_utils_locale "display help information")
	install					$(phala_scripts_utils_locale "install your phala node")
		<dcap>				$(phala_scripts_utils_locale "install DCAP driver")
		<isgx>				$(phala_scripts_utils_locale "install isgx driver")
	uninstall				$(phala_scripts_utils_locale "uninstall your phala scripts")
	start					$(phala_scripts_utils_locale "start mining")
		<khala>				$(phala_scripts_utils_locale "start khala-node")
	stop					$(phala_scripts_utils_locale "stop mining")
		<node>				$(phala_scripts_utils_locale "stop phala-node container")
		<pruntime>			$(phala_scripts_utils_locale "stop phala-pruntime container")
		<pherry>			$(phala_scripts_utils_locale "stop phala-pherry container")
		<bench>				$(phala_scripts_utils_locale "stop phala-pruntime-bench container")
	config					
		<show>				$(phala_scripts_utils_locale "display all configuration of your node")
		<set>				$(phala_scripts_utils_locale "set all configuration")
	status					$(phala_scripts_utils_locale "display the running status of all components")
	update					$(phala_scripts_utils_locale "update all container,and don't clean up the container data")
		<clean>				$(phala_scripts_utils_locale "update all container,and clean up the container data")
		<script>			$(phala_scripts_utils_locale "update the script")
	logs					$(phala_scripts_utils_locale "print all container logs information")
		<node>				$(phala_scripts_utils_locale "print phala-node logs information")
		<pruntime>			$(phala_scripts_utils_locale "print phala-pruntime logs information")
		<pherry>			$(phala_scripts_utils_locale "print phala-pherry logs information")
		<bench>				$(phala_scripts_utils_locale "print phala-pruntime-bench logs information")
	sgx-test				$(phala_scripts_utils_locale "start the mining test program")
	score-test				
		<Parameter>			$(phala_scripts_utils_locale "get the scores of your machine")
EOF
return 0
}

function phala_scripts_main() {
  # Cannot run driectly
  if [ -z "${phala_script_dir}" ];then
  printf "\033[0;31m Cannot run driectly \033[0m\n"
    exit 1
  fi
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
            read -p "$(phala_scripts_utils_locale 'Enter your node name (no spaces)'): " node_name
            if [[ "$node_name" =~ \ |\' ]] || [ -z "$node_name" ]; then
                printf "$(phala_scripts_utils_locale The node name cannot contain spaces, please re-enter!)\n"
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
        sgx_test
    ;;
    *)
        phala_scripts_help
    ;;
  esac
}
