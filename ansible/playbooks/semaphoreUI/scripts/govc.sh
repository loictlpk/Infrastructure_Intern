#!/bin/bash

VM_NAME=LOIC_VM
GOVC_FILENAME=./secure/govc.enc

# DEMARRAGE VM
export GOVC_URL=`openssl enc -aes-256-cbc -d -in $GOVC_FILENAME -k $1 -pbkdf2 -iter 100000 | sed -n '1p'`
export GOVC_USERNAME=`openssl enc -aes-256-cbc -d -in $GOVC_FILENAME -k $1 -pbkdf2 -iter 100000 | sed -n '2p'`
export GOVC_PASSWORD=`openssl enc -aes-256-cbc -d -in $GOVC_FILENAME -k $1 -pbkdf2 -iter 100000 | sed -n '3p'`
export GOVC_INSECURE=true
govc vm.power -on=true $VM_NAME 

# APPLICATION DU PLAYBOOK
echo "Attente du démarrage de la VM $VM_NAME" && sleep 20