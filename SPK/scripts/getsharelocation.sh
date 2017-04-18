#!/bin/sh
#Checking for a specific share on internal volumes
SHARE_CONF_LOC="/usr/syno/etc/share_right.map"
SHARE_CONF=`cat "${SHARE_CONF_LOC}" | awk -F ' *= *' '{ if ($1 ~ /^\[/) section=$1; else if ($1 !~ /^$/) print $1 section "=" $2 }'`

SHARENAME="$@"

SHARE_ID=($(echo "${SHARE_CONF}" | egrep 'display[[:space:]]name.*$' | grep "=${SHARENAME}$" | cut -d "[" -f2 | cut -d "]" -f1))

counter=0
for i in ${SHARE_ID[@]}
   do
   addShare=true
   SHARE_PATH=($(echo "${SHARE_CONF}" | grep "path\[$i\]\=" | cut -d "[" -f2 | cut -d "=" -f2))
   SHARE_NAME=`echo "${SHARE_CONF}" | grep "display name\[$i\]" | cut -d "=" -f 2`
   if [[ $(dirname $SHARE_PATH) = *"volumeUSB"* ]]; then
     DEVICECONNECTED=`echo "${SHARE_CONF}" | grep "guid\[$SHARE_NAME\]" | cut -d "=" -f 2`
     if [[ $DEVICECONNECTED != $i ]]; then
	    addShare=false
     fi
   fi

   if $addShare; then
      ((counter++))
	  SHARE_VAL="$SHARE_PATH"
   else
      SHARE_ID=( "${SHARE_ID[@]/$i}" )
   fi
done

if [[ $counter -eq 0 ]]; then
   SHARE_ID=($(echo "${SHARE_CONF}" | egrep 'comment.*$' | grep "=${SHARENAME}$" | cut -d "[" -f2 | cut -d "]" -f1))
   for i in ${SHARE_ID[@]}
   do
      addShare=true
	  SHARE_PATH=($(echo "${SHARE_CONF}" | grep "path\[$i\]\=" | cut -d "[" -f2 | cut -d "=" -f2))
   SHARE_NAME=`echo "${SHARE_CONF}" | grep "display name\[$i\]" | cut -d "=" -f 2`
      if [[ $(dirname $SHARE_PATH) = *"volumeSATA"* ]]; then
         DEVICECONNECTED=`echo "${SHARE_CONF}" | grep "guid\[$SHARE_NAME\]" | cut -d "=" -f 2`
         if [[ $DEVICECONNECTED != $i ]]; then
		       addShare=false
		 fi
	  fi

   if $addShare; then
       ((counter++))
	   SHARE_VAL="$SHARE_PATH"
	else
	   SHARE_ID=( "${SHARE_ID[@]/$i}" )
	fi
   done

fi

if [[ $counter -eq 1 ]]; then
   echo "${SHARE_VAL}"
fi