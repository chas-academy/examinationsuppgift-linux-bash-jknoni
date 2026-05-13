#!/bin/bash
# script som skapar användare, deras hemkataloger och en välkomstfil

# kontrollerar om skriptet körs som root 
if [ "$EUID" -ne 0 ]; then
    echo "Tyvärr, du är inte root"
    exit 1 # avslutar skriptet med en felkod
fi

#--#--#--#--#--#--# skapa användare #--#--#--#--#--#

# loopar igenom alla argument
for user in "$@"; do

    # kontrollerar om användaren redan finns
    if id "$user" &>/dev/null; then
        echo "Användaren '$user' finns redan"
        continue # hoppar över till nästa användare
    fi

    # skapar användaren med en hemkatalog
    useradd -m "$user"
    echo "Skapar användare: $user"
done

#--#--#--#--#--# kataloger & välkomstfil #--#--#--#--#--#

# separat loop för att säkerställa att alla användare finns först
for user in "$@"; do

    # definierar sökvägen till hemkatalogen
    home_dir="/home/$user"

    # skapar katalogerna Documents, Downloads och Work
    mkdir -p "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"

    # sätter äganderätt & behörigheter
    chown -R "$user:$user" "$home_dir"

    # sätter restriktiva rättigheter
    chmod 700 "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"

    # skapar välkomstfi i hemkatalogen
    welcome_file="$home_dir/welcome.txt"
    # skriver välkomstmeddelande & skickar till välkomstfilen
    echo "Välkommen $user" > "$welcome_file"
    
    # hämtar alla användare från systemet & och skickar till välkomstfilen
    cut -d: -f1 /etc/passwd >> "$welcome_file"

    # sätter äganderätt för välkomstfilen
    chown "$user:$user" "$welcome_file"
done
