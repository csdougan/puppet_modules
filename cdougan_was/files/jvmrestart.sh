#!/bin/bash

[[ -e "/data/WebSphere/AppServer/properties/profileRegistry.xml" ]] && basedir="/data/WebSphere"
[[ -e "/opt/IBM/WebSphere/AppServer/properties/profileRegistry.xml" ]] && basedir="/opt/IBM/WebSphere"
registryfile="${basedir}/AppServer/properties/profileRegistry.xml"
profileName="$(egrep -v "<[/]|.profiles>" $registryfile|grep -vi dmgr| awk -F= '{print $4}'|awk -F\" '{print $2}')"
if [[ -e ${basedir}/profiles ]]; then
  profiledir=${basedir}/profiles
elif [[ -e ${basedir}/AppServer/profiles ]]; then
  profiledir=${basedir}/AppServer/profiles
else
  exit 1
fi
serverName=$(ls ${profiledir}/${profileName}/servers/|grep -v nodeagent)
scriptdir="${profiledir}/${profileName}/bin"
sudo -u wasuser bash -c "${scriptdir}/stopServer.sh ${serverName}"
sleep 10
sudo -u wasuser bash -c "${scriptdir}/startServer.sh ${serverName}"
