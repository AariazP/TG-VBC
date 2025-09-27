#!/bin/bash

# Show banner
cat banner.txt

# Menu options
options=("subir archivo" "limpiar cluster" "backup" "crear vm" "ssh" "scaling")

echo -e "Seleccione una opción:\n"
for i in "${!options[@]}"; do
    echo " $((i+1)): ${options[$i]}"
done

echo -ne "\nIngrese el número de su elección: "
read choice

# Validate input
if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#options[@]} )); then
    selected=${options[$((choice-1))]}
    echo -e "\nHas seleccionado: $choice -> $selected"
else
    echo -e "\nOpción inválida."
    exit 1
fi

