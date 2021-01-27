sudo su -
bash -c 'cat <<EOF> sysctladd.conf
net.ipv6.conf.eth1.accept_dad = 0
net.ipv6.conf.default.accept_dad = 0
net.ipv6.conf.eth1.dad_transmits = 0
net.ipv6.conf.default.dad_transmits = 0
EOF'
sudo cat sysctladd.conf >> /etc/sysctl.conf
sysctl -p
exit

configure
set protocols bgp 64567 parameters router-id 192.168.4.2
set protocols bgp 64567 neighbor 192.168.4.11 remote-as '64512'
set protocols bgp 64567 neighbor 192.168.4.21 remote-as '64512'
set protocols bgp 64567 neighbor 192.168.4.22 remote-as '64512'
commit
save
exit

configure
set interfaces ethernet eth1 address fc00:1:1:1::2/64
set interfaces ethernet eth1 address 192.168.4.2/24
set protocols bgp 64567 address-family ipv6-unicast network fc00:1:1:1::/64
set protocols bgp 64567 neighbor fc00:1:1:1::11 remote-as '64512'
set protocols bgp 64567 neighbor fc00:1:1:1::21 remote-as '64512'
set protocols bgp 64567 neighbor fc00:1:1:1::22 remote-as '64512'
set protocols bgp 64567 neighbor fc00:1:1:1::11 update-source fc00:1:1:1::2
set protocols bgp 64567 neighbor fc00:1:1:1::21 update-source fc00:1:1:1::2
set protocols bgp 64567 neighbor fc00:1:1:1::22 update-source fc00:1:1:1::2
set protocols bgp 64567 neighbor fc00:1:1:1::11 address-family ipv6-unicast
set protocols bgp 64567 neighbor fc00:1:1:1::21 address-family ipv6-unicast
set protocols bgp 64567 neighbor fc00:1:1:1::22 address-family ipv6-unicast
commit
save
exit
