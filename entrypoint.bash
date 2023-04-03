#! /bin/bash
set -eE

LETCD="/usr/local/etc/mariadb"
CONFD="${LETCD}/conf.d"
DATAD="/srv/data/mariadb"
DATAS="data log tmp"

# check if any configuration is present
if ! [[ -n $(ls -1A ${CONFD}) ]]; then
    echo "ERROR: there are no configuration files to be included in directory: '${CONFD}' " >&2
    exit 100
fi

# create main directory in writable volume
if ! [[ -d ${DATAD} ]]; then
  mkdir -p "${DATAD}"
  chmod ug=rwX,o-rX -R "${DATAD}"
fi

# create subdirectories in main directory
for SUBDIR in ${DATAS}; do 
  if ! [[ -d "${DATAD}/${SUBDIR}" ]]; then
    mkdir -p "${DATAD}/${SUBDIR}"
    chmod ug=rwX,o-rX -R "${DATAD}/${SUBDIR}"
  fi
done

# if datadir is empty, run just shell
if ! [[ -n $(ls -1A ${DATAD}/data) ]]; then
  exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
else
  exec /usr/bin/mariadbd --defaults-file=${LETCD}/my.cnf
fi
