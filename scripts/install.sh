#!/usr/bin/env bash

function phala_scripts_install_aptdependencies() {
  if [ "$1" == "uninstall" ];then
    shift
    phala_scripts_log info "Uninstall Apt dependencies" cut
    apt autoremove -y $*
    return 0
  fi

  _default_soft=$*
  phala_scripts_log info "Apt update" cut
  # modify cn 
  sed -i 's#http://archive.ubuntu.com#https://mirrors.ustc.edu.cn#g' /etc/apt/sources.list
  apt update
  if [ $? -ne 0 ]; then
    phala_scripts_log error "Apt update failed."
  fi
  phala_scripts_log info "Installing Apt dependencies" cut
  apt install -y ${_default_soft[@]}
}

function phala_scripts_install_otherdependencies(){
  if [ "$1" == "uninstall" ];then
    shift
    phala_scripts_log info "Uninstall other dependencies" cut
    for _package in $*;do
      if ! type $_package > /dev/null 2>&1;then
        :
      else
        case $_package in
          docker)
            apt autoremove -y docker-ce
            find /etc/apt/sources.list.d -type f -name docker.list* -exec rm -f {} \;
          ;;
          node)
            apt autoremove -y nodejs
            find /etc/apt/sources.list.d -type f -name nodesource.list* -exec rm -f {} \;
          ;;
          *)
            apt autoremove -y $_package
          ;;
        esac
      fi
    done
    return 0
  fi

  _other_soft=$*
  phala_scripts_log info "Installing other dependencies" cut
  for _package in ${_other_soft};do
    if ! type $_package >/dev/null 2>&1;then
      case $_package in
        docker|docker-compose)
          find /etc/apt/sources.list.d -type f -name docker.list* -exec rm -f {} \;
          if [ ! -f "${phala_scripts_tools_dir}/get-docker.sh" ];then
            curl -fsSL get.docker.com -o ${phala_scripts_tools_dir}/get-docker.sh
          fi

          [ ! type docker >/dev/null 2>&1 ] && {
            sh ${phala_scripts_tools_dir}/get-docker.sh --mirror Aliyun
            systemctl start docker
          }
          apt install -y docker-compose
        ;;
        node)
          find /etc/apt/sources.list.d -type f -name nodesource.list* -exec rm -f {} \;
          curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
          apt-get install -y nodejs
        ;;
      esac
    fi
  done
}

function phala_scripts_install_sgx() {
  _kernel_version=$(uname -r)
  if [ "$1" == "uninstall" ];then
    shift
    phala_scripts_log info "Uninstall Install Sgx device" cut
    apt autoremove -y libsgx-enclave-common sgx-aesm-service
    [[ "${_kernel_version}" =~ "5.4" ]] && apt autoremove -y intel-sgx-dkms
    return 0
  fi
  phala_scripts_log info "Kernel ${_kernel_version}" cut
  phala_scripts_log info "Install Sgx device"
  if [[ "${_kernel_version}" =~ "5.13" ]];then
    phala_scripts_install_sgx_default
  elif [[ "${_kernel_version}" =~ "5.4" ]];then
    phala_scripts_install_sgx_k5_4
    phala_scripts_install_sgx_default
  else
    return 1
  fi
}

function phala_scripts_install_sgx_default() {
  # install aesm encalave
  curl -fsSL https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | apt-key add - && \
  add-apt-repository "deb https://download.01.org/intel-sgx/sgx_repo/ubuntu focal main" && \
  apt install -y libsgx-enclave-common sgx-aesm-service
}

function phala_scripts_install_sgx_k5_4(){
  curl -sSL "https://download.fortanix.com/linux/apt/fortanix.gpg" | sudo -E apt-key add - && \
  add-apt-repository "deb https://download.fortanix.com/linux/apt xenial main"  && \
  apt install -y intel-sgx-dkms
}