#!/bin/bash

#------------------------------------------------------------------#
# Version: 1.0
# Date of create: 05/09/2019
# Create by: Eder Queiroz - ederbritodf@gmail.com
#------------------------------------------------------------------#

#######################
## VARIAVEIS GLOBAIS ##
#######################

SELINUX=/etc/selinux/config
REPOPERCONA=https://www.percona.com/downloads/Percona-XtraDB-Cluster-56/Percona-XtraDB-Cluster-5.6.44-28.34/binary/redhat/7/x86_64/$REPOVERSION
REPOVERSION=Percona-XtraDB-Cluster-server-56-5.6.44-28.34.1.el7.x86_64.rpm
PERC56=https://www.percona.com/downloads/Percona-XtraDB-Cluster-56/Percona-XtraDB-Cluster-5.6.44-28.34/binary/redhat/7/x86_64/
PERCVERSION=Percona-XtraDB-Cluster-5.6.44-28.34-r104-el7-x86_64-bundle.tar
MYCNF=/etc/my.cnf
MYCNFD=/etc/my.cnf.d/
CUSTOM=custom-conf-percona.cnf
DATA=`date +%d-%m-%Y-%H:%M:%S`
UMYSQL=sstuser
PWDMYSQL=P3rC0N4BacK4p
PASSSSH=/usr/bin/sshpass
COPY=/usr/bin/ssh-copy-id


#######################
### FIM VARIAVEIS #####
#######################


INFORME(){
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo " SCRIPT PARA CONFIGURAÇÃO CLUSTER PERCONA (GALERA3/XTRABACKUP/SST/WSREP)"
	echo " SYSTEM CENTOS 7 - 03 NODES"
	echo " PERCONA XTRADB CLUSTER 5.6 "
	echo " I.  configure o mesmo usuário e senha para todos os nodes do cluster"
	echo " II. faça conexão remota do host PRIMÁRIO para os demais HOSTS ssh"
	echo "       para que seja configurado nos nodes o arquivo know_hosts"
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo ""
}

HOSTS(){
echo ""
	echo "INFORME O IP DOS HOSTS QUE COMPOEM O CLUSTER"
	echo "--------------------------------------------"
	echo "INFORME O IP DO NODE1:"
	read NODE1
	echo "+IP ATRIBUIDO: $NODE1"
echo ""
	echo "INFORME O IP DO NODE2:"
	read NODE2
        echo "+IP ATRIBUIDO: $NODE2"
echo ""
	echo "INFORME O IP DO NODE3:"
	read NODE3
        echo "+IP ATRIBUIDO: $NODE3"
echo ""
	echo "|-----------|-----------|"
	echo "| HOSTS:    | IP:       |"
	echo "|-----------|-----------|"
	echo "| NODE1     | $NODE1|"
	echo "|-----------|-----------|"
	echo "| NODE2     | $NODE2|"
	echo "|-----------|-----------|"
	echo "| NODE3     | $NODE3|"
	echo "|-----------|-----------|"
echo ""

}

USERHOSTS(){
echo -n "INFORME O USUÁRIO DE CONEXAO REMOTA AOS NODES: "
read USERNODES
echo -n "INFORME A SENHA DO USUÁRIO $USERNODES: "
read -s PASSWDNODES
export -p PASSWDNODES
echo ""
}


CHAVESSH(){

echo ""
        echo "--------------------------------------------"
        echo "CONFIGURANDO CHAVE SSH RSA"
        echo "--------------------------------------------"
	ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
echo ""
        echo "REALIZANDO COPIA SSH PARA O NODE2 - $NODE2"
        $PASSSSH -p $PASSWDNODES $COPY $USERNODES@$NODE2
echo ""
        echo "REALIZANDO COPIA SSH PARA O NODE3 - $NODE3"
        $PASSSSH -p $PASSWDNODES $COPY $USERNODES@$NODE3
sleep 5
	echo "+CHAVES SSH"

}


PREREQS(){
echo ""
        echo "--------------------"
        echo "- UPDATE LINUX -"
        echo "--------------------"
        yum update -y
echo ""
        echo "--------------------"
        echo "- INSTALL PACKAGES -"
        echo "--------------------"
	yum install rsync lsof wget nmap perl-DBI perl-tests.x86_64 perl-Env.noarch perl-DBD-MySQL socat sshpass.x86_64 git scons gcc gcc-c++ openssl check cmake bison boost-devel asio-devel libaio-devel ncurses-devel readline-devel pam-devel -y 
echo ""
}

