require 'json'
require 'fileutils'

$config = JSON.parse(File.read('config.json'))
$config_local = JSON.parse(File.read('config_local.json'))
$path = $config_local["path"]

def create_site(name)
  puts "creating site #{name}"
  if(not subdomain_exists? name)
    create_subdomain(name)
  end
  # create database
  # start docker with loopback
  # create subdomain
  # copy index.html there
  # replace index.html with config
  
end

def create_mongodb()
  # create mongodb
end


def create_subdomain_plesk(subdomain)
  domain = "memberhive.com"
  path = "#{$path}/data/subdomains/#{subdomain}"
  `sudo /usr/local/psa/bin/subdomain --create #{subdomain} -domain #{domain} -ssi true -php true  -www_root #{path}`
end

def subdomain_exists?(name)
  File.exists?("#{$path}/data/subdomains/#{name}")
end
  
def main()
  if(not subdomain_exists? "static")
    create_subdomain_plesk "static"
  end
  $config["sites"].each do |name, config|
    if not $config_local.has_key? "sites" or not $config_local["sites"].has_key? name
      create_site(name)
    end
  end
end

main()