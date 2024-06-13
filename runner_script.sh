#!/bin/bash

# NEED : $  sudo cp secure/vaultfile.sh /root/secure/vaultfile.sh && sudo chmod +x /root/secure/vaultfile.sh
# INSTALL GOVC : https://github.com/vmware/govmomi?tab=readme-ov-file
# https://fabianlee.org/2019/03/09/vmware-using-the-govc-cli-to-automate-vcenter-commands/

# VARS
VM_NAME=LOIC_VM
# Uniquement pour l'utilisateur personnel
# TF_PATH=./  
# VSPHERE_PATH=/home/gitlab-runner/builds/5W7ihR8Hd/0/stageloic/infrastructure/secure/vsphere.enc
# GOVC_PATH=/home/gitlab-runner/builds/5W7ihR8Hd/0/stageloic/infrastructure/secure/govc.enc
VSPHERE_FILENAME=secure/vsphere.enc
GOVC_FILENAME=secure/govc.enc
# cd $TF_PATH

# syntaxe vars tf : TF_VAR_<nom de la variable>
export TF_VAR_vsphere_user=`openssl enc -aes-256-cbc -d -in $VSPHERE_FILENAME -k $1 -pbkdf2 -iter 100000 | sed -n '1p'` 
export TF_VAR_vsphere_password=`openssl enc -aes-256-cbc -d -in $VSPHERE_FILENAME -k $1 -pbkdf2 -iter 100000 | sed -n '2p'`
export TF_VAR_vsphere_domain=`openssl enc -aes-256-cbc -d -in $VSPHERE_FILENAME -k $1 -pbkdf2 -iter 100000 | sed -n '3p'`
# CREATION VM vSphere
terraform init 
terraform init -upgrade 
terraform apply -auto-approve 

# DEMARRAGE VM
export GOVC_URL=`openssl enc -aes-256-cbc -d -in $GOVC_FILENAME -k $1 -pbkdf2 -iter 100000 | sed -n '1p'`
export GOVC_USERNAME=`openssl enc -aes-256-cbc -d -in $GOVC_FILENAME -k $1 -pbkdf2 -iter 100000 | sed -n '2p'`
export GOVC_PASSWORD=`openssl enc -aes-256-cbc -d -in $GOVC_FILENAME -k $1 -pbkdf2 -iter 100000 | sed -n '3p'`
export GOVC_INSECURE=true
govc vm.power -on=true $VM_NAME 

# APPLICATION DU PLAYBOOK
echo "Attente du démarrage de la VM $VM_NAME" && sleep 20

# L'utilisateur local "gitlab-runner" doit posséder un clé ssh personnel et sa clé publique doit figurer dans la machine debian 
# On peut copier coller les clés privée et publique ainsi que la ligne spécifique à la VM dans knownhosts de l'utilisateur "loic" vers l'utilisateur "gitlab-runner"
# >>>>>>>>> sudo cp id_rsa /home/gitlab-runner/.ssh/id_rsa
# >>>>>>>>> sudo cp id_rsa.pub /home/gitlab-runner/.ssh/id_rsa.pub
# >>>>>>>>> sudo nano /home/loic/.ssh/known_hosts
# copier la ligne correspondante
# >>>>>>>>> sudo nano /home/gitlab-runner/.ssh/known_hosts
# coller la ligne correspondante
ansible-playbook ansible/playbooks/entrypoint.yml 

