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
  db_password = rand(36**12).to_s(36)
  if(not $config_local.has_key? 'sites')
    $config_local['sites'] = {}
  end
  
  $config_local['sites'][name] = 
      {
        "deploy_port" =>  deploy_port,
        "web_port" => web_port,
        "docker_server_name" => docker_server_name,
        "docker_db_name" => docker_db_name,
        "db_password" => db_password
      }
  $config_local['deploy_port'] = deploy_port+1;
  $config_local['web_port'] = web_port+1;
  write_local_config()
  
  # start docker with loopback
  if not create_db_docker(name, docker_db_name) #frist time
    puts "create db and user".blue
    exe("sleep 30")
    ret = "Error: "
    while(ret.include? "Error: ")
      ret = exe("docker exec -it #{docker_db_name} mongo #{name} --eval 'db.addUser(\"#{name}\", \"#{db_password}\");'")
    end
  end
  create_server_docker(docker_server_name, deploy_port, web_port, docker_db_name)
  exe("sleep 2")
  update_server(name)
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