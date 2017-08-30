Vagrant.configure(2) do |config|
  if Vagrant.has_plugin?("HostManager")
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    # Custom resolver for hostmanager and DHCP
    config.hostmanager.ip_resolver = proc do |machine|
      machine.ssh_info[:host]
    end
  end

  host = RbConfig::CONFIG['host_os']
  # Give VM 1/4 system memory & access to all cpu cores on the host
  if host =~ /darwin/
    cpus = `sysctl -n hw.ncpu`.to_i / 2
    # sysctl returns Bytes and we need to convert to MB
    mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 4
  elsif host =~ /linux/
    cpus = `nproc`.to_i / 2
    mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 4
  else
    cpus = `wmic cpu get NumberOfCores`.split("\n")[2].to_i / 2
    mem = `wmic OS get TotalVisibleMemorySize`.split("\n")[2].to_i / 1024 / 4
	if (mem % 2 != 0)
	  mem = mem + 1
	end
  end

  user_config = {
    "cpus" => cpus,
    "mem" => mem,
    "max_mem" => false,
    "differencing_disk" => true,
    "sync" => {
      "type" => "rsync",
      "exclude" => [
        ".vagrant/",
        ".git/",
        "vendor/*",
        "app/logs/*",
        "var/logs/*",
        "app/cache/*",
        "var/cache/*",
        "app/bootstrap*",
        "web/uploads/*",
        "web/bundles/*",
        "bower_components/",
        "node_modules/*"
      ]
    },
    "github" => {
      "oauth_token" => ""
    }
  }

  if Vagrant.has_plugin?("nugrant")
    config.user.defaults = {'pagrant' => user_config}
    user_config = config.user.pagrant
  end

  config.vm.network "private_network", type: "dhcp"
  config.vm.define "dev", primary: true do |node|
    PROJECT_NAME = File.basename(File.expand_path("..", Dir.pwd))
    node.vm.hostname = PROJECT_NAME + ".dev"
    node.vm.synced_folder ".", "/vagrant", type: user_config["sync"]["type"]
    node.vm.synced_folder "..", "/app", type: user_config["sync"]["type"],
      rsync__exclude: user_config["sync"]["exclude"]

    node.vm.provider "virtualbox" do |vm, override|
      override.vm.box = "bento/ubuntu-16.04"
      vm.name = node.vm.hostname
      vm.cpus = user_config["cpus"]
      vm.memory = user_config["mem"]
    end

    node.vm.provider "parallels" do |vm, override|
      override.vm.box = "parallels/ubuntu-16.04"
      vm.name = node.vm.hostname
      vm.cpus = user_config["cpus"]
      vm.memory = user_config["mem"]
      vm.customize ["set", :id, "--time-sync", "on"]
    end

    node.vm.provider "hyperv" do |vm, override|
      override.vm.box = "kmm/ubuntu-xenial64"
      vm.vmname = node.vm.hostname
      vm.cpus = user_config["cpus"]
      vm.memory = user_config["mem"]
      vm.maxmemory = user_config["max_mem"]
      vm.differencing_disk = user_config["differencing_disk"]
    end

    config.vm.provision 'Stop unattended-upgrades', type: 'shell',
        path: './ansible/apt-kill.sh'

    node.vm.provision "ansible_local" do |ansible|
      ansible.provisioning_path = "/vagrant/ansible"
      ansible.galaxy_role_file = "requirements.yml"
      ansible.playbook = "setup.yml"
      ansible.extra_vars = {
        composer_github_oauth: user_config["github"]["oauth_token"]
      }
    end

    if Vagrant.has_plugin?("HostManager")
        node.vm.post_up_message = "Project URL: http://" + PROJECT_NAME + ".dev/app_dev.php"
    end
  end
end
