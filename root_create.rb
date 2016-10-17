require 'json'
require 'fileutils'
require_relative 'common'
require_relative 'root_common'

def create_site(name, config)
  puts "creating site #{name}".blue
  
  update_subdomain_plesk(name)
  exe("chown -R #{$owner} #{$path}")
  install_ssl(name)
  
  deploy_port = $config_local.fetch('deploy_port', 8701)
  web_port = $config_local.fetch('web_port', 10000)
  docker_server_name = "mh-server-"+name
  docker_db_name = "mh-db-"+name
  db_password = rand(36**12).to_s(36)
  root_password = rand(36**12).to_s(36)
  root_email = config['root_email'] || name + "@memberhive.com"
  root_username = config['root_username'] || name
      
  if(not $config_local.has_key? 'sites')
    $config_local['sites'] = {}
  end
  
  $config_local['sites'][name] = 
      {
        "deploy_port" =>  deploy_port,
        "web_port" => web_port,
        "docker_server_name" => docker_server_name,
        "docker_db_name" => docker_db_name,
        "db_password" => db_password,
        "root_password" => root_password,
        "root_email" => root_email,
        "root_username" => root_username
      }
  $config_local['deploy_port'] = deploy_port+1;
  $config_local['web_port'] = web_port+1;
  write_local_config()

  # start docker with loopback
  if not create_docker(name) #frist time
    puts "create db and user".blue
    exe("sleep 30")
    retrys = 0
    while(!exe("docker exec -i #{docker_db_name} mongo #{name} --eval 'db.addUser(\"#{name}\", \"#{db_password}\");'"))
      retrys += 1
      exe("sleep 5");
      if(retrys > 50)
        abort("failed to execute mongo")
      end
    end
  end

  create_slc_service(name)
  set_slc_service(name)
  exe("sleep 2")
  update_server(name)
  forward_subdomain_plesk(name, web_port)


end

def create_docs()
   update_subdomain_plesk("client-docs")
end

def main()
  raise 'Must run as root' unless Process.uid == 0
  
  puts "Boostraping environment".blue

  if not $config_local.has_key? 'docker_build'
    build_docker();
  end
  
  $config_local['docker_build'] = true
  $config["sites"].each do |name, config|
    if not $config_local.has_key? "sites" or not $config_local["sites"].has_key? name
      create_site(name, config)
    end
  end
  
  # create doc site
  create_docs()
  
  
  write_local_config()
end

main()
