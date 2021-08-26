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

readonly BACKUP_SRC='/home'
readonly BACKUP_DEST='/run/media/tp/backup/home'

readonly RESTORE_SRC='/run/media/tp/backup/home'
readonly RESTORE_DEST='/home'

declare -a ALWAYS_EXCLUDE=(
    '/lost+found'
)
declare -a BACKUP_EXCLUDE=(
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
    local exclusions=''
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
            	src="${BACKUP_SRC}"
            	dest="${BACKUP_DEST}"
            	exclusions=$BACKUP_EXCLUDE
            	;;
            r)	src="${RESTORE_SRC}"
            	dest="${RESTORE_DEST}"
            	;;
            *)
                print_usage >&2
                return 1
                ;;
        esac
    done
    shift $((OPTIND-1))

    backup $exclusions "${src}" "${dest}"
}

backup() {
    local exclusions=''
    
    for dir in "${1}"; do
        exclusions="${exclusions} --exclude=${dir}"
    done

	for dir in "${ALWAYS_EXCLUDE[@]}"; do
		exclusions="${exclusions} --exclude=${dir}"
	done
    
    local src="${2}"
    local dest="${3}"

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
		$exclusions \
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

