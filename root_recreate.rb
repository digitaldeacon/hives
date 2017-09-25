require 'json'
require 'fileutils'
require 'pp'
require_relative 'common'
require_relative 'root_common'

# this recreated a site after a move to diffenent server
def create_site(name, config)
  puts "creating site #{name}".blue
  pp config
  
  update_subdomain_plesk(name)
  exe("chown -R #{$owner} #{$path}")
  install_ssl(name)
  forward_subdomain_plesk(name, config['web_port'])
end

def create_docs()
   update_subdomain_plesk("client-docs")
end

def main()
  raise 'Must run as root' unless Process.uid == 0
  
  puts "Boostraping environment".blue
  build_docker()
  
  $config_local['docker_build'] = true
  $config_local["sites"].each do |name, config|
    create_site(name, config)
  end
  
  # create doc site
  create_docs()

  write_local_config()
end

main()
