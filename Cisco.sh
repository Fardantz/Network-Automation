conf t

# Membuat VLAN 10 dan VLAN 20
vlan 10
 name VLAN10
vlan 20
 name VLAN20

# Mengkonfigurasi interface trunk
interface GigabitEthernet0/1
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 10,20
 description Trunk to Router

# Mengkonfigurasi interface akses VLAN 10
interface GigabitEthernet0/2
 switchport mode access
 switchport access vlan 10
 description To Server or PC in VLAN 10

# Mengkonfigurasi interface akses VLAN 20
interface GigabitEthernet0/3
 switchport mode access
 switchport access vlan 20
 description To Server or PC in VLAN 20

# Menyimpan konfigurasi
end
wr mem
