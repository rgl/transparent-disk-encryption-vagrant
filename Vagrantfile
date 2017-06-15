Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu-16.04-amd64'
  config.vm.provider :libvirt do |lv|
    lv.memory = 2*1024
    lv.cpus = 4
    lv.cpu_mode = 'host-passthrough'
    lv.nested = true
    lv.keymap = 'pt'
    lv.storage :file, :size => '30G'
  end
  config.vm.provider :virtualbox do |vb, override|
    vb.linked_clone = true
    vb.memory = 2*1024
    vb.cpus = 4
    storage_disk_filename = 'sdb.vmdk'
    override.trigger.before :up do
      unless File.exist? storage_disk_filename
        info "Creating the #{storage_disk_filename} virtual disk..."
        run "VBoxManage createhd --filename #{storage_disk_filename} --size #{30*1024}"
      end
    end
    vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', storage_disk_filename]
  end
  config.vm.network :private_network, ip: '10.0.0.2'
  config.vm.provision :shell, path: 'provision.sh'
end
