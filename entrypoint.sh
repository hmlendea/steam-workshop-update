#!/bin/bash

if [[ -z "${STEAM_USERNAME}" ]]; then
  echo "FATAL: Environment variable STEAM_USERNAME is required but not provided."
  exit 1
fi

if [[ -z "${STEAM_PASSWORD}" ]]; then
  echo "FATAL: Environment variable STEAM_PASSWORD is required but not provided."
  exit 1
fi

cat << EOF > /home/steam/workshop.vdf
"workshopitem"
{
  "appid" "${INPUT_APPID}"
  "contentfolder" "${GITHUB_WORKSPACE}/${INPUT_PATH}"
  "changenote" "${INPUT_CHANGENOTE}"
  "publishedfileid" "${INPUT_ITEMID}"
}
EOF

cat '/home/steam/workshop.vdf'

if [[ -z "${STEAM_2FASEED}" ]]; then
  /home/steam/steamcmd/steamcmd.sh +@ShutdownOnFailedCommand 1 +login ${STEAM_USERNAME} ${STEAM_PASSWORD} +workshop_build_item /home/steam/workshop.vdf +quit
else
  export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
  STEAM_2FACODE=$(/home/steam/steam-totp ${STEAM_2FASEED})
  
  if [[ $? -ne 0 ]]; then
    exit 1
  fi
  
  /home/steam/steamcmd/steamcmd.sh +@ShutdownOnFailedCommand 1 +login ${STEAM_USERNAME} ${STEAM_PASSWORD} ${STEAM_2FACODE} +workshop_build_item /home/steam/workshop.vdf +quit
fi

[ $? -eq 0 ] && exit 0 || (
    echo 'Showing stderr.txt:'
    echo "$(cat /home/steam/Steam/logs/stderr.txt)"
    echo
    echo 'Showing workshop_log.txt:'
    echo "$(cat /home/steam/Steam/logs/workshop_log.txt)"

    exit 1
)
