# Correção: 2,0
grep -E -v 'sshd' auth.log
grep -E 'sshd.*Accepted.*\bj' auth.log 
grep -E ' session opened.*root' auth.log
grep -E '^(Oct 11|Oct 12).*Accepted' auth.log 
