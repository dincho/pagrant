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

## Suggestions

If [vagrant-hostmanager](https://github.com/devopsgroup-io/vagrant-hostmanager) plugin is installed 
you can access your project with your_project.dev hostname

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