SELINUX(){
        echo "--------------------"
        echo "- DISABLE SELINUX -"
        echo "--------------------"
        setenforce 0
        sed -i "s/enforcing/permissive/g" $SELINUX
}

FIREWALL(){

        echo "--------------------"
        echo "- DISABLE FIREWALL -"
        echo "--------------------"
	systemctl stop firewalld
	systemctl disable firewalld
}

RPMPERCONA(){

        echo "---------------------------------"
        echo "- CONFIGURE REPOSITORIO PERCONA -"
        echo "---------------------------------"

	wget $PERC56$PERCVERSION
	tar -xvf $PERCVERSION

}



INSTALLPERCONA(){

        echo "-------------------"
        echo "- INSTALL PERCONA -"
        echo "-------------------"
	rpm -ivh Percona-XtraDB-Cluster-garbd-3-3.34-1.el7.x86_64.rpm
	rpm -ivh Percona-XtraDB-Cluster-client-56-5.6.44-28.34.1.el7.x86_64.rpm
	rpm -ivh Percona-XtraDB-Cluster-devel-56-5.6.44-28.34.1.el7.x86_64.rpm
	rpm -ivh Percona-XtraDB-Cluster-56-debuginfo-5.6.44-28.34.1.el7.x86_64.rpm
	rpm -ivh Percona-XtraDB-Cluster-test-56-5.6.44-28.34.1.el7.x86_64.rpm 
	rpm -ivh Percona-XtraDB-Cluster-galera-3-debuginfo-3.34-1.el7.x86_64.rpm 
	rpm -ivh Percona-XtraDB-Cluster-galera-3-3.34-1.el7.x86_64.rpm
	yum remove mariadb-libs -y
	rpm -ivh Percona-XtraDB-Cluster-shared-56-5.6.44-28.34.1.el7.x86_64.rpm
	yum install http://repo.percona.com/yum/percona-release-1.0-3.noarch.rpm -y
	yum install percona-xtrabackup perl-DBD-MySQL.x86_64 -y
	rpm -ivh Percona-XtraDB-Cluster-server-56-5.6.44-28.34.1.el7.x86_64.rpm 
	yum install Percona-XtraDB-Cluster-full-56 -y
   	 
         INICIAPERCONA
}


INICIAPERCONA(){
	
        echo "-------------------"
        echo "- INICIA PERCONA -"
        echo "-------------------"
	systemctl start mysql@bootstrap
	systemctl enable mysql
	echo " +++ Inicializando PERCONA BOOTSTRAP ..."	
	
	sleep 10
	echo " Aguarde ..."
	VALIDAPERCONA
}


VALIDAPERCONA(){
        echo "--------------------------"
        echo "- VALIDA SERVICO PERCONA -"
        echo "--------------------------"

	systemctl status mysql@bootstrap
	echo $?
	  if [ $? -eq 0 ]; then
	echo "+MYSQL IS RUNNING"
	FUNCTIONSPERCONA
	else
	 echo "-MYSQL IS ERROR"
	EXITPERCONA
	 fi
	
	
}

FUNCTIONSPERCONA(){
        echo "-------------------"
        echo "-FUNCTIONS PERCONA-"
        echo "-------------------"
	mysql -e "CREATE FUNCTION fnv1a_64 RETURNS INTEGER SONAME 'libfnv1a_udf.so'"
	mysql -e "CREATE FUNCTION fnv_64 RETURNS INTEGER SONAME 'libfnv_udf.so'"
	mysql -e "CREATE FUNCTION murmur_hash RETURNS INTEGER SONAME 'libmurmur_udf.so'"

	USRPERCONA
}

USRPERCONA (){

#State Snapshot Transfer is the full copy of data from one node to another. 
#It’s used when a new node joins the cluster, it has to transfer data from existing node.
echo ""
	echo "---------------------------"
	echo "+CRIANDO USUÁRIO DE SERVIÇO"
        echo "---------------------------"
echo ""
	mysql -e "CREATE USER '$UMYSQL'@'localhost' IDENTIFIED BY '$PWDMYSQL';"
	mysql -e "GRANT RELOAD, LOCK TABLES, PROCESS, REPLICATION CLIENT ON *.* TO '$UMYSQL'@'localhost';"
	mysql -e "FLUSH PRIVILEGES;"
echo ""
}

