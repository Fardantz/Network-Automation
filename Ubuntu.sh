#!/bin/bash

FARDANTZ AUTOMATION.

# Langkah 1: Pembaruan Repo (Kartolo)
echo "Memperbarui dan meningkatkan sistem..."
"deb http://kartolo.sby.datautama.net.id/ubuntu/ focal main restricted universe multiverse"
"deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-updates main restricted universe multiverse"
"deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-security main restricted universe multiverse"
"deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-backports main restricted universe multiverse"
"deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-proposed main restricted universe multiverse"
sudo apt update && sudo apt upgrade -y

# Langkah 2: Instalasi Paket-Paket Diperlukan
echo "Menginstal paket yang diperlukan..."
sudo apt install -y vlan isc-dhcp-server

# Langkah 3: Konfigurasi VLAN
echo "Mengkonfigurasi VLAN..."
sudo modprobe 8021q
echo "8021q" | sudo tee -a /etc/modules

# Buat interface untuk VLAN 10 pada eth1
sudo vconfig add eth1 10
sudo ip link set up eth1.10

# Konfigurasi IP address untuk VLAN 10
sudo tee /etc/netplan/01-netcfg.yaml << EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    eth1:
      dhcp4: no
  vlans:
    eth1.10:
      id: 10
      link: eth1
      addresses:
        - 192.168.3.1/24
EOF
sudo netplan apply

# Langkah 4: Konfigurasi DHCP Server
echo "Mengkonfigurasi DHCP server..."
sudo tee /etc/dhcp/dhcpd.conf << EOF
default-lease-time 600;
max-lease-time 7200;

subnet 192.168.3.0 netmask 255.255.255.0 {
  range 192.168.3.10 192.168.3.100;
  option routers 192.168.3.1;
  option subnet-mask 255.255.255.0;
  option domain-name-servers 8.8.8.8, 8.8.4.4; 
#  option domain-name "internal.example.org";
  option subnet-mask 255.255.255.0;
  option routers 192.168.3.1;
  option broadcast-address 192.168.3.255;
  default-lease-time 600;
  max-lease-time 7200;
}

subnet 192.168.20.0 netmask 255.255.255.0 { 
  range 192.168.20.10 192.168.20.100; 
  option routers 192.168.20.1; 
  option subnet-mask 255.255.255.0; 
  option domain-name-servers 8.8.8.8, 8.8.4.4;
#  option domain-name "internal.example.org";
  option subnet-mask 255.255.255.0;
  option routers 192.168.20.1;
  option broadcast-address 192.168.20.255;
  default-lease-time 600;
  max-lease-time 7200;
}
EOF

sudo tee /etc/default/isc-dhcp-server << EOF
INTERFACESv4="eth1.10"
EOF

sudo systemctl restart isc-dhcp-server

# Langkah 5: Konfigurasi Routing
echo "Mengkonfigurasi routing di Ubuntu Server..."
sudo tee /etc/sysctl.conf << EOF
net.ipv4.ip_forward=1
EOF
sudo sysctl -p

# Tambahkan aturan iptables untuk NAT
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables-save | sudo tee /etc/iptables/rules.v4

echo "Konfigurasi DHCP server dan VLAN di Ubuntu Server 20.04 telah selesai."

# Selesai
echo "Otomasi selesai. Silakan restart server untuk memastikan semua perubahan diterapkan."
