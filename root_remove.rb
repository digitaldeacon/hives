require 'json'
require 'fileutils'
require 'optparse'
require_relative 'common'
require_relative 'root_common'


def main()
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: root_remove.rb [options]"

    opts.on("-n", "--name NAME", "Name of the site to remove") do |n|
      options[:name] = n
    end
  end.parse!
  abort("name option not set") if options[:name].nil?
  if($config_local['sites'].has_key? name)
    
    config = $config_local['sites'][name]
    if(config.has_key? 'docker_server_name')
      exe("docker stop -t 1 #{config['docker_server_name']} && docker rm #{config['docker_server_name']}")
    end
    if(config.has_key? 'docker_db_name')
      exe("docker stop -t 1 #{config['docker_db_name']} && docker rm #{config['docker_db_name']}")
    end
    
    if(subdomain_exists? name)
      remove_subdomain_plesk(name)
    end
    
    
    if File.exists?(db_path(name))
      FileUtils.rm_rf db_path(name)
    end
    
    if File.exists?(files_path(name))
      FileUtils.rm_rf files_path(name)
    end
  else
    puts "No local config for this site".red
  end
end

main()
