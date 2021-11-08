#!/bin/bash
# Correção: 0,5
param1=$1
param2=$2
param3=$3

if expr $param1 + 1 &> /dev/null
then
	if expr $param2 + 1 &> /dev/null
	then
		if expr $param3 + 1 &> /dev/null
		then
			if [ \( $param1 -gt $param2 \) -a \( $param1 -gt $param3 \) ]
			then
				echo "Maior número: $param1"
			elif [ \( $param2 -gt $param1 \) -a \( $param2 -gt $param3 \) ]
			then
				echo "Maior número: $param2"
			elif [ \( $param3 -gt $param1 \) -a \( $param3 -gt $param2 \) ]
			then
				echo "Maior número: $param3"
			else
				echo "Maior número: $param1"
			fi
		else
			echo "Opa!!! $param3 não é um número."
		fi
	else
		echo "Opa!!! $param2 não é um número."
	fi
else
	echo "Opa!!! $param1 não é um número."
fi
