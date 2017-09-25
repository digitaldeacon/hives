# Hives
Manage serveral memberhive instances for either Version 1 or 2

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

get a root shell on the instace
``` docker exec -it -u root mh-server-$NAME bash```

## MHv1
install mongo on the docker server instance
`apt-get install mongodb`

connect to the mongo instance
`mongo mg-db-$NAME:27017/$NAME -u $NAME -p $PASSWORD`

Mongo Commands
 + show collections
 
 ##MHv2
 install mysql on the docker server instance
 

# Install
```bash
git clone https://github.com/digitaldeacon/hives.git
sh install.sh # creates folders and stuff
```
Modify the `config.json` to your new configuration
```json
{
  "sites" : {
    "ecg" : {
      "name": "Evangeliums Christen Gemeinde Berlin",
      "resources" : -1,
      "version": 1
    }
  }
}
```
then run `sudo ruby root_create.rb`

# Deploy

+ Push to git
+ Pull on webserver

# Commands

If you updated `config.json` to have a new site you have to run  `sudo ruby root_create.rb` to create this site as well.
But if you only want to update the exiting sites you have to run `ruby update.rb`.

To restart and recreate all the instances run `ruby restart.rb`. This also rebuild and updates the docker images.
