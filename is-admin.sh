#!/bin/bash

# Vérifier si le script est exécuté avec les privilèges root
if [[ $EUID -ne 0 ]]; then
   echo "Ce script doit être exécuté en tant que root" 
   exit 1
fi
