#!/bin/sh

set -eu

Main()
{
  ##############################################################################
  # INPUT
  ##############################################################################

    local home_dir=${1? Missing the home dir !!!}
    local oh_my_zsh_theme=${2:-robbyrussell}


  ##############################################################################
  # EXECUTION
  ##############################################################################

    apt install -y --no-install-recommends zsh

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

    cp -v /root/.zshrc "${home_dir}"/.zshrc

    cp -r /root/.oh-my-zsh "${home_dir}"/.oh-my-zsh

    sed -i "s|/root|${home_dir}|g" "${home_dir}"/.zshrc

    sed -i "s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"${oh_my_zsh_theme}\"/g" "${home_dir}"/.zshrc
}

Main "${@}"
