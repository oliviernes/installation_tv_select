# box

## Instructions d'installations:

sudo apt update && sudo apt install jq dvb-apps w-scan at curl

mkdir ~/.tzap

### La commande suivante demande entre 20 et 30 minutes avant d'être terminée:
w_scan -f t -c FR -X > ~/.tzap/channels.conf

### La commande suivante permet d'uniformiser les informations de multiplexage (à lancer après la fin de la commande w_scan):
sed -i -e 's/GR1\ B/GR1\ A/g' /home/$USER/.tzap/channels.conf

### Les 2 commandes précédentes (commençant pas w_scan et sed) sont à lancer de nouveau si vous déménagez loin de votre résidence ou si les fréquences de diffusion des chaînes ont changé.

cd ~ && curl https://github.com/oliviernes/installation_tv_select/archive/refs/heads/master.zip -L -o box.zip

unzip box.zip && mv installation_tv_select-master box && rm box.zip && cd box

bash install.sh