EXITPERCONA(){
	
echo ""
	echo "------------------------------"
	echo "FALHA NA INSTALAÇÃO DO PERCONA"
	echo "------------------------------"
	echo "- INSTALAÇÃO CANCELADA"
	exit
}


CONFIGURANODE1(){

        echo "------------------------------"
        echo "-STOP PERCONA - $NODE1 "
        echo "------------------------------"
        systemctl stop mysql@bootstrap

        echo "----------------------------"     
        echo " CONFIGURE - $MYCNF  "
        echo "----------------------------"

	#REMOVE LINHA STRING WSREP
	sed -i '/wsrep_cluster_address/d' $MYCNF
	sed -i '/wsrep_provider/d' $MYCNF
	sed -i '/wsrep_cluster_name/d' $MYCNF
	sed -i '/wsrep_node_name/d' $MYCNF
	#FIM REMOVE WSREP

        echo "----------------------------"     
        echo " CUSTOM CONFIGURE - $NODE1  "
        echo "----------------------------"

	touch $MYCNFD$CUSTOM
	echo "" >> $MYCNFD$CUSTOM
	echo "##########################" >> $MYCNFD$CUSTOM
	echo "# ADD BY SCRIPT - $DATA" >> $MYCNFD$CUSTOM
	echo "##########################" >> $MYCNFD$CUSTOM
echo ""
	echo "" >> $MYCNFD$CUSTOM
	echo "[mysqld]" >> $MYCNFD$CUSTOM
	echo "wsrep_provider=/usr/lib64/galera3/libgalera_smm.so" >> $MYCNFD$CUSTOM
echo "" >> $MYCNFD$CUSTOM
	echo "wsrep_cluster_name=pxc-cluster" >> $MYCNFD$CUSTOM
	echo "wsrep_cluster_address=gcomm://" >> $MYCNFD$CUSTOM
#$NODE1,$NODE2,$NODE3 >> $MYCNFD$CUSTOM
	echo "wsrep_node_name=pxc1" >> $MYCNFD$CUSTOM
	echo "wsrep_node_address=$NODE1" >> $MYCNFD$CUSTOM
	echo "" >> $MYCNFD$CUSTOM
	echo "wsrep_sst_method=xtrabackup-v2" >> $MYCNFD$CUSTOM
	echo "wsrep_sst_auth=$UMYSQL:$PWDMYSQL" >> $MYCNFD$CUSTOM
	echo "" >> $MYCNFD$CUSTOM
	echo "binlog_format=ROW" >> $MYCNFD$CUSTOM
	echo "default_storage_engine=InnoDB" >> $MYCNFD$CUSTOM
	echo "innodb_autoinc_lock_mode=2" >> $MYCNFD$CUSTOM
	systemctl start mysql@bootstrap
}


