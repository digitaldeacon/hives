require 'json'

$config = JSON.parse(File.read('config.json'))
$config_local = JSON.parse(File.read('config_local.json'))
$path = $config_local["path"]

def create_site(name)
  puts "creating site #{name}"
  
 "usr/local/psa/bin/subdomain --create subdomainame -domain domainname -ssi true -php true  -www_root /directoryname"
  # create database
  # start docker with loopback
  # create subdomain
  # copy index.html there
  # replace index.html with config
  
end

def create_mongodb()
  # create mongodb
end

def create_static_domain()
  "usr/local/psa/bin/subdomain --create subdomainame -domain domainname -ssi true -php true  -www_root /directoryname"
  # create static domain
  # copy files there
end


def main()
  if(not File.exists($path + "/subdomains/static"))
    create_static_domain()
  end
  $config["sites"].each do |name, config|
    if not $config_local.has_key? "sites" or not $config_local["sites"].has_key? name
      create_site(name)
    end
  end
end

main()