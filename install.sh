#!/usr/bin/env bash

echo -ne "Installation du programme tv-record. Le programme d'installation\n efface le crontab, il faut donc faire une sauvegarde de celui-ci si vous l'avez modifié avant\n de faire l'installation.\n"

http=$(curl -I https://tv-select.fr | grep HTTP | tail -1 | cut -d " " -f 2)

if [ "$http" != '200' ]
then
    echo -ne "\nLa box tv-select n'est pas connectée à internet. Veuillez vérifier votre connection internet et relancer le programme d'installation.\n\n"
    exit 0
fi

echo -n "Veuillez saisir votre identifiant de connexion (adresse email) sur tv-select.fr: "
read -r identifiant

echo -n "Veuillez saisir votre mot de passe sur tv-select.fr: "
read -r password_tvrecord

authprog=$(curl -iSu $identifiant:$password_tvrecord https://www.tv-select.fr/api/v1/prog | grep HTTP | cut -d " " -f 2)

echo $authprog

while [ $authprog != "200" ]
do

    echo -ne "Le couple identifiant de connexion et mot de passe est incorrecte\nVoulez-vous essayer de nouveau?(oui ou non) :"
    read -r tryagain

    if [ $tryagain = 'oui' ]
    then
        echo -n "Veuillez saisir de nouveau votre identifiant de connexion (adresse email) sur tv-select.fr: "
        read -r identifiant

        echo -n "Veuillez saisir de nouveau votre mot de passe sur tv-select.fr: "
        read -r password_tvrecord

        authprog=$(curl -iSu $identifiant:$password_tvrecord https://www.tv-select.fr/api/v1/prog | grep HTTP | cut -d " " -f 2)
    else
        exit 0
    fi
done

sed -i '3s/.*/cd \/home\/'$USER'\/Vidéos/' launch_record.sh

heure=$(shuf -i 6-23 -n1)
minute=$(shuf -i 0-58 -n1)

echo -ne " Votre box TV-select va être configuré pour demander les informations nécessaires aux enregistrements
 à $heure:$minute . Votre box TV-select n'a besoin d'être connectée à internet seulement pendant 1 seconde par jour 
 pour obtenir les informations nécessaires. Si votre box TV-select ne peut pas être connecté à internet à l'heure
 proposée, vous pouvez définir l'horaire manuellement. Voulez-vous changer l'horaire de téléchargement des
 informations d'enregistrements? Répondez par oui si vous voulez changer l'horaire de $heure:$minute ou non si
 votre connection internet sera disponible à cette horaire: "

read -r reponse_internet

if [ $reponse_internet = 'oui' ]
then
    heure=24
    while [ $heure -lt 6 -o $heure -gt 23 ]
    do
        echo -ne "Choisissez une heure entre 6 et 23 (si vous ne pouvez avoir une connection internet que entre minuit et 6 heures du matin, contactez le
support de TV-select afin de contourner cette restriction): "
        read -r heure
    done
    minute=60
    while [ $minute -lt 0 -o $minute -gt 58 ]
    do
        echo -ne "Choisissez les minutes entre 0 et 58: "
        read -r minute
    done
    echo -ne "Votre box TV-select va être configuré pour demander les informations nécessaires aux enregistrements à $heure:$minute"
fi

minute_2="$((minute+1))"

crontab -l > cron_tasks.sh

echo "$minute $heure * * * curl -H 'Accept: application/json; indent=4' --user '$identifiant:$password_tvrecord' https://www.tv-select.fr/api/v1/prog > /home/$USER/box/info_progs.json 2>> /var/tmp/cron_curl.log" > cron_tasks.sh

echo "$minute_2 $heure * * * cd /home/$USER/box && bash cron_launch_record.sh" >> cron_tasks.sh

crontab cron_tasks.sh

rm cron_tasks.sh

echo -ne "\nVotre box TV-select est maintenant configuré pour enregistrer les vidéos!\n\n"