CONFIGURANODE2(){

        echo "---------------------------"
        echo "- INSTALL PKGS $NODE2 - "
        echo "---------------------------"

        ssh $USERNODES@$NODE2 'yum install rsync lsof wget nmap perl-DBI perl-tests.x86_64 perl-Env.noarch perl-DBD-MySQL socat sshpass.x86_64 -y'

echo ""
        echo "---------------------------"
        echo "- DISABLE SELINUX $NODE2 -"
        echo "---------------------------"

        ssh $USERNODES@$NODE2 setenforce 0
        ssh $USERNODES@$NODE2 sed -i "s/enforcing/permissive/g" $SELINUX

        echo "-----------------------------"
        echo "- DISABLE FIREWALL - $NODE2  "
        echo "-----------------------------"

        ssh $USERNODES@$NODE2 systemctl stop firewalld
        ssh $USERNODES@$NODE2 systemctl disable firewalld

        echo "---------------------------------------------"
        echo "- CONFIGURE REPOSITORIO PERCONA - $NODE2"
        echo "---------------------------------------------"

        ssh $USERNODES@$NODE2 wget $PERC56$PERCVERSION
        ssh $USERNODES@$NODE2 tar -xvf $PERCVERSION

        echo "-----------------------------"
        echo "- INSTALL PERCONA - $NODE2 "
        echo "-----------------------------"
        ssh $USERNODES@$NODE2 rpm -ivh Percona-XtraDB-Cluster-garbd-3-3.34-1.el7.x86_64.rpm
        ssh $USERNODES@$NODE2 rpm -ivh Percona-XtraDB-Cluster-client-56-5.6.44-28.34.1.el7.x86_64.rpm
        ssh $USERNODES@$NODE2 rpm -ivh Percona-XtraDB-Cluster-devel-56-5.6.44-28.34.1.el7.x86_64.rpm
        ssh $USERNODES@$NODE2 rpm -ivh Percona-XtraDB-Cluster-56-debuginfo-5.6.44-28.34.1.el7.x86_64.rpm
        ssh $USERNODES@$NODE2 rpm -ivh Percona-XtraDB-Cluster-test-56-5.6.44-28.34.1.el7.x86_64.rpm
        ssh $USERNODES@$NODE2 rpm -ivh Percona-XtraDB-Cluster-galera-3-debuginfo-3.34-1.el7.x86_64.rpm
        ssh $USERNODES@$NODE2 rpm -ivh Percona-XtraDB-Cluster-galera-3-3.34-1.el7.x86_64.rpm
        ssh $USERNODES@$NODE2 yum remove mariadb-libs -y
        ssh $USERNODES@$NODE2 rpm -ivh Percona-XtraDB-Cluster-shared-56-5.6.44-28.34.1.el7.x86_64.rpm
        ssh $USERNODES@$NODE2 yum install http://repo.percona.com/yum/percona-release-1.0-3.noarch.rpm -y
        ssh $USERNODES@$NODE2 yum install percona-xtrabackup perl-DBD-MySQL.x86_64 -y
        ssh $USERNODES@$NODE2 rpm -ivh Percona-XtraDB-Cluster-server-56-5.6.44-28.34.1.el7.x86_64.rpm
        ssh $USERNODES@$NODE2 yum install Percona-XtraDB-Cluster-full-56 -y


        echo "----------------------------"
        echo "- INICIA PERCONA - $NODE2   "
        echo "----------------------------"
        ssh $USERNODES@$NODE2 systemctl start mysql
        ssh $USERNODES@$NODE2 systemctl enable mysql
        ssh $USERNODES@$NODE2 echo " +++ Inicializando PERCONA $NODE2..."
        ssh $USERNODES@$NODE2 sleep 5

#        echo "----------------------------------"
#        echo "-FUNCTIONS PERCONA - $NODE2"
#        echo "----------------------------------"
#	ssh $USERNODES@$NODE2 'sleep 5'
#	sleep 5
#        ssh $USERNODES@$NODE2 mysql -e "CREATE FUNCTION fnv1a_64 RETURNS INTEGER SONAME 'libfnv1a_udf.so'"
#        ssh $USERNODES@$NODE2 mysql -e "CREATE FUNCTION fnv_64 RETURNS INTEGER SONAME 'libfnv_udf.so'"
#        ssh $USERNODES@$NODE2 mysql -e "CREATE FUNCTION murmur_hash RETURNS INTEGER SONAME 'libmurmur_udf.so'"

        echo "------------------------------"
        echo "-STOP PERCONA - $NODE2 "
        echo "------------------------------"
        ssh $USERNODES@$NODE2 'systemctl stop mysql'

        echo "----------------------------"     
        echo " CONFIGURE - $MYCNF  "
        echo "----------------------------"

	#REMOVE LINHA STRING WSREP
        ssh $USERNODES@$NODE2 'sed -i "/wsrep_cluster_address/d" '$MYCNF' '
        ssh $USERNODES@$NODE2 'sed -i "/wsrep_provider/d" '$MYCNF' '
        ssh $USERNODES@$NODE2 'sed -i "/wsrep_cluster_name/d" '$MYCNF' '
        ssh $USERNODES@$NODE2 'sed -i "/wsrep_node_name/d" '$MYCNF' '
        
	echo "----------------------------"	
	echo " CUSTOM CONFIGURE - $NODE2  "
	echo "----------------------------"

	ssh $USERNODES@$NODE2 'touch '$MYCNFD$CUSTOM''
	ssh $USERNODES@$NODE2 'echo "" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE2 'echo "##########################" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE2 'echo "# ADD BY SCRIPT - '$DATA'" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE2 'echo "##########################" >> '$MYCNFD$CUSTOM' '
	ssh $USERNODES@$NODE2 'echo "[mysqld]" >> '$MYCNFD$CUSTOM''
        ssh $USERNODES@$NODE2 'echo "" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE2 'echo "wsrep_provider=/usr/lib64/galera3/libgalera_smm.so" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE2 'echo "" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE2 'echo "wsrep_cluster_name=pxc-cluster" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE2 'echo "wsrep_cluster_address=gcomm://'$NODE1','$NODE2','$NODE3'" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE2 'echo "wsrep_node_name=pxc2" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE2 'echo "wsrep_node_address='$NODE2'" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE2 'echo "" >> '$MYCNFD$CUSTOM''
        ssh $USERNODES@$NODE2 'echo "wsrep_sst_method=xtrabackup-v2" >> '$MYCNFD$CUSTOM''
        ssh $USERNODES@$NODE2 'echo "wsrep_sst_auth='$UMYSQL':'$PWDMYSQL'" >> '$MYCNFD$CUSTOM''
        ssh $USERNODES@$NODE2 'echo "" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE2 'echo "" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE2 'echo "binlog_format=ROW" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE2 'echo "default_storage_engine=InnoDB" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE2 'echo "innodb_autoinc_lock_mode=2" >> '$MYCNFD$CUSTOM''
        echo "------------------------------"
        echo "+INICIA PERCONA - $NODE2 "
        echo "------------------------------"
	ssh $USERNODES@$NODE2 'systemctl start mysql'
}

