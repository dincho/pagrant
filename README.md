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
git submodule add git@github.com:dincho/pagrant.git vagrant
cd vagrant
vagrant up
```

## Configuration

Using [Nugrant](https://github.com/maoueh/nugrant) Vagrant plugin configuration may be specified per project and per user

```bash
vagrant plugin install nugrant
```

Create `~/.vagrantuser` for user wide configuration, e.g:

```yml
pagrant:
  hostname: cool_project.local # defaults to <project_name>.local
  cpus: 2 # defaults to host cores / 2
  mem: 1024 # defaults to host memory / 4
  max_mem: 2048 # hyper-v only, defaults to false = turn off dynamic memory
  differencing_disk: false # hyper-v only, defaults to true
  github:
    oauth_token: your_github_token
  sync:
    type: parallels #defaults to rsync
    exclude: # defaults to the list below
      - .vagrant/
      - .git/
      - vendor/*
      - app/logs/*
      - var/logs/*
      - app/cache/*
      - var/cache/*
      - app/bootstrap*
      - web/uploads/*
      - web/bundles/*
      - bower_components/
      - node_modules/*
```

Note: <project_name> is the name of the directory that contains the pagrant_submodule.
E.g. if the module is located in `/home/cool_project/vagrant/` then <project_name> will be "cool_project"

### Per project configuration

Per project configuration can be set by creating `<path_to_project>/<pagrant_submodule>/.vagrantuser`.

E.g. `/cool_project/vagrant/.vagrantuser`:

```yml
pagrant:
  sync:
    exclude:
      - .vagrant/
      - .git/
      - vendor/*
      - app/logs/*
      - var/logs/*
      - app/cache/*
      - var/cache/*
      - app/bootstrap*
      - web/uploads/*
      - web/bundles/*
      - bower_components/
      - node_modules/*
```

### Override Ansible vars

Default configuration is optimal for common use but you are able to tweak the provisioning by passing certain vars that are used in Ansbile roles and tasks.
You can override the values you want by defining the `extra_vars` section in `.vagrantuser`.

E.g. `/cool_project/vagrant/.vagrantuser`:

```yml
pagrant:
  extra_vars:
    php_fpm_version: '7.2' # Change the PHP version. Default is '7.1'. Supported are 5.6, 7.0, 7.1, 7.2
```

Note: For the supported vars you need to check the official documentation of the ansible roles which are listed in `<pagrant_submodule>/ansible/requirements.yml`

## Suggestions

It is recommended to install [vagrant-hostmanager](https://github.com/devopsgroup-io/vagrant-hostmanager) plugin
to automatically update your hosts file. This way you can access your project by its hostname (e.g. cool_project.local)

```bash
vagrant plugin install vagrant-hostmanager
```


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
