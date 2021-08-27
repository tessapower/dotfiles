#!/usr/bin/env bash

# Fail fast and fail early.
#   - Abort script at first error
#   - Attempts to use undefined variable outputs error message and exits
#   - Pipelines return the exit status of the last command in the pipe to fail
#
set -euo pipefail


###############################################################################
# CONSTANTS
###############################################################################

_script=$(basename "${0}")
readonly SCRIPT="${_script}"
unset _script

readonly LOCAL='/home'
readonly REMOTE='/run/media/tp/backup/home'

readonly -a ALWAYS_EXCLUDE=(
    '/lost+found'
)
readonly -a BACKUP_EXCLUDE=(
	'/dev/*'
	'/sys/*'
	'/proc/*'
	'/tmp/*'
	'/run/*'
	'/mnt/*'
	'/media/*'
	'/var/lib/dhcpcd/*'
	'/home/*/.thumbnails/*'
	'/home/*/.cache/mozilla/*'
	'/home/*/.cache/chromium/*'
	'/home/*/.local/share/Trash/*'
)


###############################################################################
# HELP
###############################################################################

print_usage() {
    echo "Usage: ${SCRIPT} [-h|--help] [-d]"
}

print_help() {
    echo "Usage: ${SCRIPT} [-h|--help] [-d]"
    echo ""
    echo "    Description:"
    echo "        Creates an archived backup of everything in '/'. All"
    echo "        directories, symlinks, hard links, permissions, mod times,"
    echo "        ownerships, extended attributes, and executability will"
    echo "        be preserved. Files that have not changed since the last"
    echo "        backup will not be copied."
    echo ""  
    echo "    Options:"
    echo "        --help | -h"
    echo "            Prints this menu"
    echo "        -d"
    echo "            Dry run. Echoes the commands which would be executed to "
    echo "            stdout but doesn't modify anything."
    echo ""
}


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
    local src=''
    local dest=''
    local -a exclusions
    while getopts ":hdbr" o; do
        case "${o}" in
            h)
                print_help
                return 0
                ;;
            d)
                dry_run='--dry-run'
                ;;
            b)
                src="${LOCAL}"
                dest="${REMOTE}"
                exclusions+=("${BACKUP_EXCLUDE[@]}")
                exclusions+=("${ALWAYS_EXCLUDE[@]}")
                ;;
            r)
                src="${REMOTE}"
                dest="${LOCAL}"
                exclusions+=("${ALWAYS_EXCLUDE[@]}")
                ;;
            *)
                print_usage >&2
                return 1
                ;;
        esac
    done
    shift $((OPTIND-1))

    backup 
}

backup() {
    local exclude=''
    
    for dir in "${exclusions[@]}"; do
        exclude="${exclude} --exclude=${dir}"
    done

    # https://wiki.archlinux.org/title/rsync#Full_system_backup
    echo rsync \
        $dry_run \
        --archive \
        --acls \
        --delete \
        --hard-links \
        --info=progress2 \
        --numeric-ids \
        --xattrs \
        $exclude \
        $src \
        $dest
}


###############################################################################
# ENTRY POINT
###############################################################################

# The unusual syntax (versus `main "${@}"`) is a workaround for a bug in some
# non-POSIX compliant versions of bash in which $@ is reported as unbound.
#
main "${@:+$@}"

