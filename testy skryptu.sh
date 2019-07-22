#!/bin/sh

host1="onet.pl"
host2="google.com"
brama="172.22.0.1"
zyje=2
plik="/root/logi/ping_log.txt"

temp_d=`date +%s`
temp_dd=0
zmien_stan_diody()
{
    case $1 in
        zielona)
            dioda="/sys/devices/platform/gpio-leds/leds/F@ST2704V2:green:inet"
            ;;
        czerwona)
            dioda="/sys/devices/platform/gpio-leds/leds/F@ST2704V2:red:inet"
            ;;
        *)
            echo 'blad zmien_stan_diody() zly argument $1'
            return
            ;;
    esac
    case $2 in
        zaswiec)
            echo default-on >"$dioda/trigger"
            ;;
        zgas)
            echo none >"$dioda/trigger"
            ;;
        migaj)
            echo timer >"$dioda/trigger"
            ;;
        *)
            echo 'blad zmien_stan_diody() zly argument $2'
            return
    esac
}

if [ -f $plik ]
then
        data=`date "+%Y-%m-%d_%H-%M-%S"`
        mv $plik "/root/logi/backup/$data:log.txt"
fi

while true
do
        if ping -q -c 2 -w 3 $host1 >/dev/null 2>&1  || ping -q -c 2 -w 3 $host2 >/dev/null 2>&1
        then
                if [ $zyje == 2 ]
                then
                zyje=0
                fi

                if [ $zyje == 0 ]
                then
                        data=`date "+%Y-%m-%d %H:%M:%S"`
                        zmien_stan_diody "zielona" "zaswiec"
                        zmien_stan_diody "czerwona" "zgas"
                        temp_dd=`date +%s`
                        temp_ddd=$(($temp_dd - $temp_d))
                        if [$temp_ddd -gt 86400]
                        then
                            echo $data - Odżyl po $(date -d @$(($temp_ddd - 86400)) +%d-%H:%M:%S)  >>$plik
                        else
                            echo $data - Odżyl po 00-$(date -d @$temp_ddd +%H:%M:%S)  >>$plik
                        fi
                        zyje=1
                fi
        else
                if [ $zyje == 2 ]
                then
                zyje=1
                fi


                if [ $zyje == 1 ]
                then
                temp_d=`date +%s`

                if ping -q ping -q -c 2 -w 2 $brama >/dev/null 2>&1
                    then
                        data=`date "+%Y-%m-%d %H:%M:%S"`
                        zmien_stan_diody "zielona" "zgas"
                        zmien_stan_diody "czerwona" "migaj"
                        echo $data - ***********Brama PK padla***********  >> $plik
                        zyje=0
                    else
                        data=`date "+%Y-%m-%d %H:%M:%S"`
                        zmien_stan_diody "zielona" "zgas"
                        zmien_stan_diody "czerwona" "zaswiec"
                        echo $data - ***************Zdechl***************  >> $plik
                        zyje=0
                    fi
                fi
        fi
        sleep 5
done
