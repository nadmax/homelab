#!/usr/bin/env bash

###############################################################
#
#  DESCRIPTION: Instalaltion de OPENTOFU à partir des releases GITHUB.
#
#  TODO: Demande de version installée et à venir.
###############################################################

source "$(dirname $0)/lib_functions.sh"

version="1.8.9"

if [[ ! PATH_COMMAND = "$(type -p "tofu")" ]] || [[ -z ${PATH_COMMAND} ]]; then
    version_installed=$($(which tofu) -version | head -n1 | awk -F' ' '{print $2}' | tail -c+2)
    echo "opentoufu est déjà installé avec la version ${version_installed}"

else

    echo "Installation d'opentofu en version ${version}."
    archive="tofu_${version}_linux_amd64.tar.gz"

    wget --quiet --show-progress "https://github.com/opentofu/opentofu/releases/download/v${version}/${archive}" --output-document="/tmp/${archive}"

    tar -xvzf "/tmp/${archive}" --one-top-level=/tmp/tofu

    install --preserve-timestamps /tmp/tofu/tofu --target-directory=/usr/local/bin/

fi

# Shell Tab-completion
# https://opentofu.org/docs/cli/commands/#shell-tab-completion
LINE='complete -C /usr/local/bin/tofu tofu'
FILE="${HOME}/.bashrc"
#grep -qF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"
echo "$LINE"
echo "$FILE"
grep -qF -v -- "${LINE}" "${FILE}"
if [ $? -ne 0 ]; then
    echo "Instalaltion de la completion pour opentofu."
    tofu -install-autocomplete
    source ${FILE}
fi
