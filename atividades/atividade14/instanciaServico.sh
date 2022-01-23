#!/bin/bash
key=$1

echo "Criando servidor de Monitoramento em CRON..."

imageId="ami-083602cee93914c0c"
instanceType="t2.micro"
vpcId=$(aws ec2 describe-vpcs --query "Vpcs[0].VpcId" --output text)
subnetId=$(aws ec2 describe-subnets --query "Subnets[0].SubnetId" --output text)

###### Criação do script userdata.sh para a inicialização da instancia 
cat << EOF > /tmp/userdata.sh
#!/bin/bash

sudo amazon-linux-extras install -y nginx1.12
sudo systemctl start nginx
cd /usr/share/nginx/html
sudo su
mv index.html index.html.old


cat << FIM > /usr/share/nginx/html/index.html
    <!DOCTYPE html>
        <html>
        <head>
            <meta charset='utf-8'>
            <title>Servidor de Monitoramento</title>
        </head>
        <body>
            <table border="1" cellpadding="5px">
                <tr>
                    <td>Data e Hora</td>
                    <td>Tempo de atividade</td>
                    <td>Carga média</td>
                    <td>Memória livre</td>
                    <td>Memória ocupada</td>
                    <td>Bytes recebidos na eth0</td>
                    <td>Bytes transmitidos da eth0</td>
                </tr>
                <tr>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>
            </table>
        </body>
        </html>
FIM


##### Criação do script de monitoramento 

cat << SERVICOSH > /usr/local/bin/monitoramento.sh
#!/bin/bash

sudo systemctl start nginx

#### Coleta de dados 

HORA=@(date +%H:%M:%S-%d/%m/%y)
UPTIME=@(uptime -p)
CARGA=@(uptime  | grep -oP '(?<=average:).*')
free -h > /tmp/mem.tmp
MEMLIVRE=@(awk 'NR == 2 {print @4}' /tmp/mem.tmp)
MEMUSADA=@(awk 'NR == 2 {print @3}' /tmp/mem.tmp)
rm /tmp/mem.tmp
ENVIADOS=@(awk 'NR == 3 {print @2}' /proc/net/dev)
RECEBIDOS=@(awk 'NR == 3 {print @10}' /proc/net/dev)

#### Criação da página HTML

cat << FIM > /usr/share/nginx/html/index.html
    <!DOCTYPE html>
        <html>
        <head>
            <meta charset='utf-8'>
            <title>Servidor de Monitoramento</title>
        </head>
        <body>
            <table border="1" cellpadding="5px">
                <tr>
                    <td>Data e Hora</td>
                    <td>Tempo de atividade</td>
                    <td>Carga média</td>
                    <td>Memória livre</td>
                    <td>Memória ocupada</td>
                    <td>Bytes recebidos na eth0</td>
                    <td>Bytes transmitidos da eth0</td>
                </tr>
                <tr>
                    <td>@HORA</td>
                    <td>@UPTIME</td>
                    <td>@CARGA</td>
                    <td>@MEMLIVRE</td>
                    <td>@MEMUSADA</td>
                    <td>@ENVIADOS</td>
                    <td>@RECEBIDOS</td>
                </tr>
            </table>
        </body>
        </html>
FIM

################ Fim da criação da página HTML


SERVICOSH
########### Fim da criação do script de monitoramento 

########## Manipulação de caracteres no script de monitoramento 

cp /usr/local/bin/monitoramento.sh /usr/local/bin/monitoramento2.sh
cat /usr/local/bin/monitoramento2.sh | tr @ $ > /usr/local/bin/monitoramento.sh
rm /usr/local/bin/monitoramento2.sh

####### Criação do serviço

chmod 744 /usr/local/bin/monitoramento.sh

echo "*/1  *  *  *  *  root  /usr/local/bin/monitoramento.sh" >> /etc/crontab

EOF



aws ec2 create-security-group --group-name newgroup --description "Grupo criado para a atividade 12 de scripts" --vpc-id $vpcId > /tmp/securityid.txt

groupId=$(aws ec2 describe-security-groups --filters Name=group-name,Values=newgroup --query "SecurityGroups[*].GroupId" --output text)

aws ec2 authorize-security-group-ingress --group-id $groupId --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $groupId --protocol tcp --port 80    --cidr 0.0.0.0/0

aws ec2 run-instances --image-id $imageId --instance-type $instanceType --key-name $key --security-group-ids $groupId --subnet-id $subnetId --user-data file:///tmp/userdata.sh | grep "InstanceId" | cut -f2 -d":" | tr -d '",' > /tmp/instanceid.txt

instanceId=$(cat /tmp/instanceid.txt)
instanceStatus=$(aws ec2 describe-instance-status --instance-ids $instanceId --query "InstanceStatuses[0].InstanceState.Name" --output text)

until [ "$instanceStatus" = "running" ]
do
    instanceStatus=$(aws ec2 describe-instance-status --instance-ids $instanceId --query "InstanceStatuses[0].InstanceState.Name" --output text)
    sleep 5
done

IP=$(aws ec2 describe-instances --instance-ids $instanceId --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
echo "Instância em estado \"${instanceStatus}\""
echo "Acesse: http://$IP"

rm /tmp/userdata.sh /tmp/securityid.txt /tmp/instanceid.txt