REPNODE2(){

        echo "--------------------------"
        echo "  Criando TABELA $NODE2 "
        echo "--------------------------"
        ssh $USERNODES@$NODE2 'mysql -e "USE percona"'
        ssh $USERNODES@$NODE2 'mysql -e "INSERT INTO percona.example VALUES (1, 'percona1');"'

}

CONFIGURANODE3(){

        echo "---------------------------"
        echo "- INSTALL PKGS $NODE3 - "
        echo "---------------------------"

	ssh $USERNODES@$NODE3 'yum install rsync lsof wget nmap perl-DBI perl-tests.x86_64 perl-Env.noarch perl-DBD-MySQL socat sshpass.x86_64 -y'

echo ""
        echo "---------------------------"
        echo "- DISABLE SELINUX $NODE3 -"
        echo "---------------------------"

	ssh $USERNODES@$NODE3 setenforce 0
	ssh $USERNODES@$NODE3 sed -i "s/enforcing/permissive/g" $SELINUX

        echo "-----------------------------"
        echo "- DISABLE FIREWALL - $NODE3  "
        echo "-----------------------------"

	ssh $USERNODES@$NODE3 systemctl stop firewalld
        ssh $USERNODES@$NODE3 systemctl disable firewalld

        echo "---------------------------------------------"
        echo "- CONFIGURE REPOSITORIO PERCONA - $NODE3"
        echo "---------------------------------------------"

        ssh $USERNODES@$NODE3 wget $PERC56$PERCVERSION
        ssh $USERNODES@$NODE3 tar -xvf $PERCVERSION

        echo "-----------------------------"
        echo "- INSTALL PERCONA - $NODE3 "
        echo "-----------------------------"

	ssh $USERNODES@$NODE3 rpm -ivh Percona-XtraDB-Cluster-garbd-3-3.34-1.el7.x86_64.rpm
        ssh $USERNODES@$NODE3 rpm -ivh Percona-XtraDB-Cluster-client-56-5.6.44-28.34.1.el7.x86_64.rpm
        ssh $USERNODES@$NODE3 rpm -ivh Percona-XtraDB-Cluster-devel-56-5.6.44-28.34.1.el7.x86_64.rpm
        ssh $USERNODES@$NODE3 rpm -ivh Percona-XtraDB-Cluster-56-debuginfo-5.6.44-28.34.1.el7.x86_64.rpm
        ssh $USERNODES@$NODE3 rpm -ivh Percona-XtraDB-Cluster-test-56-5.6.44-28.34.1.el7.x86_64.rpm
        ssh $USERNODES@$NODE3 rpm -ivh Percona-XtraDB-Cluster-galera-3-debuginfo-3.34-1.el7.x86_64.rpm
        ssh $USERNODES@$NODE3 rpm -ivh Percona-XtraDB-Cluster-galera-3-3.34-1.el7.x86_64.rpm
        ssh $USERNODES@$NODE3 yum remove mariadb-libs -y
        ssh $USERNODES@$NODE3 rpm -ivh Percona-XtraDB-Cluster-shared-56-5.6.44-28.34.1.el7.x86_64.rpm
        ssh $USERNODES@$NODE3 yum install http://repo.percona.com/yum/percona-release-1.0-3.noarch.rpm -y
        ssh $USERNODES@$NODE3 yum install percona-xtrabackup perl-DBD-MySQL.x86_64 -y
        ssh $USERNODES@$NODE3 rpm -ivh Percona-XtraDB-Cluster-server-56-5.6.44-28.34.1.el7.x86_64.rpm
        ssh $USERNODES@$NODE3 yum install Percona-XtraDB-Cluster-full-56 -y


        echo "----------------------------"
        echo "- INICIA PERCONA - $NODE3   "
        echo "----------------------------"
	ssh $USERNODES@$NODE3 systemctl start mysql
        ssh $USERNODES@$NODE3 systemctl enable mysql
        ssh $USERNODES@$NODE3 echo " +++ Inicializando PERCONA $NODE3..."
	ssh $USERNODES@$NODE3 sleep 5
	sleep 5

#        echo "----------------------------------"
#        echo "-FUNCTIONS PERCONA - $NODE3"
#        echo "----------------------------------"
#	ssh $USERNODES@$NODE3 mysql -e "CREATE FUNCTION fnv1a_64 RETURNS INTEGER SONAME 'libfnv1a_udf.so'"
#        ssh $USERNODES@$NODE3 mysql -e "CREATE FUNCTION fnv_64 RETURNS INTEGER SONAME 'libfnv_udf.so'"
#        ssh $USERNODES@$NODE3 mysql -e "CREATE FUNCTION murmur_hash RETURNS INTEGER SONAME 'libmurmur_udf.so'"

        echo "------------------------------"
        echo "-STOP PERCONA - $NODE3 "
        echo "------------------------------"
	ssh $USERNODES@$NODE3 'systemctl stop mysql'

	echo "----------------------------"     
        echo " CONFIGURE - $MYCNF  "
        echo "----------------------------"

	#REMOVE LINHA STRING WSREP
        ssh $USERNODES@$NODE3 'sed -i '/wsrep_cluster_address/d' '$MYCNF' '
        ssh $USERNODES@$NODE3 'sed -i '/wsrep_provider/d' '$MYCNF' '
        ssh $USERNODES@$NODE3 'sed -i '/wsrep_cluster_name/d' '$MYCNF' '
        ssh $USERNODES@$NODE3 'sed -i '/wsrep_node_name/d' '$MYCNF' '
	

        echo "----------------------------"     
        echo " CUSTOM CONFIGURE - $NODE3  "
        echo "----------------------------"

        ssh $USERNODES@$NODE3 'touch '$MYCNFD$CUSTOM''
        ssh $USERNODES@$NODE3 'echo "" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE3 'echo "##########################" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE3 'echo "# ADD BY SCRIPT - '$DATA'" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE3 'echo "##########################" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE3 'echo "[mysqld]" >> '$MYCNFD$CUSTOM''
        ssh $USERNODES@$NODE3 'echo "" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE3 'echo "wsrep_provider=/usr/lib64/galera3/libgalera_smm.so" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE3 'echo "" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE3 'echo "wsrep_cluster_name=pxc-cluster" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE3 'echo "wsrep_cluster_address=gcomm://'$NODE1','$NODE3','$NODE3'" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE3 'echo "wsrep_node_name=pxc3" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE3 'echo "wsrep_node_address='$NODE3'" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE3 'echo "" >> '$MYCNFD$CUSTOM''
        ssh $USERNODES@$NODE3 'echo "wsrep_sst_method=xtrabackup-v2" >> '$MYCNFD$CUSTOM''
        ssh $USERNODES@$NODE3 'echo "wsrep_sst_auth='$UMYSQL':'$PWDMYSQL'" >> '$MYCNFD$CUSTOM''
        ssh $USERNODES@$NODE3 'echo "" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE3 'echo "" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE3 'echo "binlog_format=ROW" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE3 'echo "default_storage_engine=InnoDB" >> '$MYCNFD$CUSTOM' '
        ssh $USERNODES@$NODE3 'echo "innodb_autoinc_lock_mode=2" >> '$MYCNFD$CUSTOM''

        echo "------------------------------"
        echo "+INICIA PERCONA - $NODE3 "
        echo "------------------------------"
	ssh $USERNODES@$NODE3 'systemctl start mysql'
}

