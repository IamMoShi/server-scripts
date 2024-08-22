#!/bin/bash

bash is-admin.sh

echo "Création d'un utilisateur admin"
# Nom de l'utilisateur à créer
username="moshi"

if id "$username" &>/dev/null; then

	echo "L'utilisateur '$username' exise déjà."  
	
else 

	# Mot de passe de l'utilisateur admin
	read -reps "Mot de passe de l'administrateur moshi: " password
	echo ""
	
	# Créer l'utilisateur avec un répertoire personnel et une connexion shell par défaut
	useradd -m -s /bin/bash "$username"
	
	# Définir le mot de passe de l'utilisateur
	echo "$username:$motdepasse" | chpasswd
	
	# Afficher un message de confirmation 
	echo "L'utilisateur '$username' a été créé avec succès et son mot de passe a été défini."
	
fi

if ! groups "$username" | grep -q -E '\b(sudo|wheel)\b'; then 

	echo "L'utilisateur '$username' n'a pas de privilèges sudo. Ajout des privilèges" 
	# Ajout de l'utilisateur au groupe des administrateurs
	usermod -aG sudo "$username"
	
fi
