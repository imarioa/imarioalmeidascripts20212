#!/bin/bash
# Correção: 4,0
key=$1

echo "Criando servidor..."

imageId="ami-083602cee93914c0c"
instanceType="t2.micro"
vpcId=$(aws ec2 describe-vpcs --query "Vpcs[0].VpcId" --output text)
subnetId=$(aws ec2 describe-subnets --query "Subnets[0].SubnetId" --output text)

echo "#!/bin/bash
sudo amazon-linux-extras install -y nginx1.12
sudo systemctl start nginx
cd /usr/share/nginx/html
sudo su
mv index.html index.html.old
echo '<html><head><meta charset='UTF-8'/><title>Atividade12</title></head><body><h1>Imario Almeida <br> Matricula: 412976</h1></body></html>' > index.html" > /tmp/userdata.txt

aws ec2 create-security-group --group-name atividade12 --description "Grupo criado para a atividade 12 de scripts" --vpc-id $vpcId > /tmp/securityid.txt

groupId=$(aws ec2 describe-security-groups --filters Name=group-name,Values=atividade12 --query "SecurityGroups[*].GroupId" --output text)

aws ec2 authorize-security-group-ingress --group-id $groupId --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $groupId --protocol tcp --port 80    --cidr 0.0.0.0/0

aws ec2 run-instances --image-id $imageId --instance-type $instanceType --key-name $key --security-group-ids $groupId --subnet-id $subnetId --user-data file:///tmp/userdata.txt | grep "InstanceId" | cut -f2 -d":" | tr -d '",' > /tmp/instanceid.txt

instanceId=$(cat /tmp/instanceid.txt)

IP=$(aws ec2 describe-instances --instance-ids $instanceId --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

echo "Acesse: http://$IP"

rm /tmp/userdata.txt /tmp/securityid.txt /tmp/instanceid.txt


