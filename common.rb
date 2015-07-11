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

def create_subdomain_plesk(subdomain)
  domain = "memberhive.com"
  path = path_subdomain(subdomain)
  `sudo /usr/local/psa/bin/subdomain --create #{subdomain} -domain #{domain} -ssi true -php true  -www_root #{path}`
end

def remove_subdomain_plesk(subdomain)
  domain = "memberhive.com"
  `sudo /usr/local/psa/bin/subdomain --remove #{subdomain} -domain #{domain}`
end