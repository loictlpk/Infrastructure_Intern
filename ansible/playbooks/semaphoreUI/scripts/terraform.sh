#!/bin/bash

VSPHERE_FILENAME=./secure/vsphere.enc
TF_PATH=Bureau/STAGES/UC_TF/infrastructure
# syntaxe vars tf : TF_VAR_<nom de la variable>
export TF_VAR_vsphere_user=`openssl enc -aes-256-cbc -d -in $VSPHERE_FILENAME -k $1 -pbkdf2 -iter 100000 | sed -n '1p'` 
export TF_VAR_vsphere_password=`openssl enc -aes-256-cbc -d -in $VSPHERE_FILENAME -k $1 -pbkdf2 -iter 100000 | sed -n '2p'`
export TF_VAR_vsphere_domain=`openssl enc -aes-256-cbc -d -in $VSPHERE_FILENAME -k $1 -pbkdf2 -iter 100000 | sed -n '3p'`

# CREATION VM vSphere
terraform -chdir=$TF_PATH init 
terraform -chdir=$TF_PATH init -upgrade 
terraform -chdir=$TF_PATH apply -auto-approve 