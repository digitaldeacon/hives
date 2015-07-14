require 'json'
require 'fileutils'
require_relative 'common'

remove_subdomain_plesk("static")
if $config_local.has_key? "sites"
  $config_local["sites"].each do |name, config|
    remove_subdomain_plesk(name)
    exe("docker stop #{config['docker_name']} && docker rm #{config['docker_server_name']}")
  end
end