#!/bin/sh

# src: https://github.com/jhubig/FritzBoxShell

fritzbox_user='fritz9150'
fritzbox_pw_path='/run/user/1000/secrets/wlan-password'
fritzbox_pw=''
if [ -f "$fritzbox_pw_path" ]; then
  fritzbox_pw=`cat "$fritzbox_pw_path"`
else
  read -p "Enter wlan password: " fritzbox_pw
fi
fritzbox_ip='fritz.box'

get_wlan_state_x() {
  wlanNumber=$1
  action='GetInfo'
  location="/upnp/control/wlanconfig$wlanNumber"
  uri="urn:dslforum-org:service:WLANConfiguration:$wlanNumber"

  # echo $(curl -s -k -m 5 --anyauth -u "$BoxUSER:$BoxPW" "http://$BoxIP:49000$location" -H 'Content-Type: text/xml; charset="utf-8"' -H "SoapAction:$uri#$action" -d "<?xml version='1.0' encoding='utf-8'?><s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/' xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'><s:Body><u:$action xmlns:u='$uri'></u:$action></s:Body></s:Envelope>")
  # exit

  r=$(curl \
    -s \
    -k \
    -m 5 \
    --anyauth \
    -u "$fritzbox_user:$fritzbox_pw" \
    "http://$fritzbox_ip:49000$location" \
    -H 'Content-Type: text/xml; charset="utf-8"' \
    -H "SoapAction:$uri#$action" \
    -d "<?xml version='1.0' encoding='utf-8'?><s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/' xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'><s:Body><u:$action xmlns:u='$uri'></u:$action></s:Body></s:Envelope>" \
    | grep NewEnable \
    | awk -F">" '{print $2}' \
    | awk -F"<" '{print $1}')
  echo $r
}

set_wlan_x() {
  onOff=$1
  wlanNumber=$2
  action='SetEnable'
  location="/upnp/control/wlanconfig$wlanNumber"
  uri="urn:dslforum-org:service:WLANConfiguration:$wlanNumber"
  curl \
    -k \
    -m 5 \
    --anyauth \
    -u "$fritzbox_user:$fritzbox_pw" \
    "http://$fritzbox_ip:49000$location" \
    -H 'Content-Type: text/xml; charset="utf-8"' \
    -H "SoapAction:$uri#$action" \
    -d "<?xml version='1.0' encoding='utf-8'?><s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/' xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'><s:Body><u:$action xmlns:u='$uri'><NewEnable>$onOff</NewEnable></u:$action></s:Body></s:Envelope>" \
    -s > /dev/null
}

toggle_wlan_x() {
  wlanNumber=$1
  onOff=0
  if [ $(get_wlan_state_x $wlanNumber) = "0" ]; then
    onOff=1
  fi
  set_wlan_x $onOff $wlanNumber
}

toggle_wlan_2G() {
  toggle_wlan_x 1
}

toggle_wlan_5G() {
  toggle_wlan_x 2
}

toggle_wlan_5G
