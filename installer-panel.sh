#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_root() {
    if [[ $EUID -ne 0 ]]; then
       echo -e "${RED}Error: Skrip ini harus dijalankan sebagai root.${NC}"
       echo -e "Silakan coba lagi dengan 'sudo bash $0'"
       exit 1
    fi
}

show_menu() {
    clear
    echo -e "====================================================="
    echo -e "         ${GREEN}Pterodactyl All-in-One Manager${NC}"
    echo -e "====================================================="
    echo -e "Pilih salah satu opsi di bawah ini:"
    echo ""
    echo -e "  ${YELLOW}1)${NC} Install Panel Pterodactyl"
    echo -e "  ${YELLOW}2)${NC} Install Wings (Node Daemon)"
    echo -e "  ${YELLOW}3)${NC} ${RED}Panduan Uninstall Panel & Wings (Manual)${NC}"
    echo -e "  ${YELLOW}4)${NC} Keluar"
    echo ""
    echo -e "-----------------------------------------------------"
}

install_panel() {
    echo -e "${GREEN}Memulai instalasi Panel Pterodactyl...${NC}"
    echo -e "Skrip instalasi resmi akan dijalankan."
    echo -e "${YELLOW}PENTING: Nantinya, skrip instalasi akan meminta Anda untuk memilih sistem operasi (seperti Ubuntu atau Debian). Pastikan Anda memilih yang sesuai.${NC}"
    echo -e "Pastikan Anda menjalankan ini di server yang bersih."
    read -p "Tekan [Enter] untuk melanjutkan atau [Ctrl+C] untuk membatalkan."
    bash <(curl -s https://pterodactyl-installer.se)
    echo -e "${GREEN}Instalasi Panel telah selesai dijalankan.${NC}"
}

install_wings() {
    echo -e "${GREEN}Memulai instalasi Wings...${NC}"
    echo -e "Skrip instalasi resmi akan dijalankan."
    echo -e "${YELLOW}PENTING: Nantinya, skrip instalasi akan meminta Anda untuk memilih sistem operasi (seperti Ubuntu atau Debian). Pastikan Anda memilih yang sesuai.${NC}"
    echo -e "Pastikan Docker sudah siap di server node ini."
    read -p "Tekan [Enter] untuk melanjutkan atau [Ctrl+C] untuk membatalkan."
    bash <(curl -s https://pterodactyl-installer.se/wings)
    echo -e "${GREEN}Instalasi Wings telah selesai dijalankan.${NC}"
    echo -e "Jangan lupa untuk mengkonfigurasi file '/etc/pterodactyl/config.yml' dari Panel Anda."
}

uninstall_pterodactyl() {
    clear
    echo -e "${RED}=====================================================${NC}"
    echo -e "${RED}     PANDUAN UNINSTALL PTERODACTYL (MANUAL)${NC}"
    echo -e "${RED}=====================================================${NC}"
    echo -e "${YELLOW}PERINGATAN: Proses ini TIDAK OTOMATIS.${NC}"
    echo -e "Skrip ini hanya akan menampilkan perintah yang perlu Anda jalankan satu per satu."
    echo -e "Ini untuk mencegah penghapusan data yang tidak disengaja."
    echo -e "${RED}LAKUKAN BACKUP SEBELUM MELANJUTKAN!${NC}"
    read -p "Tekan [Enter] untuk melihat langkah-langkahnya."

    echo -e "\n--- ${YELLOW}Langkah 1: Hapus File Web Panel${NC} ---"
    echo "Perintah berikut akan menghapus direktori web Pterodactyl."
    echo -e "${RED}sudo rm -rf /var/w ww/pterodactyl${NC}"
    read -p "Tekan [Enter] untuk ke langkah berikutnya."

    echo -e "\n--- ${YELLOW}Langkah 2: Hapus Database${NC} ---"
    echo "Login ke MariaDB/MySQL Anda dengan 'sudo mysql -u root -p', lalu jalankan perintah SQL ini:"
    echo -e "${RED}DROP DATABASE panel;${NC}"
    echo -e "${RED}DROP USER 'pterodactyluser'@'127.0.0.1';${NC}"
    echo -e "${RED}FLUSH PRIVILEGES;${NC}"
    echo -e "${YELLOW}(Catatan: Ganti nama database/user jika Anda menggunakan nama yang berbeda)${NC}"
    read -p "Tekan [Enter] untuk ke langkah berikutnya."

    echo -e "\n--- ${YELLOW}Langkah 3: Hapus Konfigurasi Web Server${NC} ---"
    echo "Untuk Nginx:"
    echo -e "${RED}sudo rm /etc/nginx/sites-enabled/pterodactyl.conf${NC}"
    echo -e "${RED}sudo systemctl restart nginx${NC}"
    echo "Untuk Apache:"
    echo -e "${RED}sudo rm /etc/apache2/sites-enabled/pterodactyl.conf${NC}"
    echo -e "${RED}sudo systemctl restart apache2${NC}"
    read -p "Tekan [Enter] untuk ke langkah berikutnya."

    echo -e "\n--- ${YELLOW}Langkah 4: Hapus Service dan File Wings${NC} ---"
    echo "Hentikan, nonaktifkan, dan hapus service Wings:"
    echo -e "${RED}sudo systemctl stop wings${NC}"
    echo -e "${RED}sudo systemctl disable wings${NC}"
    echo -e "${RED}sudo rm /etc/systemd/system/wings.service${NC}"
    echo "Hapus direktori konfigurasi dan data Wings:"
    echo -e "${RED}sudo rm -rf /etc/pterodactyl/${NC}"
    echo -e "${RED}sudo rm -rf /var/lib/pterodactyl/${NC}"
    read -p "Tekan [Enter] untuk ke langkah berikutnya."

    echo -e "\n--- ${YELLOW}Langkah 5: Hapus Cronjob${NC} ---"
    echo "Buka editor crontab dengan perintah:"
    echo -e "${GREEN}sudo crontab -e${NC}"
    echo "Kemudian hapus baris yang berisi 'pterodactyl/artisan schedule:run'."
    
    echo -e "\n${GREEN}Panduan uninstall selesai.${NC}"
}

check_root
while true; do
    show_menu
    read -p "Pilih opsi [1-4]: " choice
    case $choice in
        1)
            install_panel
            ;;
        2)
            install_wings
            ;;
        3)
            uninstall_pterodactyl
            ;;
        4)
            echo "Keluar dari skrip."
            exit 0
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid. Silakan coba lagi.${NC}"
            ;;
    esac
    echo ""
    read -p "Tekan [Enter] untuk kembali ke menu utama..."
done
