require 'json'
require 'fileutils'
require_relative 'common'
require 'colorize'

def create_site(name)
  puts "creating site #{name}".blue
  if(not subdomain_exists? name)
    create_subdomain_plesk(name)
  end
  deploy_port = $config_local.fetch('deploy_port', 8701)
  web_port = $config_local.fetch('web_port', 10000)
  server_name = "mh-server-"+name
  db_name = "mh-db-"+name
  # start docker with loopback
  create_db_docker(db_name)
  create_server_docker(server_name, deploy_port, web_port, db_name)
  
  $config_local['deploy_port'] = deploy_port+1;
  $config_local['web_port'] = web_port+1;
  exe("sleep 2")
  exe("cd #{$path}/data/code && slc deploy http://localhost:#{deploy_port} master")
  
  if(not $config_local.has_key? 'sites')
    $config_local['sites'] = {}
  end
  
  $config_local['sites'][name] = 
      {
        "deploy_port" =>  deploy_port,
        "web_port" => web_port,
        "docker_server_name" => server_name,
        "docker_db_name" => db_name
      }
  write_local_config()
end

def create_db_docker(name)
  puts "Create db server for #{name}".colorize(:blue)
  exe("docker run -d --name #{name} -d mongo")
end

def create_server_docker(name, deploy_port, web_port, db_name)
  puts "Create docker server for #{name}".colorize(:blue)
  exe("docker run -d -p #{deploy_port}:8701 -p #{web_port}:3001 --name #{name} --link #{db_name}:db mh-strong-pm")
end


def build_docker()
  puts "Building docker files".colorize(:blue)
  exe("cd docker/server && docker build -t mh-strong-pm .")
  exe("docker pull mongo")

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