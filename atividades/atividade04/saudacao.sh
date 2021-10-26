#!/bin/bash
cat << Fim | tee -a saudacao.log 
Olá $(whoami),
Hoje é dia $(date +%d), do mês $(date +%m) do ano de $(date +%Y).

Fim
