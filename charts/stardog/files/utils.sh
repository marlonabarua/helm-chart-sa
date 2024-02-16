
function wait_for_start {
    (
    HOST=${1}
    PORT=${2}
    PROTOCOL=${3}
    # Wait for stardog to be running
    RC=1
    COUNT=0
    set +e
    while [[ ${RC} -ne 0 ]];
    do
      if [[ ${COUNT} -gt 600 ]]; then
          return 1;
      fi
      COUNT=$(expr 1 + ${COUNT} )
      sleep 1
      curl -v  ${PROTOCOL}://${HOST}:${PORT}/admin/healthcheck
      RC=$?
    done
    # Give it a second to finish starting up
    sleep 20

    return 0
    )
}

function change_pw {
    (
    set +e
    HOST=${1}
    PORT=${2}
    PROTOCOL=${3}

    echo "/opt/stardog/bin/stardog-admin --server ${PROTOCOL}://${HOST}:${PORT} user passwd -N xxxxxxxxxxxxxx"
    NEW_PW=$(cat /etc/stardog-password/adminpw)
    /opt/stardog/bin/stardog-admin --server ${PROTOCOL}://${HOST}:${PORT} user passwd -N ${NEW_PW}
    if [[ $? -eq 0 ]];
    then
	    echo "Password successfully changed"
	    return 0
    else
    	curl --fail -u admin:${NEW_PW} ${PROTOCOL}://${HOST}:${PORT}/admin/status
    	RC=$?
    	if [[ $RC -eq 0 ]];
      then
        echo "Default password was already changed"
        return 0
      elif [[ $RC -eq 22 ]]
      then
        echo "HTTP 4xx error"
        return $RC
      else
        echo "Something else went wrong"
        return $RC
      fi
    fi
    )
}

function add_roles {
    (
    set +e
    HOST=${1}
    PORT=${2}
    PROTOCOL=${3}
    ROLE=${4}
    

    echo "/opt/stardog/bin/stardog-admin --server ${PROTOCOL}://${HOST}:${PORT} user passwd -N xxxxxxxxxxxxxx"
    NEW_PW=$(cat /etc/stardog-password/adminpw)
    /opt/stardog/bin/stardog-admin --server ${PROTOCOL}://${HOST}:${PORT} user passwd -N ${NEW_PW}
    if [[ $? -eq 0 ]];
    then
	    echo "Role ${ROLE} successfully Add"
	    return 0
    else
    	curl --fail -u admin:${NEW_PW} ${PROTOCOL}://${HOST}:${PORT}/admin/status
    	RC=$?
    	if [[ $RC -eq 0 ]];
      then
        echo "Default password was already changed"
        return 0
      elif [[ $RC -eq 22 ]]
      then
        echo "HTTP 4xx error"
        return $RC
      else
        echo "Something else went wrong"
        return $RC
      fi
    fi
    )
}

function make_temp {
    (
    set +e
    TEMP_PATH=${1}

    if [ ! -d "$TEMP_PATH" ]; then
      mkdir -p $TEMP_PATH
      if [ $? -ne 0 ]; then
        echo "Could not create stardog tmp directory ${TEMP_PATH}" >&2
        return 1
      fi
    fi
    )
}

function get_license {
    (
    set +e
    LICENSE_SERVER_ENABLED="${1}"
    LICENSE_SERVER=${2}
    LICENSE_TYPE=${3}
    LICENSE_NAME=${4}
    LICENSE_PATH=${5}
    MOUNTED_LICENSE_PATH="/etc/stardog-license/stardog-license-key.bin"

    if [ $LICENSE_SERVER_ENABLED != "true" ]; then
      if [ -f "${LICENSE_PATH}" ]; then
        echo "License server not enabled, using pre-exiting license"
        return 0
      fi

      if [ -f "${MOUNTED_LICENSE_PATH}" ]; then
        cp $MOUNTED_LICENSE_PATH $LICENSE_PATH
        RC=$?
        if [[ $RC -eq 0 ]]; then
          echo "Found a mounted license secret at ${MOUNTED_LICENSE_PATH} and moved it into place at ${LICENSE_PATH}"
          return 0
        else
          echo "Found a mounted license secret at ${MOUNTED_LICENSE_PATH} but could not copy it. Can't start stardog"
          return $RC
        fi
      fi

      echo "No license server provided and no pre-existing license exists. Can't start stardog."
      return 1
    fi

    # make sure we have network
    sleep 5

    PAYLOAD="{\"name\":\"${LICENSE_NAME}\", \"email\":\"ops@stardog.com\", \"company\": \"Stardog Union\", \"version\": \"8\", \"expiresIn\": \"365\", \"clusterSize\": 3, \"flavor\": \"${LICENSE_TYPE}\"}"
    curl --fail -X POST -H 'Content-Type: application/json' -v "${LICENSE_SERVER}" -d "${PAYLOAD}" --output "${LICENSE_PATH}"
    RC=$?

    if [[ $RC -eq 0 ]]; then
      echo "License successfully obtained from ${LICENSE_SERVER} of type ${LICENSE_TYPE}"
    elif [ -f "${LICENSE_PATH}" ]; then
      echo "Could not obtain license from license server ${LICENSE_SERVER}, failing back to using pre-existing license"
      return 0
    else
      echo "Could not obtain license from license server ${LICENSE_SERVER} and no pre-existing license to fall back on. Can't start stardog"
    fi
    return $RC
    )
}
