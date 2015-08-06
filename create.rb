require 'json'
require 'fileutils'
require_relative 'common'

def create_site(name)
  puts "creating site #{name}".blue
  if(not subdomain_exists? name)
    create_subdomain_plesk(name)
  end
  deploy_port = $config_local.fetch('deploy_port', 8701)
  web_port = $config_local.fetch('web_port', 10000)
  docker_server_name = "mh-server-"+name
  docker_db_name = "mh-db-"+name
  # start docker with loopback
  create_db_docker(name, docker_db_name)
  create_server_docker(docker_server_name, deploy_port, web_port, docker_db_name)
  
  $config_local['deploy_port'] = deploy_port+1;
  $config_local['web_port'] = web_port+1;
  exe("sleep 2")
  
  if(not $config_local.has_key? 'sites')
    $config_local['sites'] = {}
  end
  
  $config_local['sites'][name] = 
      {
        "deploy_port" =>  deploy_port,
        "web_port" => web_port,
        "docker_server_name" => docker_server_name,
        "docker_db_name" => docker_db_name
      }
  
  update_server(name)
  
  write_local_config()
end
def create_slc_service(name)
  exe("slc ctl create #{name}")
  exe("slc ctl env-set #{name} NODE_ENV=production")
end

def create_db_docker(name, docker_db_name)
  puts "Create db server for #{name}".blue
  db = db_path(name)
  db_exists = true
  if not File.exists? db
    db_exists = false
    FileUtils.mkpath db
  end
  exe("docker run -d -v #{db}:/data/db --name #{docker_db_name} -d mongo")
  exe("sleep 10")
  if(not db_exists)
    puts "create db".blue
    exe("docker exec -it #{docker_db_name} 'mongo memberhive --eval \"db.addUser(\\\"memberhive\\\", \\\"memberhive\\\");\"'")
  end
end

def create_server_docker(name, deploy_port, web_port, db_name)
  puts "Create docker server for #{name}".blue
  exe("docker run -d -p #{deploy_port}:8701 -p #{web_port}:3001 --name #{name} --link #{db_name}:db mh-strong-pm")
end


def build_docker()
  puts "Building docker files".colorize(:blue)
  exe("cd docker/server && docker build -t mh-strong-pm .")
  #exe("docker pull mongo")

end


def subdomain_exists?(name)
  File.exists?(path_subdomain(name))
end

def main()
  puts "Begiining to boostrap environment".blue
  build_docker();
  $config["sites"].each do |name, config|
    if not $config_local.has_key? "sites" or not $config_local["sites"].has_key? name
      create_site(name)
    end
  end
  
  write_local_config()
end

main()