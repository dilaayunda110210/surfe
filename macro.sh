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

    local website_block="neoinf.online|3lakk.online|naughtyfriendgirl.blogspot.com"

    local target1="visit complete"
    local target2="video viewing is complete"
    local target3="captcha failed"
    local target4="connection error. retry"
    local target5="you earned"
    
    local target6="this site can’t be reached"
    local target7="this site can’t provide a secure connection"
    local target8="page can’t be found"
    
    local target9="open xdg-open?"
    
    local target10="video is loading"
    local target11="rumble.com"
    local target12="google.com"
    local target13="select all"
    
    local target14="stay on this site"
    local target15="watching this video for"

    local target16="youtube.com"
    local target17="oops! =0"

    local target18="video paused"
    local target19="surfe.be/vi"

    local hasil=""

    echo "Kerjakan tugas ....."

    # Klik tugas surfe
    xdotool mousemove --sync $KOORDINAT_TOMBOL_TUGAS1 click --delay 100 1
    xdotool mousemove --sync $KOORDINAT_TOMBOL_TUGAS2 click --delay 100 1

    local index=0
    while true; do

        hasil=$(baca_tampilan "$SCROT_KOORDINAT_KONFIRMASI,$SCROT_DIMENSI_KONFIRMASI")
        # echo $hasil
        if [[ $hasil =~ $website_block ]]; then
            kerjakan_umpan_balik 4
            break
        elif [[ $hasil =~ $target1|$target2|$target3|$target4|$target5 ]]; then
            break
        elif [[ $hasil =~ $target6|$target7|$target8 ]]; then
            kerjakan_umpan_balik 4
            break
        elif [[ $hasil =~ $target9 ]]; then
            xdotool key "Return"
            continue
        # cek kondisi jika video rumble bermasalah
        elif [[ $hasil =~ $target11.*$target10 ]]; then
            index=$((index + 1))
            if [ $index -gt 5 ]; then
                kerjakan_umpan_balik 1
                break
            fi 
            continue
        # video pause
        elif [[ $hasil =~ $target11.*$target18 ]] || [[ $hasil =~ $target19 ]]; then
            index=$((index + 1))
            if [ $index -le 1 ]; then
                sleep 3 
                xdotool mousemove 272 286 click 1
                sleep 5
            fi     
            continue
        elif [[ $hasil =~ $target16.*$target17 ]]; then
            index=$((index + 1))
            if [ $index -gt 8 ]; then
                kerjakan_umpan_balik 1
                break
            fi 
            continue
        # cek kondisi jika captcha youtube bermasalah
        elif [[ ($hasil =~ $target12.*$target10) && !($hasil =~ $target13) ]]; then
            index=$((index + 1))
            if [ $index -gt 5 ]; then
                kerjakan_hapus_history
                break
            fi 
            continue
        fi

        sleep 5  # Tunggu 5 detik sebelum membaca lagi
    done

    # Tutup tab tugas
    xdotool mousemove --sync $KOORDINAT_TUTUP_TAB click --delay 100 1
}

# Fungsi untuk  mengerjakan tugas hapus history
kerjakan_hapus_history() {
    xdotool mousemove --sync $KOORDINAT_HISTORY click --delay 100 1
    sleep 3
    xdotool key "Tab"
    sleep 3 
    xdotool key "Return"
    sleep 6 
}

# Fungsi untuk  mengerjakan tugas umpan balik
kerjakan_umpan_balik() {
    xdotool mousemove --sync $KOORDINAT_TUTUP_TAB click --delay 100 1

    # Buka extensi surfe.be
    buka_extensi_surfe
    sleep 3

    # Klik tombol dislake
    xdotool mousemove --sync $KOORDINAT_TOMBOL_DISLAKE click --delay 100 1
    sleep 4

    case $1 in
        1)
            xdotool mousemove --sync $KOORDINAT_UPAN_BALIK1 click --delay 100 1
            ;;
        2)
            xdotool mousemove --sync $KOORDINAT_UPAN_BALIK2 click --delay 100 1
            ;;
        3)
            xdotool mousemove --sync $KOORDINAT_UPAN_BALIK3 click --delay 100 1
            ;;
        4)
            xdotool mousemove --sync $KOORDINAT_UPAN_BALIK4 click --delay 100 1
            ;;
        5)
            xdotool mousemove --sync $KOORDINAT_UPAN_BALIK5 click --delay 100 1
            ;;
        *)
            xdotool mousemove --sync $KOORDINAT_UPAN_BALIK1 click --delay 100 1
            ;;
    esac

    sleep 3
    xdotool key --delay 100 "Return"
    sleep 3
}

# Fungsi untuk memeriksa mengerjakan tugas captcha
kerjalan_tugas_captcha() {
    local regex=".*\b\s*this window can be closed\s*\b.*"

    # Klik tugas surfe
    xdotool mousemove --sync $KOORDINAT_TOMBOL_CAPTCHA click --delay 100 1

    echo "Kerjakan captcha ....."

    while true; do
        hasil=$(baca_tampilan "$SCROT_KOORDINAT_CAPTCHA,$SCROT_DIMENSI_CAPTCHA")

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
