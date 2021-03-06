#!/bin/bash

set -u

# Check curl
if ! command -v curl > /dev/null 2>&1; then
    cat << EOF >&2
curl command not found.

Install it with the package manager of your OS and then run this script again.
EOF
    exit 1;
fi

# Check Vim version
case "$(uname -s)" in
    "Darwin")
        case "$(command -v vim)" in
            "/usr/bin/vim")
                cat << EOF >&2
Unsupported Vim version: /usr/bin/vim

Install a version that supports Python 3 with 'brew install vim'.
EOF
                exit 1;
                ;;
        esac
        ;;
esac

# Paths
vimdir=${HOME}/.vim
vimrc=${vimdir}/vimrc
cachedir=${XDG_CACHE_HOME:-$HOME/.cache}/vim

# Get user option
force=false
dirs_only=false
update=false
if [ $# -eq 1 ]; then
    case "$1" in
        -f) force=true ;;
        -d) dirs_only=true ;;
        -u) update=true ;;
        *) echo "Unknown option."; exit 2 ;;
    esac
fi

# Check ~/.vim directory
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ "${script_dir}" != "${vimdir}" ]; then
    echo "Clone the repository in ${vimdir}, not in ${script_dir}"
    exit 1
fi

# Create directory for bundles
if [ ${force} = true ]; then
    rm -rf "${vimdir}/bundle"
fi
mkdir -p "${vimdir}/bundle"
mkdir -p "${vimdir}/autoload"

# Create directory for swap/backup/undo files
mkdir -p "${cachedir}"/{swap,backup,undo}
if [ ${dirs_only} = true ]; then
    exit
fi

# Install package manager
vimplug_url=https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vimplug_vim=${vimdir}/autoload/plug.vim
if [ ! -f "${vimplug_vim}" ]; then
    echo -e "Installing vim-plug package manager..."
    sleep 1
    if curl -fLo "${vimplug_vim}" --create-dirs ${vimplug_url}; then
        echo -e "\nPackage manager installed sucessfully"
        echo -e "https://github.com/junegunn/vim-plug#readme"
    else
        echo -e "\nCould not install package manager"
        exit
    fi
elif [ ${update} = false ]; then
    echo -e "Package manager already installed"
fi

# Install plugins
if [ ${update} = false ]; then
    log_file=$(mktemp 2>/dev/null || mktemp -t 'tmp')
    trap 'rm -f "$log_file"' EXIT
    echo -e "\nInstalling plugins..."
    sleep 1
    vim -N -u "${vimrc}" -U NONE -i NONE \
        -c "try | PlugInstall | finally | w ${log_file} | qall! | endtry" \
        -e
    cat "${log_file}"
    if grep -q '^x ' "${log_file}"; then
        echo -e "\nCould not install all plugins. Check log."
    fi
    echo
else
    vim -N -u "${vimrc}" -U NONE -i NONE \
        -c "PlugUpgrade | PlugSafeUpdate | echomsg 'Plugins updated. You can exit Vim.'"
    exit $?
fi

# Spell files
echo -e "\nGetting spell files..."
sleep 1
spell_url=http://ftp.vim.org/vim/runtime/spell
spell_dir=${vimdir}/spell
mkdir -p "${spell_dir}"
for idiom in es en; do
    for enc in latin1 utf-8; do
        for ver in spl sug; do
            spell_name=${idiom}.${enc}.${ver}
            spell_file=${spell_dir}/${spell_name}
            if [ ${force} = true ]; then
                rm -f "${spell_file}"
            fi
            if [ ! -f "${spell_file}" ]; then
                echo "- ${spell_name}..."
                curl -fLo "${spell_file}" "${spell_url}/${spell_name}"
            fi
        done
    done
done

echo -e "\nDone!"
