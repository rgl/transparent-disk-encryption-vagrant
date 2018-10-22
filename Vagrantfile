Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu-18.04-amd64'
  config.vm.provider :libvirt do |lv, config|
    lv.memory = 2*1024
    lv.cpus = 4
    lv.cpu_mode = 'host-passthrough'
    lv.nested = true
    lv.keymap = 'pt'
    lv.storage :file, :size => '30G'
    config.vm.synced_folder '.', '/vagrant', type: 'nfs'
  end
  config.vm.provider :virtualbox do |vb, config|
    vb.linked_clone = true
    vb.memory = 2*1024
    vb.cpus = 4
    storage_disk_filename = 'sdb.vmdk'
    config.trigger.before :up do |trigger|
      unless File.exist? storage_disk_filename
        trigger.info = "Creating the #{storage_disk_filename} virtual disk..."
        trigger.run = {inline: "VBoxManage createhd --filename #{storage_disk_filename} --size #{30*1024}"}
      end
    end
    vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', storage_disk_filename]
  end
  config.vm.network :private_network, ip: '10.0.0.2'
  config.vm.provision :shell, path: 'provision.sh'
end
