require 'json'
require 'fileutils'

$config = JSON.parse(File.read('config.json'))
$config_local = JSON.parse(File.read('config_local.json'))
$path = $config_local["path"]

def path_subdomain(name)
  "#{$path}/data/subdomains/#{name}"
end

def path_dist()
  "#{$path}/data/dist"
end
