#!/usr/bin/env bash


ssh  ceph-server-1
ssh  ceph-server-2
ssh  ceph-server-3
ssh  ceph-client


# Dipendenza mancante per la dashboard
ssh  ceph-server-1 sudo apt-get install -yq python-routes
ssh  ceph-server-2 sudo apt-get install -yq python-routes
ssh  ceph-server-3 sudo apt-get install -yq python-routes
ssh  ceph-client sudo apt-get install -yq python-routes



mkdir my-cluster
cd my-cluster

#
#ceph-deploy purge ceph-server-1 ceph-server-2 ceph-server-3 ceph-client ceph-admin
#ceph-deploy purgedata ceph-admin ceph-server-1 ceph-server-2 ceph-server-3 ceph-client
#ceph-deploy forgetkeys
#rm ceph.*


ceph-deploy new ceph-server-1 ceph-server-2 ceph-server-3

echo "mon_clock_drift_allowed = 1" >> ceph.conf

ceph-deploy install ceph-admin ceph-server-1 ceph-server-2 ceph-server-3 ceph-client

ceph-deploy mon create-initial

ceph-deploy admin ceph-admin ceph-server-1 ceph-server-2 ceph-server-3 ceph-client

ceph-deploy mgr create ceph-server-1

ceph-deploy osd create --data /dev/sdc ceph-server-1
ceph-deploy osd create --data /dev/sdc ceph-server-2
ceph-deploy osd create --data /dev/sdc ceph-server-3