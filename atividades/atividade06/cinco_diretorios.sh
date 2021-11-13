#!/bin/bash
mkdir cinco
for var in $(seq 5)
do
    mkdir cinco/dir$var
    for i in $(seq 4)
    do
        for j in $(seq $i)
        do
            echo $i >> cinco/dir$var/arq$i.txt
        done
    done
   
done