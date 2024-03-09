#!/bin/bash

# Memuat file konfigurasi
source config/config.sh

# Fungsi untuk membuka dan menutup extensi
buka_extensi_surfe() {
    sleep 2
    xdotool windowactivate $CHROMIUM_ID key alt+shift+s
}

# Fungsi untuk membaca tampilan pada koordinat tertentu
baca_tampilan() {
    local koordinat=$1
    local sumber_gambar=$(mktemp)

    trap "rm $sumber_gambar*" EXIT
    scrot -a $koordinat -q 100 $sumber_gambar.png
    mogrify -modulate 100,0 -resize 400% $sumber_gambar.png
    tesseract $sumber_gambar.png $sumber_gambar &> /dev/null
    local hasil=$(cat $sumber_gambar.txt | tr '[:upper:]' '[:lower:]')

    echo "$hasil"
}

# Fungsi untuk mengerjalan tugas berselancar
kerjalan_tugas_berselancar() {
    local target1="visit complete"
    local target2="video viewing is complete"
    local target3="captcha failed"
    local regex=".*\b\s*(${target1}|${target2}|${target3})\s*\b.*"
    local hasil=""

    echo "Kerjakan tugas ....."

    # Klik tugas surfe
    xdotool mousemove --sync $KOORDINAT_TOMBOL_TUGAS click --delay 100 1

    while true; do
        hasil=$(baca_tampilan "$SCROT_KOORDINAT_KONFIRMASI,$SCROT_DIMENSI_KONFIRMASI")
        echo $hasil

        if [[ $hasil =~ $regex ]]; then
            break
        fi
        sleep 5  # Tunggu 5 detik sebelum membaca lagi
    done

    # Tutup tab tugas
    xdotool mousemove --sync $KOORDINAT_TUTUP_TAB click --delay 100 1
}

kerjalan_tugas_captcha() {
    local regex=".*\b\s*this window can be closed\s*\b.*"

    # Klik tugas surfe
    xdotool mousemove --sync $KOORDINAT_TOMBOL_CAPTCHA click --delay 100 1

    echo "Kerjakan captcha ....."

    while true; do
        hasil=$(baca_tampilan "$SCROT_KOORDINAT_CAPTCHA,$SCROT_DIMENSI_CAPTCHA")
        echo $hasil

        if [[ $hasil =~ $regex ]]; then
            break
        fi
        sleep 5  # Tunggu 5 detik sebelum membaca lagi
    done

    # Tutup tab tugas
    xdotool mousemove --sync $KOORDINAT_TUTUP_TAB click --delay 100 1
}


# Fungsi untuk memeriksa ketersediaan tugas
cek_ketersediaan_tugas() {

    local hasil=$(baca_tampilan "$SCROT_KOORDINAT_TUGAS,$SCROT_DIMENSI_TUGAS")

    local target1="start"
    local target2="watch video"
    local regex_tugas=".*\b\s*(${target1}|${target2})\s*\b.*"
 
    local regex_captcha=".*\b\s*solve captcha\s*\b.*"

    if [[ "$hasil" =~ $regex_tugas ]]; then
        return 1
    elif [[ "$hasil" =~ $regex_captcha ]]; then
        return 2
    else
        return 3
    fi
}

cek_ketersediaan_tugas

# Function untuk menjalankan tugas
jalankan_tugas() {

    while true; do
     
        # Buka extensi surfe.be
        buka_extensi_surfe
        sleep 3

        
        cek_ketersediaan_tugas
        case $? in
            1)
                # Kerjakan tugas surfe
                echo "Kerjakan tugas surfe"
                kerjalan_tugas_berselancar
                ;;
            2)
                # Kerjakan tugas captcha
                echo "Captcha tersedia"
                kerjalan_tugas_captcha
                ;;
            *)
                echo "Tugas tidak tersedia"
                sleep $INTERVAL_TIDUR
                buka_extensi_surfe
                ;;
        esac
    done
}


# Jalankan fungsi utama
jalankan_tugas