#!/bin/bash

declare -A PALAVRAS
declare -A QTD

read -p "Informe o arquivo: " ARQUIVO

for var in $(tr -d [:punct:] < $ARQUIVO)
do
    PALAVRAS[${var}]=$var
    QTD[${var}]=0
done 
for var in $(tr -d [:punct:] < $ARQUIVO)
do
    QTD[${var}]=$(( ${QTD[${var}]} + 1 ))
done
for var in ${PALAVRAS[@]}
do
    echo $var: ${QTD[$var]}
done