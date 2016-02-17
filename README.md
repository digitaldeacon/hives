# Hives
Manage serveral memberhive instances

# Requirements
 + ruby >= 2.1.3
 + docker >= 1.7.0
 + git

Currently the only supported host manager is plesk. We use plesk to create subdomains and the configurations of the hosts.
In the future we will support at least spinning up digitalocean instances and configuring them.

# Tools
show console output
```docker attach mh-server-$NAME```

get a shell on the instance
```docker exec -it mh-server-$NAME bash```

# Install
```bash
git clone https://github.com/digitaldeacon/hives.git
sh install.sh # creates folders and stuff
sudo ruby root_create.rb
```