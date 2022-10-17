#!/bin/bash
INTERVAL="1"  # update interval in seconds

#### Tools
#
# - apt-get install -y lshw ethtool
#

if [ -z "$1" ]; then
        echo
        echo usage: $0 [network-interface] [throughput-unit]
        echo
        echo e.g. $0 eth0 G
        echo
        echo shows packets-per-second & bytes-per-second
        exit
fi

case $2 in
    "G")
        CX=`awk "BEGIN{print 10 ^ 9 / 8}"`
        UM="Gb/s";;
    "M")
        CX=`awk "BEGIN{print 10 ^ 6 / 8}"`
        UM="Mb/s";;
    "K")
        CX=`awk "BEGIN{print 10 ^ 3 / 8}"`
        UM="Kb/s";;
    *)
        CX=8
        UM="b/s";;
esac

#us: user cpu time (or) % CPU time spent in user space
#sy: system cpu time (or) % CPU time spent in kernel space
#ni: user nice cpu time (or) % CPU time spent on low priority processes
#id: idle cpu time (or) % CPU time spent idle
#wa: io wait cpu time (or) % CPU time spent in wait (on disk)
#hi: hardware irq (or) % CPU time spent servicing/handling hardware interrupts
#si: software irq (or) % CPU time spent servicing/handling software interrupts
#st: steal time - - % CPU time in involuntary wait by virtual cpu while hypervisor is servicing another processor (or) % CPU time stolen from a virtual machine

gcpiid=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/id" -H "Metadata-Flavor: Google")
gcpit=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/machine-type" -H "Metadata-Flavor: Google")
gcpzone=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google")
gcphost=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/hostname" -H "Metadata-Flavor: Google")
gcpnics=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/" -H "Metadata-Flavor: Google")

nicduplex=$(cat /sys/class/net/$1/duplex)
nicspeed=$(cat /sys/class/net/$1/speed)
nicmtu=$(cat /sys/class/net/$1/mtu)
nicdriver=$(cat /sys/class/net/$1/device/uevent | awk 'FNR <= 1 {split($0,a,"="); print a[2]}' )

cpucount=$(cat /proc/cpuinfo | grep processor | wc -l)
niccount=$(expr $(ls /sys/class/net/ | wc -l) - 1)

if [ "$3" == 'CSV' ]; then
    echo -e "EPOCH,Local-Instance-Type,Local-Instance-Id,Local-Hostname,MTU,Duplex,Speed,Driver,CPU %,User,Nice,System,Idle,IOWait,Hardware IRQ,Software IRQ,TCP Established,TCP Closed,TCP Orphaned,TCP SynRecv,TCP Timewait,TX Pkt/s,RX Pkt/s,Total Pkt/s,TX $UM,RX $UM,Total $UM"
fi

