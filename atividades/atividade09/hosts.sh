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

    echo "$NOMEDAMAQUINA     $IP" >> hosts.db

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
        grep "${BUSCAR}" hosts.db | cut -f1 -d" "
    else
        grep "$BUSCAR" hosts.db | cut -f6 -d" "
    fi

}

lista(){
    cat hosts.db
}


#----------------------------------------------------------#



while getopts "a:d:i:lr:" OPTVAR
do
    if  [ "$OPTVAR" == "a" ]
    then
        nome=$OPTARG
    fi
    if  [ "$OPTVAR" == "d" ]
    then   
        remover $OPTARG
    fi
    if  [ "$OPTVAR" == "i" ]
    then
        ip=$OPTARG
        if [ "$nome" != "NULL" ] && [ "$ip" != "NULL" ]
        then
            adicionar $nome $ip
        fi
    fi
    if  [ "$OPTVAR" == "r" ]
    then
        ip=$OPTARG
        procurar $ip $OPTVAR

    fi
    if  [ "$OPTVAR" == "l" ]
    then
        lista
    fi
done    


