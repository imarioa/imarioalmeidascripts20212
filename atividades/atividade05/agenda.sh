#!/bin/bash
acao=$1
param1=$2
param2=$3

case $acao in
        adicionar)
            if [ -e agenda.db ]
            then
                echo "$param1: $param2" >> agenda.db
                echo "Usuário $param1 adicionado."
            else
                echo "$param1: $param2" > agenda.db
                echo "Arquivo criado!!!"
                echo "Usuário $param1 adicionado."
            fi
            ;;
        remover)
            if grep "$param1" agenda.db >> /dev/null
            then
                sed -r '/${param1}/d' agenda.db > /tmp/ex 2> /dev/null
                mv /tmp/ex agenda.db
                echo "Removido"
                cat agenda.db
            else
                echo "Teste 1"
            fi
            ;;
        listar)
            if [ -e agenda.db ]
            then
                cat agenda.db
            else
                echo "Arquivo vazio!!!"
            fi
            ;;
        *)
            echo "Teste 2"
esac