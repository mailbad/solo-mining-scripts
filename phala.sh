#!/usr/bin/env bash
# Error Quit
set -e

# check script dir
# other system readlink -f [False]
if [ -L $0 ];then
  phala_script_dir=$(cd $(dirname $(readlink $0));pwd)
else
  phala_script_dir=$(cd $(dirname $0);pwd)
fi

# source 
. ${phala_script_dir}/scripts/utils.sh
. ${phala_script_dir}/scripts/log.sh
. ${phala_script_dir}/scripts/main.sh

#check shell
phala_shellname="$(ps -o comm= $$)"
if [ "$(basename ${phala_shellname})" != "bash" ];then
  phala_scripts_log error "$(phala_scripts_utils_locale 'Please is Bash run!')"
fi

#check sudo
if [ $UID -ne 0 ];then
  phala_scripts_log error "$(phala_scripts_utils_locale 'Please run with sudo!')"
fi

#run main
phala_scripts_main $*