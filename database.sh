# chmod +x database.sh
# ./database.sh

echo "|---- Komandinio failo aprašymas ir vartotojo instrukcija ----|"
echo ""
echo "Šis skriptas suteikia galimybę valdyti darbuotojų duomenų bazę tekstiniame faile."
echo "Galimos funkcijos:"
echo "1. Peržiūrėti darbuotojų sąrašą:"
echo "   - Pasirinkus šią parinktį, bus atspausdintas visas darbuotojų sąrašas iš 'list.txt' failo (pagal mažėjančią metų patirtį)."
echo "   - Bus išvestas bendras darbuotojų skaičius po sąrašu."
echo ""
echo "2. Peržiūrėti darbuotojų metų patirties statistiką:"
echo "   - Pasirinkus šią parinktį, bus pateikta statistika apie darbuotojų metų patirtį."
echo "   - Pamatysite vidutinę, mažiausią ir didžiausią metų patirtį."
echo "   - Jei darbuotojų nėra, bus parodytas pranešimas apie tai."
echo ""
echo "3. Ieškoti pagal techninį įgūdį arba dominančią sritį:"
echo "   - Pasirinkus šią parinktį, įvesite ieškomą techninį įgūdį arba sritį."
echo "   - Skriptas parodys darbuotojus, kurie atitinka paieškos kriterijus."
echo "   - Rezultatai bus rūšiuojami pagal metų patirtį (nuo didžiausios iki mažiausios)."
echo ""
echo "4. Pridėti naują darbuotoją:"
echo "   - Pasirinkus šią parinktį, įvesite naujo darbuotojo duomenis, tokius kaip vardas, pavardė, el. paštas, techniniai įgūdžiai, metų patirtis ir dominančios sritys."
echo "   - Įrašas bus pridedamas į 'list.txt' failą ir sąrašas bus atnaujintas."
echo ""
echo "5. Ištrinti darbuotoją:"
echo "   - Pasirinkus šią parinktį, įvesite darbuotojo vardą ir pavardę, kad jį ištrintumėte."
echo "   - Jeigu darbuotojas buvo rastas, jis bus pašalintas iš 'list.txt' failo."
echo ""
echo "6. Baigti darbą:"
echo "   - Pasirinkus šią parinktį, programa baigs darbą."
echo ""


FILE="list.txt"

PS3="Pasirinkite [1-6]: "
while true; do
echo "|---- Darbuotojų duomenų bazė ----|"
select item in "Peržiūrėti darbuotojų sąrašą" "Peržiūrėti darbuotojų metų patirties statistiką" "Ieškoti pagal techninį įgūdį arba dominančią sritį" "Pridėti naują darbuotoją" "Ištrinti darbuotoją" "Baigti darbą"
  do
    case $REPLY in
        1) 
            echo ""
            echo "Darbuotojų sąrašas:"
            awk 'NR <= 2 {print $0}' "$FILE"
            awk 'NR > 2 {print $0}' "$FILE" | sort -rnk 5
            awk 'NR > 2 {count++} END {print "Darbuotojų skaičius: " count}' "$FILE"
            echo ""
            break
            ;;
        2) 
           echo ""
           echo "Darbuotojų metų patirties statistika:"
           awk 'NR > 2 {sum += $5; if (min == "" || $5 < min) min = $5; if (max == "" || $5 > max) max = $5; count++} 
            END {
                if (count > 0) {
                    print "Vidutinė patirtis:", sum / count;
                    print "Mažiausia patirtis:", min;
                    print "Didžiausia patirtis:", max;
                } else {
                    print "Darbuotojų nėra.";
                }
            }' "$FILE"
            echo ""
            break
            ;;
        3)
            echo ""
            echo -n "Įveskite techninį įgūdį arba dominančią sritį: "
            read search_term
            echo "Rezultatai \"$search_term\":"
            awk -v term="$search_term" '
                NR > 2 && (tolower($4) ~ tolower(term) || tolower($6) ~ tolower(term)) {
                    printf "%s;%s;%s;%s;%s\n", $1 " " $2, $3, $5, $4, $6
                }
            ' "$FILE" | sort -t ';' -k3,3nr | awk -F';' '
                BEGIN {
                    printf "%-20s %-25s %-20s %-15s\n", "Name", "Contact", "YearsOfExperience", "TechnicalSkills"
                    print "----------------------------------------------------------------------------------------------------"
                }
                {
                    printf "%-20s %-25s %-20s %-15s\n", $1, $2, $3, $4
                }
            '
            echo ""
            break
            ;;
        4)  
            echo ""
            echo -n "Įveskite vardą: "
            read name
            echo -n "Įveskite pavardę: "
            read lastname
            echo -n "Įveskite elektroninį pašto adresą: "
            read contact
            echo -n "Įveskite techninius įgūdžius (be tarpų, kableliu atskirti): "
            read skills
            echo -n "Įveskite metų patirtį: "
            read experience
            echo -n "Įveskite dominančias sritis (be tarpų, kableliu atskirti): "
            read interest
            printf "%-9s %-13s %-27s %-49s %-8s %-50s\n" "$name" "$lastname" "$contact" "$skills" "$experience" "$interest" >> "$FILE"
            echo "Darbuotojas sėkmingai pridėtas!"
            awk 'END {print "Vardas:", $1, "\nPavardė:", $2, "\nEl. paštas:", $3, "\nTechniniai įgūdžiai:", $4, "\nMetų patirtis:", $5, "\nDominančios sritys:", $6}' "$FILE"
            echo ""
            break
            ;;
        5)
            echo ""
            echo -n "Įveskite darbuotojo vardą, kurį norite ištrinti: "
            read name
            echo -n "Įveskite darbuotojo pavardę, kurį norite ištrinti: "
            read lastname
            awk -v name="$name" -v lastname="$lastname" '!($1 == name && $2 == lastname)' "$FILE" > temp.txt && mv temp.txt "$FILE"
            echo "Jei darbuotojas egzistavo, jis buvo ištrintas."
            echo ""
            break
            ;;
        6)
            echo "Darbo pabaiga."
            break 2
            ;;
        *)
            echo "Netinkamas pasirinkimas."
            ;;
    esac
done
done