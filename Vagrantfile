block_storage_disk_m1 = './block_storage_disk_m1.vdi'
block_storage_disk_n1 = './block_storage_disk_n1.vdi'
block_storage_disk_n2 = './block_storage_disk_n2.vdi'
Vagrant.configure("2") do |config|
  config.vm.provision "shell", inline: "echo Hello"
  config.vm.define "m1", primary: true do |m1|
    m1.vm.provider "virtualbox" do |v|
      v.memory = 8192
      v.cpus = 2
      v.customize [ "modifyvm", :id, "--nicpromisc2", "allow-vms"]
      v.customize [ "modifyvm", :id, "--nicpromisc3", "allow-vms"]
    end
    m1.vm.box = "bento/ubuntu-20.04"
    m1.vm.hostname = "master"
    m1.vm.network "private_network", ip: "192.168.4.11", hostname: true, name: "vboxnet0"
    m1.vm.network "private_network", ip: "192.168.8.11", name: "vboxnet1"
    m1.vm.provider "virtualbox" do |v|
      unless File.exist?(block_storage_disk_m1)
        v.customize ['createhd', '--filename', block_storage_disk_m1, '--size', 50 * 1024]
      end
      v.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', block_storage_disk_m1]
    end
    m1.vm.provision "shell",
      run: "always",
      inline: "ip -6 addr add fc00:1:1:1::11/64 dev eth1"
    m1.vm.provision "shell", path: "./m1.sh"
  end

  config.vm.define "n1" do |n1|
    n1.vm.provider "virtualbox" do |v|
      v.memory = 8192
      v.cpus = 2
      v.customize [ "modifyvm", :id, "--nicpromisc2", "allow-vms"]
      v.customize [ "modifyvm", :id, "--nicpromisc3", "allow-vms"]
    end
    n1.vm.box = "bento/ubuntu-20.04"
    n1.vm.hostname = "node1"
    n1.vm.network "private_network", ip: "192.168.4.21", hostname: true, name: "vboxnet0"
    n1.vm.network "private_network", ip: "192.168.8.21", name: "vboxnet1"
    n1.vm.provider "virtualbox" do |v|
      unless File.exist?(block_storage_disk_n1)
        v.customize ['createhd', '--filename', block_storage_disk_n1, '--size', 50 * 1024]
      end
      v.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', block_storage_disk_n1]
    end
    n1.vm.provision "shell",
      run: "always",
      inline: "ip -6 addr add fc00:1:1:1::21/64 dev eth1"
    n1.vm.provision "shell", path: "./n1.sh"
  end

  config.vm.define "n2" do |n2|
    n2.vm.provider "virtualbox" do |v|
      v.memory = 8192
      v.cpus = 2
      v.customize [ "modifyvm", :id, "--nicpromisc2", "allow-vms"]
      v.customize [ "modifyvm", :id, "--nicpromisc3", "allow-vms"]
    end
    n2.vm.box = "bento/ubuntu-20.04"
    n2.vm.hostname = "node2"
    n2.vm.network "private_network", ip: "192.168.4.22", hostname: true, name: "vboxnet0"
    n2.vm.network "private_network", ip: "192.168.8.22", name: "vboxnet1"    
    n2.vm.provider "virtualbox" do |v|
      unless File.exist?(block_storage_disk_n2)
        v.customize ['createhd', '--filename', block_storage_disk_n2, '--size', 50 * 1024]
      end
      v.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', block_storage_disk_n2]
    end
    n2.vm.provision "shell",
      run: "always",
      inline: "ip -6 addr add fc00:1:1:1::22/64 dev eth1"
    n2.vm.provision "shell", path: "./n2.sh"
  end

  config.vm.define "vyos", primary: true do |vyos|
    vyos.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 2
      v.customize [ "modifyvm", :id, "--nicpromisc2", "allow-vms"]
      v.customize [ "modifyvm", :id, "--nicpromisc3", "allow-vms"]
    end
    #vyos.vm.box = "vyos/current"
    vyos.vm.box = "higebu/vyos"
    vyos.vm.hostname = "vyos"
    vyos.vm.network "private_network", ip: "192.168.4.2", hostname: true, name: "vboxnet0"
    vyos.vm.network "private_network", ip: "192.168.8.2", name: "vboxnet1"
    #vyos.vm.provision "shell", path: "./vyos.sh"
  end

end

