LEMP Vagrant configuration
==========================

- Nginx
- php-fpm
- MySQL (Percona)
- Elasticsearch
- Composer
- NPM
- Bower


## Installation

```bash
cd <path_to_project>
git submodule add https://github.com/dincho/pagrant.git vagrant
cd vagrant
vagrant up
```

## Configuration

Using [Nugrant](https://github.com/maoueh/nugrant) Vagrant plugin configuration may be specified per project and for the system

```bash
vagrant plugin install nugrant
```

### System-wide configuration

To provide configuration that is shared by all your projects create `<user_home_path>/.vagrantuser`. For different OS'es `<user_home_path>` varies.

E.g. for MacOS/OSx it is `~/.vagrantuser`, for Windows it should be `%USERPROFILE%\.vagrantuser` (something like `C:\Users\your_username\.vagrantuser`)

```yml
pagrant:
  github:
    oauth_token: your_github_token
  sync:
    type: parallels # defaults to 'rsync'
    exclude: # List replaces the defaults if provided. Defaults to the list below.
      - .vagrant/
      - .git/
      - vendor/*
      - app/logs/*
      - var/*
      - app/cache/*
      - app/bootstrap*
      - web/uploads/*
      - web/bundles/*
      - public/uploads/*
      - public/bundles/*
      - bower_components/
      - node_modules/*
```

### Per project configuration

Per project configuration can be set by creating `<path_to_project>/<pagrant_submodule>/.vagrantuser`.

E.g. To customize sync exclusions create `/cool_project/vagrant/.vagrantuser`:

```yml
pagrant:
  hostname: cool_project.local # defaults to <project_name>.local
  hostname_aliases:  # Additional domains to add to hosts. Defaults to []
    - project.local
    - project.test
    - subdomain.project.test
  project_path: /app # Absolute path of your project root. Default is '/app'
 # For a symfony flex app
  sync:
    exclude: # list replaces the system-wide config
      - .vagrant/
      - .git/
      - vendor/*
      - var/*
      - public/uploads/*
      - public/bundles/*
      - bower_components/
      - node_modules/*
  # ...
```

Note: <project_name> is the name of the directory that contains the <pagrant_submodule>. E.g. if the module is located in `/home/cool_project/vagrant/` then <project_name> will be "cool_project".

<project_path> is the absolute path on VM (guest) where your project files will reside and will be synced with your local (host) dir. It is best to leave it `/app`

### Per VM configuration

In addition you can tweak the VM config (hardware). Depending on the case configure in project's `.vagrantuser` or in the system wide '~/.vagrantuser'.

```yml
pagrant:
  cpus: 2 # defaults to host cores / 2
  mem: 1024 # defaults to host memory / 4
  max_mem: 2048 # hyper-v only, defaults to false = turn off dynamic memory
  linked_clone: false # hyper-v and virtualbox only, use of differencing disk, defaults to true
```

### Change the default box

You can override the default boxes used by vagrant in `.vagrantuser` under `boxes` section.
```yml
pagrant:
  boxes:
    virtualbox: 'bento/ubuntu-16.04'
    parallels: 'parallels/ubuntu-16.04'
    hyperv: 'kmm/ubuntu-xenial64'
```

### Override Ansible vars

Default configuration is optimal for common use but you are able to tweak the provisioning by passing certain vars that are used in Ansbile roles and tasks.
You can override the values you want by defining the `extra_vars` section in `.vagrantuser`.

E.g. for a Symfony flex project `/cool_project/vagrant/.vagrantuser`:

```yml
pagrant:
  extra_vars:
    php_fpm_version: '7.2' # Define the PHP version. Default is '7.1'.
    nodejs_version: '8.x' # Define the NodeJS major version. Default is '6.x'.
    nginx_sites_default_root: /app/public # Absolute path of the public dir. Default is '/app/web'.
```

Notes:

 * For the supported vars you need to check the official documentation of the ansible roles which are listed in `<pagrant_submodule>/ansible/requirements.yml`
 * Make sure `nginx_sites_default_root` points to a subdir of `project_path`
 * Avoid changing `extra_vars` after initial provisioning. Reprovision after changes might have unexpected results
 * Supported php versions and packages could be found here https://launchpad.net/~ondrej/+archive/ubuntu/php/+index?field.series_filter=xenial

**Warning: If you change `php_fpm_version` and reprovision with `vagrant reload --provision` you will end up with multiple php versions installed. Nginx will be reconfigured to use the updated `php_fpm_version`**

### Override package dependencies

The apt and npm packages listed below are required by pagrant (by dafault). This configuration allows you to add your own, if they are needed before other pagrant tasks are executed.

```yml
pagrant:
  extra_vars:
    apt_packages:
      pkg:
        - nodejs
        - git
        - make
        - unzip
    
    npm_packages:
      - bower
      - yarn
```

### Override Ansible roles

You can override the existing roles by creating your own requirements file and linking it via `galaxy_role_file` key in the config.
We suggest using the root directory of your project.

```yml
pagrant:
  galaxy_role_file: "/app/ansible_requirements_dev.yml", # Absolute path to custom requirements. Default is 'requirements.yml'.
```

Notes: 

 * The roles defined in [requirements.yml](https://github.com/dincho/pagrant/blob/master/ansible/requirements.yml) are mandatory. You can change their versions if needed.

## Suggestions

It is recommended to install [vagrant-hostmanager](https://github.com/devopsgroup-io/vagrant-hostmanager) plugin
to automatically update your hosts file. This way you can access your project by its hostname (e.g. cool_project.local)

```bash
vagrant plugin install vagrant-hostmanager
```

To force update of `hosts` file while machine is running use:

```bash
vagrant hostmanager
```

This also allows you to change `hostname` and `hostname_aliases` at any time without restart.

## Ansible tasks per project

You can include ansible tasks per project by creating `<path_to_project>/ansible_dev.yml` file which will be included in provisioning

E.g.:

```
-----
- name: Install additional libs
  apt: pkg={{ item }} state=installed
  with_items:
   - imagemagick
   - unzip
```
