#!/usr/bin/env bash

function phala_scripts_install_sgx() {
  _kernel_version=$(uname -r)
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