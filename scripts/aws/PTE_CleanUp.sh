#!/bin/bash
## Clean-UP and Combine
type=$1
awsiid=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
awsit=$(curl -s http://169.254.169.254/latest/meta-data/instance-type)
awshost=$(curl -s http://169.254.169.254/latest/meta-data/hostname)

pkill -F HostMonitor_pid.txt
mv HostMonitor.csv $awsit-$awsiid-HostMonitor.csv
gzip $awsit-$awsiid-HostMonitor.csv

if [ $type == 'client' ]; then
    pkill -F NetworkLatency_pid.txt
    mv NetworkLatency.csv $awsit-$awsiid-NetworkLatency.csv
    gzip $awsit-$awsiid-NetworkLatency.csv

    if ls *cps* 1> /dev/null 2>&1; then
        echo "StartTime,EPOCH,ctime,dtime,ttime,wait,Test-Type,Instance-Type,Instance-Id,Hostname,FileName" > $awsit-$awsiid-result-cps.csv
        for fn in `dir gplot*-cps-*.tsv`;do
            sed -i 's/$/\t'$awsit'\t'$awsiid'\t'$awshost'\tConnections\/s\t'$fn'/; s/\t/,/g' $fn
        done
        awk 'FNR>1' gplot*-cps-*.tsv >> $awsit-$awsiid-result-cps.csv
        gzip $awsit-$awsiid-result-cps.csv
        tar -cvzf $awsit-$awsiid-output-cps.gz *cps*.output
    elif ls *rps* 1> /dev/null 2>&1; then
        echo "StartTime,EPOCH,ctime,dtime,ttime,wait,Test-Type,Instance-Type,Instance-Id,Hostname,FileName" > $awsit-$awsiid-result-rps.csv
        for fn in `dir gplot*-rps-*.tsv`;do
            sed -i 's/$/\t'$awsit'\t'$awsiid'\t'$awshost'\tRequests\/s\t'$fn'/; s/\t/,/g' $fn
        done
        awk 'FNR>1' gplot*-rps-*.tsv >> $awsit-$awsiid-result-rps.csv
        gzip $awsit-$awsiid-result-rps.csv
        tar -cvzf $awsit-$awsiid-output-rps.gz *rps*.output
    elif ls *db128* 1> /dev/null 2>&1; then
        echo "dbartTime,EPOCH,ctime,dtime,ttime,wait,Tedb-Type,Indbance-Type,Indbance-Id,Hodbname,FileName" > $awsit-$awsiid-result-db128.csv
        for fn in `dir gplot*-db128-*.tsv`;do
            sed -i 's/$/\t'$awsit'\t'$awsiid'\t'$awshodb'\tRequedbs\/s-db128\t'$fn'/; s/\t/,/g' $fn
        done
        awk 'FNR>1' gplot*-db128-*.tsv >> $awsit-$awsiid-result-db128.csv
        gzip $awsit-$awsiid-result-db128.csv
        tar -cvzf $awsit-$awsiid-output-db128.gz *db128*.output
    elif ls *db512* 1> /dev/null 2>&1; then
        echo "dbartTime,EPOCH,ctime,dtime,ttime,wait,Tedb-Type,Indbance-Type,Indbance-Id,Hodbname,FileName" > $awsit-$awsiid-result-db512.csv
        for fn in `dir gplot*-db512-*.tsv`;do
            sed -i 's/$/\t'$awsit'\t'$awsiid'\t'$awshodb'\tRequedbs\/s-db512\t'$fn'/; s/\t/,/g' $fn
        done
        awk 'FNR>1' gplot*-db512-*.tsv >> $awsit-$awsiid-result-db512.csv
        gzip $awsit-$awsiid-result-db512.csv
        tar -cvzf $awsit-$awsiid-output-db512.gz *db512*.output
    elif ls *st128* 1> /dev/null 2>&1; then
        echo "StartTime,EPOCH,ctime,dtime,ttime,wait,Test-Type,Instance-Type,Instance-Id,Hostname,FileName" > $awsit-$awsiid-result-st128.csv
        for fn in `dir gplot*-st128-*.tsv`;do
            sed -i 's/$/\t'$awsit'\t'$awsiid'\t'$awshost'\tRequests\/s-ST128\t'$fn'/; s/\t/,/g' $fn
        done
        awk 'FNR>1' gplot*-st128-*.tsv >> $awsit-$awsiid-result-st128.csv
        gzip $awsit-$awsiid-result-st128.csv
        tar -cvzf $awsit-$awsiid-output-st128.gz *st128*.output
    elif ls *st512* 1> /dev/null 2>&1; then
        echo "StartTime,EPOCH,ctime,dtime,ttime,wait,Test-Type,Instance-Type,Instance-Id,Hostname,FileName" > $awsit-$awsiid-result-st512.csv
        for fn in `dir gplot*-st512-*.tsv`;do
            sed -i 's/$/\t'$awsit'\t'$awsiid'\t'$awshost'\tRequests\/s-ST512\t'$fn'/; s/\t/,/g' $fn
        done
        awk 'FNR>1' gplot*-st512-*.tsv >> $awsit-$awsiid-result-st512.csv
        gzip $awsit-$awsiid-result-st512.csv
        tar -cvzf $awsit-$awsiid-output-st512.gz *st512*.output
    fi

    ## Clean-UP log files
    if ls *.tsv 1> /dev/null 2>&1; then
        rm *.tsv
    fi
    if ls *.output 1> /dev/null 2>&1; then
        rm *.output
    fi
fi
