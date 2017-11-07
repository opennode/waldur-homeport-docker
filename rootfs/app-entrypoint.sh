#!/bin/bash
set -eo pipefail

# required variables
: ${MASTERMIND_HOST:="waldur-mastermind-api"}
: ${MASTERMIND_PORT:="8080"}
: ${MASTERMIND_PROTO:="http"}

# optional variables	
: ${OWNER_CAN_MANAGE_CUSTOMER:=true}
: ${ACCOUNTING_MODE:=billing}
: ${LOG_LEVEL:=INFO}

function set_param {

	cat /etc/waldur-homeport/config.json \
    		| jq ".$1=\"$2\"" > /tmp/cfg.tmp \
    		&& mv -f /tmp/cfg.tmp /etc/waldur-homeport/config.json

}

echo "INFO: Welcome to Waldur HomePort!"

if [ -d "/opnd" ]; then

	echo "INFO: Custom configuration directory mount detected as /opnd"
    	echo "INFO: NB! Skipping ENV variables processing and using supplied configuration files!" 
    	echo "INFO: Linking /etc/waldur-homeport -> /opnd"
    	rm -rf /etc/waldur-homeport
    	ln -s /opnd /etc/waldur-homeport

else 

	echo "INFO: Processing required ENV variables..."
	if [ -z "$MASTERMIND_HOST" ] || [ -z "$MASTERMIND_PORT" ] || [ -z "$MASTERMIND_PROTO" ]; then

		echo "ERROR: MasterMind API endpoint variables are not correctly defined! Aborting."
		exit 1

	fi

	API_ENDPOINT="${MASTERMIND_PROTO}://${MASTERMIND_HOST}:${MASTERMIND_PORT}/"
	echo "INFO: Setting apiEndpoint: $API_ENDPOINT"
	set_param apiEndpoint $API_ENDPOINT

	echo "INFO: Processing optional ENV variables..."
	echo "INFO: Setting ownerCanManageCustomer = $OWNER_CAN_MANAGE_CUSTOMER"
	set_param ownerCanManageCustomer $OWNER_CAN_MANAGE_CUSTOMER
	echo "INFO: Setting accountingMode = $ACCOUNTING_MODE"
	set_param accountingMode $ACCOUNTING_MODE

fi

echo "INFO: Spawning $@"
exec /usr/local/bin/tini -- "$@"
