
$resourcegroup = "training4.2"
$location = "westeurope"
az group create -l $location -n $resourcegroup

az appservice plan create -n "AnupPlanservice" -g $resourcegroup -l $location --is-linux --sku S1
# We have choosen linux container and S1 pricing tier


# lets create MySql DB
$mysqlservername = "mysql-Servername1"
$adminuser = "Anupkumarmishra"
$adminpassword = "Anup@123"
az mysql server create -g $resourcegroup -n $mysqlservername --admin-user $adminuser --admin-password $adminpassword -l $location --ssl-enforcement Disabled --sku-name GP_Gen5_2 --version 5.7


#Lets allow firewalls rules for my appservices to talk to it. 

az mysql server firewall-rule create -g $resourcegroup --server $mysqlservername --name AllowAppservicesAnup --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0


# Create app using docker image
$appname = "wordpress-Anupname1"
$dockerrepo = "wordpress"

az webapp create -n $appname -g $resourcegroup --plan "AnupPlanservice" -i $dockerrepo

#We need to connect opu app with mysql db 

$wordpressdbhost = (az mysql server show -g $resourcegroup -n $mysqlservername --query "fullyQualifiedDomainName" -o tsv)
$wordpressdbhost

az webapp config appsettings set -n $appname -g $resourcegroup --settings WORDPRESS_DB_HOST=$wordpressdbhost WORDPRESS_DB_USER="$adminuser@$mysqlservername" WORDPRESS_DB_PASSWORD="$adminpassword"