REPNODE3(){

        echo "--------------------------"
        echo "  SELECT TABELA $NODE3 "
        echo "--------------------------"
        ssh $USERNODES@$NODE3 'mysql -e "USE percona"'
        ssh $USERNODES@$NODE3 'mysql -e "SELECT * FROM percona.example;"'

}


BOOTSTRAPPING(){

echo ""
	echo "--------------------"
	echo "+INICIANDO PERCONA BOOTSTRAPPING"
	echo "--------------------"
echo ""
	systemctl start mysql@bootstrap.service
echo ""
	echo "Para certificar-se que o cluster foi inicializado:"
echo ""
	mysql -e "show status like 'wsrep%';"
}

VERIFYREPLICATION(){

#Use the following procedure to verify replication by creating a new database on the second node
#creating a table for that database on the third node, and adding some records to the table on the first node.
	echo "--------------------------"
	echo "  Criando DATABASE $NODE1 "
	echo "--------------------------"
echo ""
	mysql -e "CREATE DATABASE percona;"
}

STOPALL(){

echo ""
        echo "----------------------"
        echo "+STOP MYSQL $NODE3"
        echo "----------------------"
echo""
        ssh $USERNODES@$NODE3 'systemctl stop mysql'
	sleep 5

echo ""
        echo "----------------------"
        echo "+STOP MYSQL $NODE2"
        echo "----------------------"
echo""

        ssh $USERNODES@$NODE2 'systemctl stop mysql'
        sleep 5

echo ""
        echo "----------------------"
        echo "+STOP MYSQL BOOTSTRAP $NODE1"
        echo "----------------------"
echo""
	systemctl stop mysql@bootstrap
	sleep 5
}


