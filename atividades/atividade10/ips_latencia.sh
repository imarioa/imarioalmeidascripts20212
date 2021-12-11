#!/bin/bash
IPS=$1
N_LINHAS=$(cat $IPS | wc -l)

for var in $(seq $N_LINHAS)
do
    sed -n "$var p" $IPS | xargs ping -c 10 >> pings.tmp
done
awk 'BEGIN { media = 0  }
{   
    split($7, v, "="); 
    media = media + (v[2]/10); 
    split($5, c, "="); 
    it = c[2]; 
    if(it == 10){
        tamanho = length($4) - 1;
        ip = substr($4, 1, tamanho); 
        printf"%s %.2fms\n", ip, media; 
        media = 0
    }
}' pings.tmp

rm pings.tmp


