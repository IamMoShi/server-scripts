#!/bin/bash

bash is-admin.sh

bash adminuser.sh

# ------------------------------------------

# Initialiser la configuration SSH
ssh_config="# ------------------ automatic script by moshi ------------------\n"

# Demander le port SSH
read -rep "SSH Configuration : \n  - Veuillez entrer le port utilisé par la connexion SSH : " ssh_port

# Ajouter le port à la configuration
ssh_config+="Port $ssh_port\n"

# Limiter l'accès aux clés
read -rep "Limiter l'accès aux clés [Y/n] : " keys

if [[ $keys != [Nn]* ]]; then
    echo "Seules les connexions avec clé seront autorisées"
    ssh_config+="PasswordAuthentication no\n"
else 
    echo "Les connexions avec mot de passe seront autorisées"
    ssh_config+="PasswordAuthentication yes\n"
fi

# Bloquer l'accès root
read -rep "Bloquer l'accès root [Y/n] : " root_log

if [[ $root_log != [Nn]* ]]; then
    echo "La connexion SSH en tant que root ne sera plus possible"
    ssh_config+="PermitRootLogin no\n"
else
    echo "Paramètres par défaut pour la connexion root"
    ssh_config+="PermitRootLogin yes\n"
fi

# Finaliser la configuration SSH
ssh_config+="# ------------------------------------------------------\n"

# Écrire la configuration dans le fichier de configuration SSH
echo -e "$ssh_config" > /etc/ssh/sshd_config.d/moshi.conf

echo "La configuration SSH a été écrite dans /etc/ssh/sshd_config.d/moshi.conf"

# Demander si l'utilisateur souhaite ajouter une clé SSH 
read -p "Souhaitez-vous ajouter une clé de connexion SSH pour l'utilisateur $username [Y/n] ? " add_ssh_key

# Si l'utilisateur souhaite ajouter une clé SSH (par défaut, la réponse est 'yes') 

if [[ $add_ssh_key != [Nn]* ]]; then 
	echo "Veuillez entrer la clé publique SSH (terminée par [ENTER] et une ligne vide) :" # Lire la clé publique SSH de l'utilisateur 
	ssh_key="" 
	
	while IFS= read -r line; do 
	# Lire jusqu'à une ligne vide 
		[[ -z "$line" ]] && break 
		ssh_key+="$line\n" 
	done 
	
	# Vérifier que la clé n'est pas vide 
	if [[ -z "$ssh_key" ]]; then 
		echo "Erreur : Aucune clé publique SSH fournie. L'ajout de la clé a échoué." 
		exit 1 
	fi
	
	# Créer le répertoire .ssh de l'utilisateur s'il n'existe pas 
	mkdir -p /home/"$username"/.ssh chmod 700 /home/"$username"/.ssh 
	
	# Ajouter la clé publique au fichier authorized_keys 
	echo -e "$ssh_key" > /home/"$username"/.ssh/authorized_keys 
	chmod 600 /home/"$username"/.ssh/authorized_keys 
	chown -R "$username":"$username" /home/"$username"/.ssh 
	echo "La clé publique SSH a été ajoutée avec succès pour l'utilisateur '$username'." 
else 
	echo "Aucune clé SSH n'a été ajoutée pour l'utilisateur '$username'." 
fi