vboxmanage hostonlyif create
vboxmanage hostonlyif create
vboxmanage hostonlyif ipconfig "vboxnet0" --ip 192.168.4.1 --netmask 255.255.255.0 
vboxmanage hostonlyif ipconfig "vboxnet1" --ip 192.168.8.1 --netmask 255.255.255.0 
vboxmanage hostonlyif ipconfig "vboxnet0" --ipv6 fc00:1:1:1::1
##ipconfig <name> [--dhcp | --ip<ipv4> [--netmask<ipv4> (def: 255.255.255.0)] | --ipv6<ipv6> [--netmasklengthv6<length> (def: 64)]] create | remove <name>