STARTALL(){

echo ""
        echo " -----------------------------"
        echo " CONFIG ORDEM INICIALIZAÇÃO   "
        echo "------------------------------"
	echo "1. $NODE1"
	echo "2. $NODE2"
	echo "3. $NODE3"
echo ""


echo ""
        echo "----------------------"
        echo "+START MYSQL BOOTSTRAP $NODE1"
        echo "----------------------"
echo""
        systemctl start mysql@bootstrap
        sleep 10


echo ""
        echo "----------------------"
        echo "+START MYSQL $NODE2"
        echo "----------------------"
echo""

        ssh $USERNODES@$NODE2 'systemctl start mysql'
        sleep 5

echo ""
        echo "----------------------"
        echo "+START MYSQL $NODE3"
        echo "----------------------"
echo""
        ssh $USERNODES@$NODE3 'systemctl start mysql'
        sleep 5
}



MONITOR(){

echo ""
	echo "----------------------"
	echo "+EXIBINDO SAÍDA MONITOR"
	echo "----------------------"
echo""
	mysql -e "SHOW STATUS LIKE 'wsrep_local_state_comment';"
echo ""
	echo "-----------------------"
	echo " + LISTA QTD. CLUSTER "
	echo "-----------------------"
	mysql -e "show global status like 'wsrep_cluster_size';"

}

EXITHOST(){
echo ""
	echo "LOGOUT HOST"
	exit
}

CONFIGCLUSTER(){

echo ""
	echo "-----------------------------------------------------------"
	echo "ATUALIZA VARIAVEL: "wsrep_cluster_address" NO NODE MASTER  "
	echo "-----------------------------------------------------------"
	echo "Configurando variável ..."
	echo "wsrep_cluster_address=gcomm://'$NODE1','$NODE3','$NODE3'"
	sed -i '/wsrep_cluster_address/d' $MYCNFD$CUSTOM
	echo "wsrep_cluster_address=gcomm://'$NODE1','$NODE3','$NODE3'" >> $MYCNFD$CUSTOM
	echo "------------------------------------"
	echo "STOP MYSQL@BOOTSTRAP - $NODE1 "
	echo "------------------------------------"
	systemctl stop mysql@bootstrap
	echo "------------------------------------"
	echo "START MYSQL - $NODE1"
	echo "------------------------------------"
	systemctl start mysql
}

INFORME
HOSTS
USERHOSTS
PREREQS
SELINUX
FIREWALL
CHAVESSH
RPMPERCONA
INSTALLPERCONA
CONFIGURANODE2
CONFIGURANODE3
CONFIGURANODE1
STOPALL
STARTALL
MONITOR
CONFIGCLUSTER
MONITOR
#VERIFYREPLICATION
#REPNODE2
#REPNODE3
