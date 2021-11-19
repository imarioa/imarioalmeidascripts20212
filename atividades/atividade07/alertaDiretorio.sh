#!/bin/bash

INTERVALO=$1
DIR=$2
QTD=$(ls -Rl $DIR | grep -c "^-" )
ARQUIVOS=/var/tmp/arquivos.txt
ARQUIVOS_MODIFICAODS=/var/tmp/arquivos-modificados.txt
DIFERENCA=/var/tmp/diferenca.txt
ls -F | grep -v '/$' > $ARQUIVOS

while true
do  
    QTD_atual=$(ls -Rl $DIR | grep -c "^-" )
    if [[ $QTD -ne $QTD_atual ]]
    then    
        if [[ $QTD -gt $QTD_atual ]]
        then
           ls -F | grep -v '/$' > $ARQUIVOS_MODIFICAODS
           diff $ARQUIVOS $ARQUIVOS_MODIFICAODS | sed "1d" | cut -f2 -d" " > $DIFERENCA
           REMOVIDOS=$(sed ':a;$!N;s/\n/, /;ta;' ${DIFERENCA})
           echo "[$(date +%d-%m-%Y) $(date +%H:%M:%S)] Alteração! $QTD->${QTD_atual}. Removidos: $REMOVIDOS"
           ls -F | grep -v '/$' > $ARQUIVOS
        else
            ls -F | grep -v '/$' > $ARQUIVOS_MODIFICAODS
            diff $ARQUIVOS $ARQUIVOS_MODIFICAODS | sed "1d" | cut -f2 -d" " > $DIFERENCA
            ADICIONADOS=$(sed ':a;$!N;s/\n/, /;ta;' ${DIFERENCA})
            echo "[$(date +%d-%m-%Y) $(date +%H:%M:%S)] Alteração! $QTD->${QTD_atual}. Adicionados: $ADICIONADOS"
            ls -F | grep -v '/$' > $ARQUIVOS
        fi
        QTD=$QTD_atual
    fi
    
    sleep $INTERVALO
done