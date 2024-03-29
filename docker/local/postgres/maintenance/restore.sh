#! /usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

working_dir="$(dirname ${0})"

source "${working_dir}/_sourced/constants.sh"
source "${working_dir}/_sourced/messages.sh"

# determine if the variable "${1}" is unset or set to an empty string.
if [[ -z "${1+x}" ]]; then
  message_error "Backup filename is not specified yet it is a required parameter. Make sure you provide one and try again."
  exit 1
fi

backup_filename="${BACKUP_DIR_PATH}/${1}"

# checking whether a file specified by the backup_filename variable exists or not
if [[ ! -f "${backup_filename}" ]]; then
  message_error "No backup with the specified backup filename was found.
  Check out the 'backups' maintenance script output to see if there is one and try again."
  exit 1
fi

message_welcome "Restoring the ${POSTGRES_DB} database from the ${backup_filename} backup..."

# checking whether the POSTGRES_USER environment variable is set to the string "postgres" or not.
if [[ "${POSTGRES_USER}" == "postgres" ]]; then
  message_error "Restoring as 'postgres' user is not allowed. Assign 'POSTGRES_USER' env with another value and try again."
  exit 1
fi

export PGHOST=${POSTGRES_HOST}
export PGPORT=${POSTGRES_PORT}
export PGUSER=${POSTGRES_USER}
export PGPASSWORD=${POSTGRES_PASSWORD}
export PGDATABASE=${POSTGRES_DB}

message_info "Dropping the database..."

dropdb "${PGDATABASE}"

message_info "Creating a new database..."

createdb --owner="${PGUSER}"

message_info "Applyting the backup to the new database..."

gunzip -c "${backup_filename}" | psql "${POSTGRES_DB}"

message_success "The '${POSTGRES_DB}' database was successfully restored from the '${BACKUP_FILENAME}' backup file."