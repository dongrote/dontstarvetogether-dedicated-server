#!/bin/bash

drop_privileges_and_run_server() {
  su -p --group "${DST_GROUP}" -c "$1" "${DST_USER}" &    
}

start_world() {
  drop_privileges_and_run_server dontstarve_world_server
}

start_caves() {
  drop_privileges_and_run_server dontstarve_caves_server
}

sleep_forever() {
  sleep inf
}

if [[ -d "${DST_USER_DATA_PATH}/DoNotStarveTogether/MyDediServer" ]]
then
  start_world
  start_caves
  sleep_forever
else
  echo "Extract MyDediServer.zip into your ${DST_USER_DATA_PATH} directory mount."
fi
