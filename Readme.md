Automatização do processo de instalação de um cluster Percona com 3 nodes Multi Master através de ShellScript.

# Pré-Requisitos
- 03 Hosts
- Sistema Operacional: Centos7
- Usuário root com mesma senha nos 03 Hosts.
- Know_hosts no Node02 e Node03.

# Script

- Link

# Configuração de Cluster Percona XtraDB-Backup

With Percona XtraDB Cluster you can write to any node, and the Cluster guarantees consistency of writes. That is, the write is either committed on all the nodes or not committed at all. For the simplicity, this diagram shows the use of the two-node example, but the same logic is applied with the N nodes.

# Xtrabackup

### Using Percona Xtrabackup

This is the default SST method (version 2 of it: xtrabackup-v2). This is the least blocking method as it uses backup locks. XtraBackup is run locally on the donor node, so it’s important that the correct user credentials are set up on the donor node. In order for PXC to perform the SST using the XtraBackup, credentials for connecting to the donor node need to be set up in the variable wsrep_sst_auth. Beside the credentials, one more important thing is that the datadir needs to be specified in the server configuration file my.cnf, otherwise the transfer process will fail.

# State Snapshot Transfer

State Snapshot Transfer is a full data copy from one node (donor) to the joining node (joiner). It’s used when a new node joins the cluster. In order to be synchronized with the cluster, new node has to transfer data from the node that is already part of the cluster. There are three methods of SST available in Percona XtraDB Cluster: mysqldump, rsync and xtrabackup. The downside of mysqldump and rsync is that the donor node becomes READ-ONLY while data is being copied from one node to another. Xtrabackup SST, on the other hand, uses backup locks, which means galera provider is not paused at all as with FTWRL (Flush Tables with Read Lock) earlier. State snapshot transfer method can be configured with the wsrep_sst_method variable.



# Reference

[Link de acesso à Documentação](https://www.percona.com/doc/percona-xtradb-cluster/5.6/features/multimaster-replication.html)
