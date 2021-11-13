#!/bin/bash
IPS=$1
N_LINHAS=$(cat $1 | wc -l)

for var in $(seq $N_LINHAS)
do
    sed -n "$var p" $IPS | xargs ping -c 10 | cut -f7 -d' ' | sed  "s/data.\|packet\|time=//g" | sed '/^$/d' > temp.txt
    SOMA=$(paste -sd+ temp.txt | bc)
    MEDIA=$(echo "$SOMA * 0.1" | bc)
    echo "$(sed -n "$var p" $IPS) ${MEDIA}ms" >> ipstemp.txt
done
sort -r -t' ' -k2 ipstemp.txt
rm ipstemp.txt temp.txt