while true
do
    ## Collect STATS for packets & bytes
    Rp1=`cat /sys/class/net/$1/statistics/rx_packets`
    Tp1=`cat /sys/class/net/$1/statistics/tx_packets`
    Rb1=`cat /sys/class/net/$1/statistics/rx_bytes`
    Tb1=`cat /sys/class/net/$1/statistics/tx_bytes`

    ## Collect STATS for CPU USAGE
    C1=`grep 'cpu ' /proc/stat`
    C1Sum=`awk '{for(i=t=0;i<NF;) t+=$++i; $0=t}1' <<< $C1`
    C1us=`awk '{print $2}' <<< $C1`
    C1ni=`awk '{print $3}' <<< $C1`
    C1sy=`awk '{print $4}' <<< $C1`
    C1id=`awk '{print $5}' <<< $C1`
    C1wa=`awk '{print $6}' <<< $C1`
    C1hi=`awk '{print $7}' <<< $C1`
    C1si=`awk '{print $8}' <<< $C1`

    ## Collect STATS for TCP Connections
    S1=`ss -s | grep 'TCP:' | awk -F [\(\)] '{printf $2}'`
    S1e=`awk -F[\ ,] '{print $2}' <<< $S1`
    S1c=`awk -F[\ ,] '{print $5}' <<< $S1`
    S1o=`awk -F[\ ,] '{print $8}' <<< $S1`
    S1s=`awk -F[\ ,] '{print $11}' <<< $S1`
    S1t=`awk -F[\ ,] '{print $14}' <<< $S1`

    sleep $INTERVAL
    Rp2=`cat /sys/class/net/$1/statistics/rx_packets`
    Tp2=`cat /sys/class/net/$1/statistics/tx_packets`
    Rb2=`cat /sys/class/net/$1/statistics/rx_bytes`
    Tb2=`cat /sys/class/net/$1/statistics/tx_bytes`

    C2=`grep 'cpu ' /proc/stat`
    C2Sum=`awk '{for(i=t=0;i<NF;) t+=$++i; $0=t}1' <<< $C2`
    C2us=`awk '{print $2}' <<< $C2`
    C2ni=`awk '{print $3}' <<< $C2`
    C2sy=`awk '{print $4}' <<< $C2`
    C2id=`awk '{print $5}' <<< $C2`
    C2wa=`awk '{print $6}' <<< $C2`
    C2hi=`awk '{print $7}' <<< $C2`
    C2si=`awk '{print $8}' <<< $C2`

    ## Collect STATS for TCP Connections
    S2=`ss -s | grep 'TCP:' | awk -F [\(\)] '{printf $2}'`
    S2e=`awk -F[\ ,] '{print $2}' <<< $S2`
    S2c=`awk -F[\ ,] '{print $5}' <<< $S2`
    S2o=`awk -F[\ ,] '{print $8}' <<< $S2`
    S2s=`awk -F[\ ,] '{print $11}' <<< $S2`
    S2t=`awk -F[\ ,] '{print $14}' <<< $S2`

    CUser=`expr $C2us - $C1us`
    CNice=`expr $C2ni - $C1ni`
    CSystem=`expr $C2sy - $C1sy`
    CIdle=`expr $C2id - $C1id`
    CIOWait=`expr $C2wa - $C1wa`
    CHardIrq=`expr $C2hi - $C1hi`
    CSoftIrq=`expr $C2si - $C1si`

    CDelta=`expr $C2Sum - $C1Sum`
    CUsed=`expr $CDelta - $CIdle`
    CUsage=`awk "BEGIN{print (100 * $CUsed) / $CDelta}"`
    CUsage=`awk '{printf "%.2f\n",$0}'<<<$CUsage`

    CPUUser=`awk "BEGIN{print (100 * $CUser) / $CDelta}"`
    CPUUser=`awk '{printf "%.2f\n",$0}'<<<$CPUUser`

    CPUNice=`awk "BEGIN{print (100 * $CNice) / $CDelta}"`
    CPUNice=`awk '{printf "%.2f\n",$0}'<<<$CPUNice`

    CPUSystem=`awk "BEGIN{print (100 * $CSystem) / $CDelta}"`
    CPUSystem=`awk '{printf "%.2f\n",$0}'<<<$CPUSystem`

    CPUIdle=`awk "BEGIN{print (100 * $CIdle) / $CDelta}"`
    CPUIdle=`awk '{printf "%.2f\n",$0}'<<<$CPUIdle`

    CPUIOWait=`awk "BEGIN{print (100 * $CIOWait) / $CDelta}"`
    CPUIOWait=`awk '{printf "%.2f\n",$0}'<<<$CPUIOWait`

    CPUHardIrq=`awk "BEGIN{print (100 * $CHardIrq) / $CDelta}"`
    CPUHardIrq=`awk '{printf "%.2f\n",$0}'<<<$CPUHardIrq`

    CPUSoftIrq=`awk "BEGIN{print (100 * $CSoftIrq) / $CDelta}"`
    CPUSoftIrq=`awk '{printf "%.2f\n",$0}'<<<$CPUSoftIrq`

    # TCPEstab=`expr $S1e - $S2e`
    # TCPClosed=`expr $S1c - $S2c`
    # TCPOrphaned=`expr $S1o - $S2o`
    # TCPSynrecv=`expr $S1s - $S2s`
    #TCPTimeWait=`awk "BEGIN{print ($S1t - $S2t)*-1}"`

    TCPEstab=$S1e
    TCPClosed=$S1c
    TCPOrphaned=$S1o
    TCPSynrecv=$S1s
    TCPTimeWait=$S1t

    TXPPS=`expr $Tp2 - $Tp1`
    RXPPS=`expr $Rp2 - $Rp1`
    TXBPS=`expr $Tb2 - $Tb1`
    RXBPS=`expr $Rb2 - $Rb1`

    if [[ $TXBPS > 0 ]]; then
        TXBPS=`awk "BEGIN{print $TXBPS / $CX }"`
        TXBPS=`awk '{printf "%.2f\n",$0}'<<<$TXBPS`
    fi
    if [[ $RXBPS > 0 ]]; then
        RXBPS=`awk "BEGIN{print $RXBPS / $CX }"`
        RXBPS=`awk '{printf "%.2f\n",$0}'<<<$RXBPS`
    fi
    TOTALPPS=$((TXPPS + $RXPPS))
    TOTALBPS=`awk "BEGIN{print $TXBPS + $RXBPS}"`
    if [ "$3" == 'CSV' ]; then
        echo -e "$(date +%s),$gcpiid,$gcpit,$gcphost,$nicmtu,$nicduplex,$nicspeed,$nicdriver,$CUsage%,$CPUUser,$CPUNice,$CPUSystem,$CPUIdle,$CPUIOWait,$CPUHardIrq,$CPUSoftIrq,$TCPEstab,$TCPClosed,$TCPOrphaned,$TCPSynrecv,$TCPTimeWait,$TXPPS,$RXPPS,$TOTALPPS,$TXBPS,$RXBPS,$TOTALBPS"
    else
        echo -e "CPU: $CUsage%\tTCP: Estab: $TCPEstab Closed: $TCPClosed TimeWait: $TCPTimeWait\t$1: TX $TXPPS pkts/s RX $RXPPS pkts/s TOTAL $TOTALPPS pkts/s \tTX $TXBPS $UM RX $RXBPS $UM TOTAL $TOTALBPS $UM"
    fi
done
