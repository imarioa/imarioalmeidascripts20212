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

mysql << FIM
CREATE DATABASE scripts;
CREATE USER  $usuario@'%' IDENTIFIED BY $senha;
GRANT ALL ON scripts.* to $usuario@'%' IDENTIFIED BY $senha WITH GRANT OPTION;
FLUSH PRIVILEGES;
FIM

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
echo " "
echo "Criando servidor de Aplicação..."

cat << EOF > /tmp/userdata.sh
#!/bin/bash

yum update -y
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum install -y httpd
yum -y install mariadb-server
systemctl enable httpd
systemctl start httpd

usermod -a -G apache ec2-user
sudo chown -R apache /var/www
chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
sed -i '7a\user=$usuario' /etc/my.cnf.d/client.cnf
sed -i '8a\password=$senha' /etc/my.cnf.d/client.cnf

service mariadb start

cat<<END > /etc/apache2/sites-available/wordpress.conf
<Directory /var/www/html/wordpress/>
    AllowOverride All
</Directory>
END

a2enmod rewrite
a2ensite wordpress
curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
touch wordpress/.htaccess
cp -a wordpress/. /var/www/html/wordpress
chown -R apache /var/www/html/wordpress
find /var/www/html/wordpress/ -type d -exec chmod 750 {} \;
find /var/www/html/wordpress/ -type f -exec chmod 640 {} \;

systemctl restart httpd

cat << END > config.sh
#!/bin/bash
usuario=$1
senha=$2
privateIP=$3

BD=scripts
USER=$usuario
PASSWORD=$senha
HOST=$privateIP

cat << CLOSE > wp-config.php
<?php
define( 'DB_NAME', '$BD' );
define( 'DB_USER', '$USER' );
define( 'DB_PASSWORD', '$PASSWORD' );
define( 'DB_HOST', '$HOST' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)

\$table_prefix = 'wp_';

define( 'WP_DEBUG', false );

if ( ! defined( 'ABSPATH' ) ) {
        define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';
CLOSE
END

chmod +x config.sh
./config.sh $usuario $senha $privateIP
cp wp-config.php /var/www/html/wordpress/

systemctl restart httpd

find /var/www/html/wordpress/ -type d -exec chmod 750 {} \;
find /var/www/html/wordpress/ -type f -exec chmod 640 {} \;

systemctl start httpd

EOF

aws ec2 run-instances --image-id $imageId --instance-type $instanceType --key-name $key --security-group-ids $groupId --subnet-id $subnetId --user-data file:///tmp/userdata.sh | grep "InstanceId" | cut -f2 -d":" | tr -d '",' > /tmp/instanceid.txt
instanceId=$(cat /tmp/instanceid.txt)
instanceStatus=$(aws ec2 describe-instance-status --instance-ids $instanceId --query "InstanceStatuses[0].InstanceState.Name" --output text)

until [ "$instanceStatus" = "running" ]
do
    instanceStatus=$(aws ec2 describe-instance-status --instance-ids $instanceId --query "InstanceStatuses[0].InstanceState.Name" --output text)
    sleep 5
done

IP=$(aws ec2 describe-instances --instance-ids $instanceId --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
echo "IP Público do servidor de Aplicação: $IP"

echo " "
echo "Acesse http://$IP/wordpress para finalizar a configuração."
rm /tmp/userdata.sh /tmp/securityid.txt /tmp/instanceid.txt


