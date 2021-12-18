BEGIN{
    i = 1
}
{
    if(NR >= 2){
        lista_cursos[$2] = $2
        salarios[$1] = $3
        professores[$1] = $2
    }   
}
END{
    for(j in lista_cursos){
        for(k in salarios){
            if(j == professores[k]){
                if(salarios[k] > maior[j]){
                    maior[j] = salarios[k]
                    professor[j] = k
                }
            }
        }
    }
    for(j in lista_cursos){
        printf "%s: %s, %d\n", j, professor[j], maior[j] >> "prof.tmp"
    }
    system("column -t prof.tmp | sort -n; rm prof.tmp")
}