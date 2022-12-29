#!/bin/bash

SERVER_SMA="192.168.1.50"
if [ ! -f /tmp/sma.conf ]; then
	SID=$(curl -s "http://${SERVER_SMA}/dyn/login.json"  --data-raw '{"right":"istl","pass":"26042019"}' |jq -r ".result.sid"|sed 's/"//g')
	echo "SID=$SID" > /tmp/sma.conf
else
	. /tmp/sma.conf
fi
echo $SID |egrep -i "503|null" > /dev/null
if [ $? -ne 0 ]; then

curl  -s "http://${SERVER_SMA}/dyn/getAllOnlValues.json?sid=$SID" -H "Cookie: tmhDynamicLocale.locale=%22fr-fr%22; user80=%7B%22role%22%3A%7B%22bitMask%22%3A4%2C%22title%22%3A%22istl%22%2C%22loginLevel%22%3A2%7D%2C%22username%22%3A862%2C%22sid%22%3A%22${SID}%22%7D" --data-raw '{"destDev":[]}' > /tmp/sma.json
cat /tmp/sma.json |grep -i "401" > /dev/null
if [ $? -eq 0 ]; then
	rm /tmp/sma.conf
	ID=$(curl -s "http://${SERVER_SMA}/dyn/login.json"  --data-raw '{"right":"istl","pass":"26042019"}' |jq -r ".result.sid"|sed 's/"//g')
        echo "SID=$SID" > /tmp/sma.conf
	curl  -s "http://${SERVER_SMA}/dyn/getAllOnlValues.json?sid=$SID" -H "Cookie: tmhDynamicLocale.locale=%22fr-fr%22; user80=%7B%22role%22%3A%7B%22bitMask%22%3A4%2C%22title%22%3A%22istl%22%2C%22loginLevel%22%3A2%7D%2C%22username%22%3A862%2C%22sid%22%3A%22${SID}%22%7D" --data-raw '{"destDev":[]}' > /tmp/sma.json
fi
curl -s "http://${SERVER_SMA}/dyn/sessionCheck.json?sid=$SID" -H "Cookie: tmhDynamicLocale.locale=%22fr-fr%22; user80=%7B%22role%22%3A%7B%22bitMask%22%3A4%2C%22title%22%3A%22istl%22%2C%22loginLevel%22%3A2%7D%2C%22username%22%3A862%2C%22sid%22%3A%22${SERVER_SMA}%22%7D" --data-raw '{}' > /dev/null
#> /dev/null
power=$(cat /tmp/sma.json |jq  '.result."012F-730B4EA7"."6100_40263F00"."1"[]."val"')
powermax=$(cat /tmp/sma.json |jq  '.result."012F-730B4EA7"."6100_00411E00"."1"[]."val"')
curl -s "http://${SERVER_SMA}/dyn/logout.json?sid=${SID}" -H "Cookie: tmhDynamicLocale.locale=%22fr-fr%22; user80=%7B%22role%22%3A%7B%22bitMask%22%3A4%2C%22title%22%3A%22istl%22%2C%22loginLevel%22%3A2%7D%2C%22username%22%3A862%2C%22sid%22%3A%22${SID}%22%7D" --data-raw '{}' > /tmp/sma.logout
egrep -i '"islogin":false|401' /tmp/sma.logout > /dev/null
[ $? -eq 0 ] && rm /tmp/sma.*
[ "$power" == "null" ] && power=0
[ ! -z ${powermax} ] && echo -n "sma,power=power power=${power},powermax=${powermax} "
else
	rm /tmp/sma.*
fi

