#!/usr/bin/env bash

# Fail fast and fail early.
set -euo pipefail


###############################################################################
# CONFIGURATION
###############################################################################

# The format is 'source file' -> 'destination'.
# For full setup (packages + symlinks), use the setup scripts instead:
#   macOS:       ./setup-macos.sh
#   Ubuntu/WSL:  ./setup-ubuntu.sh
#   Windows:     .\setup-windows.ps1
#
declare -a FILES=(
    'git/gitconfig               -> ~/.gitconfig'
    'git/gitignore_global        -> ~/.gitignore_global'
    'git/tigrc                   -> ~/.tigrc'
    'vim/autoload/plug.vim       -> ~/.vim/autoload/plug.vim'
    'vim/vimrc                   -> ~/.vimrc'
    'config/starship.toml        -> ~/.config/starship.toml'
    'config/delta/themes.gitconfig -> ~/.config/delta/themes.gitconfig'
)

# OS-specific gitconfig overlay
case "$(uname -s)" in
    Darwin*)
        FILES+=('git/gitconfig-macos -> ~/.gitconfig-os')
        ;;
    Linux*)
        FILES+=('git/gitconfig-linux -> ~/.gitconfig-os')
        ;;
esac


###############################################################################
# CONSTANTS
###############################################################################

_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
readonly DIR="${_dir}"
unset _dir

_script=$(basename "${0}")
readonly SCRIPT="${_script}"
unset _script


###############################################################################
# MAIN
###############################################################################

main() {

    # Be nice and check for all common help flags
    if [[ $# -gt 0 ]]; then
        if [[ "${1}" = "help" ]] || [[ "${1}" = "--help" ]]; then
	    print_help
	    return 0
	fi
    fi

    local dry_run=''
    local force='false'

    while getopts ":hfdl" o; do
        case "${o}" in
            h)
                print_help
                return 0
                ;;
            f)
                force='true'
                ;;
            d)
                dry_run='echo'
                ;;
            l)
                list_destinations
                return 0
                ;;
            *)
                print_usage >&2
                return 1
                ;;
        esac
    done
    shift $((OPTIND-1))

    link_files "${dry_run}"
}


###############################################################################
# FUNCTIONS
###############################################################################

print_usage() {
    echo "Usage: ${SCRIPT} [-h|--help] [-f] [-d] [-l]"
}

print_help() {
    echo "Usage: ${SCRIPT} [-h|--help] [-f] [-d] [-l]"
    echo ""
    echo "    Description:"
    echo "        Relinks config files to their usual destinations."
    echo "        For full setup (packages + symlinks), use the setup scripts:"
    echo "          macOS:       ./setup-macos.sh"
    echo "          Ubuntu/WSL:  ./setup-ubuntu.sh"
    echo "          Windows:     .\\setup-windows.ps1"
    echo ""
    echo "    Options:"
    echo "        --help | -h"
    echo "            Prints this menu"
    echo "        -d"
    echo "            Dry run. Echoes the commands which would be executed to "
    echo "            stdout but doesn't modify anything."
    echo "        -f"
    echo "            Force. Overwrites any existing files."
    echo "        -l"
    echo "            Lists the files that would be installed by this program. Each"
    echo "            full path is printed on a new line making the output suitable"
    echo "            for piping to xargs or using as a for-loop input, i.e.:"
    echo ""
    echo "                for file in \$(${SCRIPT} -l); do"
    echo "                    ls -lah \"\$file\""
    echo "                done"
    exit 1
}

list_destinations() {
    for mapping in "${FILES[@]}"; do
        file_dest "${mapping}"
    done
}

file_source() {
    echo "$1" | awk 'BEGIN { FS = " +-> +" } END { print $1 }'
}

file_dest() {
    dest=$(echo "$1" | awk 'BEGIN { FS = " +-> +" } END { print $2 }')
    echo "${dest/#\~/$HOME}"
}

link_files() {
    local created_links='false'

    local file
    local fq_src
    local fq_dest
    local dest_dir
    for mapping in "${FILES[@]}"; do
        file=$(file_source "${mapping}")
        fq_src="${DIR}/${file}"
        fq_dest=$(file_dest "${mapping}")
        dest_dir=$(dirname "${fq_dest}")

        if [[ ! -e "${fq_src}" ]]; then
            echo "${fq_src} doesn't exist" 1>&2
            exit 1
        fi

        if [[ -d "${fq_src}" && -d "${fq_dest}" ]]; then
            echo "${fq_dest} is a directory and already exists — skipping ${file}"
            continue
        fi

        if [[ "${force}" == 'true' ]] || [[ ! -e "${fq_dest}" ]]; then
            if [[ ! -d "${dest_dir}" ]]; then
                $dry_run mkdir -p "${dest_dir}"
            fi
            $dry_run ln -fs "${fq_src}" "${fq_dest}"
            created_links='true'
        fi
    done

    if [[ "${created_links}" == 'false' ]]; then
        echo "no changes required"
    fi

    echo ""
    echo "Done :)"
}


###############################################################################
# ENTRY POINT
###############################################################################

main "${@:+$@}"
