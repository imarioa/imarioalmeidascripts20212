#!/bin/bash

#--------------------------Variáveis----------------------------#
acao="NULL"
nome="NULL"
ip="NULL"
#---------------------------------------------------------------#
#------------------------- Funções -----------------------------#

adicionar(){
NOMEDAMAQUINA=$1
IP=$2
    echo "${NOMEDAMAQUINA},${IP}" >> hosts.db
}

remover(){
NOMEDAMAQUINA=$1
    sed -i "/$NOMEDAMAQUINA/d" hosts.db
}

procurar(){
BUSCAR=$1
BUSCAREVERSA=$2
    if [ "$BUSCAREVERSA" == "r" ]
    then
        grep -w "${BUSCAR}" hosts.db | cut -f1 -d","
    else
        grep -w "$BUSCAR" hosts.db | cut -f2 -d","
    fi
}

lista(){
    column -t -s "," hosts.db | sort -k2
}


#----------------------------------------------------------#



while getopts ":i:d:a:r:l" OPTVAR
do
    if  [ "$OPTVAR" == "a" ]
    then
        nome=$OPTARG
    fi
    if  [ "$OPTVAR" == "d" ]
    then   
        remover $OPTARG
        exit
    fi
    if  [ "$OPTVAR" == "i" ]
    then
        ip=$OPTARG
        if [ "$nome" != "NULL" ] && [ "$ip" != "NULL" ]
        then
            adicionar $nome $ip
            exit
        else
            echo "Comando inválido!"
            exit
        fi
    fi
    if  [ "$OPTVAR" == "r" ]
    then
        ip=$OPTARG
        procurar $ip $OPTVAR
        exit

    fi
    if  [ "$OPTVAR" == "l" ]
    then
        lista
        exit
    fi
    if [ "$OPTVAR" == "?" ]
    then
        echo "Digite um parâmetro válido!"
        exit
    fi
    if [ "$OPTVAR" == ":" ]
    then
        echo "Comando inválido"
        exit
    fi
    if [ "$OPTIND" -eq 1 ]
    then 
        echo "finalmente"
    fi
done    
if [ ${#1} -ge 1 ]
then
    procurar $1
else
    echo "Parâmetro inválido!"
fi