require 'json'
require 'fileutils'
require_relative 'common'

remove_subdomain_plesk("static")
if $config_local.has_key? "sites"
  $config_local["sites"].each do |name, config|
    remove_subdomain_plesk(name)
    exe("docker stop #{config['docker_server_name']} && docker rm #{config['docker_server_name']}")
    exe("docker stop #{config['docker_db_name']} && docker rm #{config['docker_db_name']}")
  end
  FileUtils.rm()
  File.open("config_local.json", "w") do |file|
    pwd = `pwd`
    file.write('{"path":"'+pwd+'"}') 
  end
end