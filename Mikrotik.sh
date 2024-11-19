# Buat VLAN 10 dan 20 pada interface ether1
/interface vlan
add name=vlan10 vlan-id=10 interface=ether1
add name=vlan20 vlan-id=20 interface=ether1

# Assign IP address ke VLAN
/ip address
add address=192.168.3.1/24 interface=vlan10
add address=192.168.20.1/24 interface=vlan20

# Konfigurasi DHCP Server untuk VLAN 10
/ip pool
add name=dhcp_pool_vlan10 ranges=192.168.3.10-192.168.3.100
/ip dhcp-server
add name=dhcp_vlan10 interface=vlan10 address-pool=dhcp_pool_vlan10
/ip dhcp-server network
add address=192.168.3.0/24 gateway=192.168.3.1 dns-server=8.8.8.8,8.8.4.4

# Konfigurasi DHCP Server untuk VLAN 20
/ip pool
add name=dhcp_pool_vlan20 ranges=192.168.20.10-192.168.20.100
/ip dhcp-server
add name=dhcp_vlan20 interface=vlan20 address-pool=dhcp_pool_vlan20
/ip dhcp-server network
add address=192.168.20.0/24 gateway=192.168.20.1 dns-server=8.8.8.8,8.8.4.4

# Aktifkan IP forwarding
/ip settings set forward=yes

# Konfigurasi NAT
/ip firewall nat
add chain=srcnat out-interface=ether1 action=masquerade

# Simpan konfigurasi
/system backup save name=backup

# Selesai
:log info "Konfigurasi VLAN dan DHCP selesai."
