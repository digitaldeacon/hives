require 'json'
require 'fileutils'
require_relative 'common'

if $config_local.has_key? "sites"
  $config_local["sites"].each do |name, config|
    #remove_subdomain_plesk(name)
    remove_docker(name)
    exe("slc ctl remove #{name}")
  end
end

File.open("config_local.json", "w") do |file|
  pwd = `pwd`
  file.write('{"path":"'+pwd.strip+'"}') 
end