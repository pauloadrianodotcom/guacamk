#!/bin/bash

start=$SECONDS




#1 - Autenticacao

#Apache Guacamole
GUACAMOLESERVER=REPLACE
#Username
#Password

#Checkmk
#Username
#Password

export TOKEN=$(curl -s -k -X POST  https://$GUACAMOLESERVER/api/tokens -d 'username=guacadmin&password=pa55wrd' | jq -r .authToken)
echo $GUACAMOLESERVER
echo ====================================================
echo 1 - Retrieving connection ids from Apache Guacamole
curl -s -k -X GET -H 'Content-Type: application/json' https://$GUACAMOLESERVER/api/session/data/postgresql/connections?token=$TOKEN | jq | grep -o '"identifier":\s*"[0-9]\+"' | tr -d '"identifier": ' > ./files/gcm_ids.file
echo ====================================================
echo 2 - Retrieving all connections details from Apache Guacamole
curl -s -k -X GET -H 'Content-Type: application/json' https://$GUACAMOLESERVER/api/session/data/postgresql/connections?token=$TOKEN | jq > ./files/gcm.json
filename="./files/gcm_ids.file"
while IFS= read -r CONNECTIONID;
do
CHECKCONNECTIONID=$(cat ./files/gcm.json | jq --arg CONNECTIONID "$CONNECTIONID" '.[$CONNECTIONID].name' | tr -d '"')
CHECKCONNECTIONPROTOCOL=$(cat ./files/gcm.json | jq --arg CONNECTIONID "$CONNECTIONID" '.[$CONNECTIONID].protocol' | tr -d '"')
CHECKCONNECTIONIP=$(curl -s -k -X GET -H 'Content-Type: application/json' https://$GUACAMOLESERVER/api/session/data/postgresql/connections/$CONNECTIONID/parameters?token=$TOKEN | jq .hostname | tr -d '"')
echo $CONNECTIONID,$CHECKCONNECTIONID,$CHECKCONNECTIONIP,$CHECKCONNECTIONPROTOCOL >> ./files/gcm_connections.file
done < "$filename"
echo ====================================================
echo 3 - Retrieving current hosts from Checkmk
./cmk_gethosts.sh | grep id > ./files/cmk_hosts.file
echo ====================================================
echo 4 - Create connections on Checkmk

filename="./files/gcm_connections.file"

while IFS=',' read -r connectionid name ip protocol; do
if grep -q "$name" ./files/cmk_hosts.file
then
echo Already on Checkmk - Connection ID: $connectionid Name: $name $ip $protocol
else
echo NOT on Checkmk - Connection ID: $connectionid Name: $name $ip $protocol    
./cmk_createhosts.sh $connectionid $name $ip $protocol > ./logs/mklog_$name.log
fi
done < "$filename"

end=$SECONDS
duration=$((end - start))
echo "Execution time: $duration seconds"



exit
echo ===================================================
echo 5 - Activate changes on Checkmk
./cmk_activatechanges.sh
echo ====================================================
echo 6 -Cleanup
echo Removing gcm_ids.file
rm ./files/gcm_ids.file
echo Removing gcm_connections.file
rm ./files/gcm_connections.file
echo Removing cmk_hosts.file
rm ./files/cmk_hosts.file
echo ====================================================
exit
