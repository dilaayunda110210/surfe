#!/bin/bash

config_file="config/config.sh"
img_source="scrot/screenshot.png"
txt_source="scrot/screenshot"

# Fungsi untuk mengedit nilai dalam file konfigurasi
edit_config() {
    local key="$1"
    local new_value="$2"
    sed -i "s/\($key=\).*/\1\"$new_value\"/" "$config_file"
}

# Fungsi untuk mengambil screenshot dan mengedit file konfigurasi
take_screenshot() {
    rm "$img_source" "$txt_source.txt"
    
    # Ambil tangkapan layar dengan scrot
    scrot -s "$img_source"
    
    # Dapatkan koordinat mouse menggunakan xdotool
    mouse_x=$(xdotool getmouselocation --shell | grep 'X' | cut -d '=' -f 2)
    mouse_y=$(xdotool getmouselocation --shell | grep 'Y' | cut -d '=' -f 2)
    
    # Dapatkan panjang dan lebar gambar
    image_width=$(identify -format "%w" "$img_source")
    image_height=$(identify -format "%h" "$img_source")
    
    # Pastikan nilai-nilai telah diinisialisasi
    if [ -z "$mouse_x" ] || [ -z "$mouse_y" ] || [ -z "$image_width" ] || [ -z "$image_height" ]; then
        echo "Gagal mendapatkan nilai dari tangkapan layar."
        exit 1
    fi
    
    # Dapatkan text dari gambar
    mogrify -modulate 100,0 -resize 400% "$img_source"
    tesseract "$img_source" "$txt_source" &> /dev/null
    hasil_txt=$(cat "$txt_source.txt")
    
    echo "Mouse Coordinate	: $mouse_x $mouse_y"
    echo "Image Dimensions	: $image_width, $image_height"
    echo "Text Images		: $hasil_txt"
}

# Cek argumen
case "$1" in
  "tugas")
    take_screenshot
    edit_config "SCROT_KOORDINAT_TUGAS" "$mouse_x,$mouse_y"
    edit_config "SCROT_DIMENSI_TUGAS" "$image_width,$image_height"
    ;;
  "konfirmasi")
    take_screenshot
    edit_config "SCROT_KOORDINAT_KONFIRMASI" "$mouse_x,$mouse_y"
    edit_config "SCROT_DIMENSI_KONFIRMASI" "$image_width,$image_height"
    ;;
  "captcha")
    take_screenshot
    edit_config "SCROT_KOORDINAT_CAPTCHA" "$mouse_x,$mouse_y"
    edit_config "SCROT_DIMENSI_CAPTCHA" "$image_width,$image_height"
    ;;
  *)
    echo "Argumen tidak valid. Gunakan: tugas, konfirmasi, atau captcha."
    exit 1
    ;;
esac
