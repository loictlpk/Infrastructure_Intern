#!/bin/bash

# https://www.shellhacks.com/encrypt-decrypt-file-password-openssl/

# 1 - Créer un fichier ".txt" contenant le mot de passe en clair.
# 2 - Crypter le fichier ".txt" avec openssl vers un autre fichier ".enc"
#           $ openssl enc -aes-256-cbc -salt -in <file>.txt -out <file>.enc -k PASS -pbkdf2 -iter 100000

# 3 - Supprimer le fichier ".txt" qui contient le mdp en clair
# 4 - Décrypter le fichier ".enc" grâce à ce script + "chmod 700"
            # $ openssl enc -aes-256-cbc -d -in /home/loic/secure/<file>.enc -k PASS -pbkdf2 -iter 100000

# 5 - copier le fichier vers /etc/ansible/vaultfile.sh && chmod +x

# mdp réel : root

# decryptage :
openssl enc -aes-256-cbc -d -in /home/loic/secure/encrypted.txt.enc -k PASS -pbkdf2 -iter 100000
