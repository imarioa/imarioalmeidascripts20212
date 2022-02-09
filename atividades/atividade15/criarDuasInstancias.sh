#!/bin/bash
# Correção: 0,5. Só criou a primeira instância, sem sequer ter criado o banco.
key=$1
usuario=$2
senha=$3
public_ip=$(wget -qO- http://ipecho.net/plain)

echo "Criando servidor de Banco de Dados..."

imageId="ami-083602cee93914c0c"
instanceType="t2.micro"
vpcId=$(aws ec2 describe-vpcs --query "Vpcs[0].VpcId" --output text)
subnetId=$(aws ec2 describe-subnets --query "Subnets[0].SubnetId" --output text)

###### Criação do script userdata.sh para a inicialização da instancia 
cat << EOF > /tmp/userdata.sh
#!/bin/bash

sudo yum -y install mariadb-server
service mariadb start

EOF



aws ec2 create-security-group --group-name atividade15 --description "Grupo criado para a atividade 12 de scripts" --vpc-id $vpcId > /tmp/securityid.txt

groupId=$(aws ec2 describe-security-groups --filters Name=group-name,Values=atividade15 --query "SecurityGroups[*].GroupId" --output text)

aws ec2 authorize-security-group-ingress --group-id $groupId --protocol tcp --port 22 --cidr $public_ip/32
aws ec2 authorize-security-group-ingress --group-id $groupId --protocol tcp --port 80    --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $groupId --protocol tcp --port 3306  --source-group $groupId

aws ec2 run-instances --image-id $imageId --instance-type $instanceType --key-name $key --security-group-ids $groupId --subnet-id $subnetId --user-data file:///tmp/userdata.sh | grep "InstanceId" | cut -f2 -d":" | tr -d '",' > /tmp/instanceid.txt

instanceId=$(cat /tmp/instanceid.txt)
instanceStatus=$(aws ec2 describe-instance-status --instance-ids $instanceId --query "InstanceStatuses[0].InstanceState.Name" --output text)

until [ "$instanceStatus" = "running" ]
do
    instanceStatus=$(aws ec2 describe-instance-status --instance-ids $instanceId --query "InstanceStatuses[0].InstanceState.Name" --output text)
    sleep 5
done

IP=$(aws ec2 describe-instances --instance-ids $instanceId --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
private_IP=$(aws ec2 describe-instances --instance-ids $instanceId --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)

echo "IP Privado do Banco de Dados: $private_IP"

rm /tmp/userdata.sh /tmp/securityid.txt /tmp/instanceid.txt


