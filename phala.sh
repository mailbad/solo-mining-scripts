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

#check shell
phala_shellname="$(ps -o comm= $$)"
if [ "$(basename ${phala_shellname})" != "bash" ];then
  printf "\033[0;31m Please is Bash run! \033[0m\n"
  exit 1
fi

# source 
. ${phala_script_dir}/scripts/main.sh


#check sudo
if [ $UID -ne 0 ];then
  printf "\033[0;31m Please run with sudo! \033[0m\n"
  exit 1
fi

#run main
phala_scripts_main $*