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
cd /path/to/your/project
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
  min_mem: 1024 # hyper-v only, default mem = min_mem to turn off dynamic memory
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

Per project configuration should be set by creating `/<<path_to_project>>/vagrant/.vagrantuser`.

E.g.:

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
