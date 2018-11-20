Vagrant.configure(2) do |config|
  config.ssh.forward_agent = true

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

  PROJECT_NAME ||= File.basename(File.expand_path("..", Dir.pwd))

  user_config = {
    "hostname" => PROJECT_NAME + ".local",
    "hostname_aliases" => [],
    "boxes" => {
      "virtualbox" => "bento/ubuntu-16.04",
      "parallels" => "parallels/ubuntu-16.04",
      "hyperv" => "bento/ubuntu-16.04",
    },
    "galaxy_role_file" => "requirements.yml",
    "cpus" => cpus,
    "mem" => mem,
    "max_mem" => false,
    "linked_clone" => true,
    "sync" => {
      "type" => "rsync",
      "exclude" => [
        ".vagrant/",
        ".git/",
        "vendor/*",
        "var/*",
        "app/logs/*",
        "app/cache/*",
        "app/bootstrap*",
        "web/uploads/*",
        "web/bundles/*",
        "public/uploads/*",
        "public/bundles/*",
        "bower_components/",
        "node_modules/"
      ]
    },
    "project_path" => "/app",
    "extra_vars" => {},
    "github" => {
      "oauth_token" => ""
    }
  }

  if Vagrant.has_plugin?("nugrant")
    config.user.defaults = {'pagrant' => user_config}
    user_config = config.user.pagrant
  end

  # Include additional params
  user_config["extra_vars"]["project_path"] = user_config["project_path"]
  user_config["extra_vars"]["composer_github_oauth"] = user_config["github"]["oauth_token"]

  config.vm.network "private_network", type: "dhcp"
  config.vm.define "dev", primary: true do |node|
    node.vm.hostname = user_config["hostname"]
    node.vm.synced_folder ".", "/vagrant", type: user_config["sync"]["type"]
    node.vm.synced_folder "..", user_config["extra_vars"]["project_path"], type: user_config["sync"]["type"],
      rsync__exclude: user_config["sync"]["exclude"]

    node.vm.provider "virtualbox" do |vm, override|
      override.vm.box = user_config["boxes"]["virtualbox"]
      vm.name = node.vm.hostname
      vm.cpus = user_config["cpus"]
      vm.memory = user_config["mem"]
      vm.linked_clone = user_config["linked_clone"]
    end

    node.vm.provider "parallels" do |vm, override|
      override.vm.box = user_config["boxes"]["parallels"]
      vm.name = node.vm.hostname
      vm.cpus = user_config["cpus"]
      vm.memory = user_config["mem"]
      vm.customize ["set", :id, "--time-sync", "on"]
    end

    node.vm.provider "hyperv" do |vm, override|
      override.vm.box = user_config["boxes"]["hyperv"]
      vm.vmname = node.vm.hostname
      vm.cpus = user_config["cpus"]
      vm.memory = user_config["mem"]
      vm.maxmemory = user_config["max_mem"]
      vm.linked_clone = user_config["linked_clone"]
    end

    config.vm.provision 'Stop unattended-upgrades', type: 'shell',
        path: './ansible/apt-kill.sh'

    node.vm.provision "ansible_local" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.provisioning_path = "/vagrant/ansible"
      ansible.galaxy_role_file = user_config["galaxy_role_file"]
      ansible.playbook = "setup.yml"
      ansible.extra_vars = user_config["extra_vars"]
    end

    if Vagrant.has_plugin?("HostManager")
        node.vm.post_up_message = "Project URL: http://" + user_config["hostname"] + "/"
        node.hostmanager.aliases = user_config["hostname_aliases"]
    end
  end
end
