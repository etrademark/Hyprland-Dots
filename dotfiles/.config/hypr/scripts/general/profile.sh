#!/bin/bash

asusctl profile --next
profile=$(asusctl profile --profile-get | grep -Po 'Active profile is \K[^ ]+' | tr '[:upper:]' "[:lower:]")

if [ $profile == "quiet" ]; then
  profileNumber=33
elif [ $profile == "balanced" ]; then
  profileNumber=67
elif [ $profile == "performance" ]; then
  profileNumber=100
else profileNumber=0; fi
notify-send -h string:x-canonical-private-synchronous:volume_notif "Changed profile to ${profile}" -e -h int:value:$profileNumber -u low
