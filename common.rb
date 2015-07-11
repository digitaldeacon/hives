require 'json'
require 'fileutils'

$config = JSON.parse(File.read('config.json'))
$config_local = JSON.parse(File.read('config_local.json'))
$path = $config_local["path"]

def plesk_path_subdomain(name)
  "hives/data/subdomains/#{name}"
end
def path_subdomain(name)
  "#{$path}/data/subdomains/#{name}"
end
def path_dist()
  "#{$path}/data/dist"
end

def create_subdomain_plesk(subdomain)
  puts "create subdomain #{subdomain}"
  domain = "memberhive.com"
  path = ples_path_subdomain(subdomain)
  FileUtils.mkpath path
  `sudo /usr/local/psa/bin/subdomain --create #{subdomain} -domain #{domain} -ssi true -php true  -www_root #{path}`
end

def remove_subdomain_plesk(subdomain)
  puts "remove subdomain #{subdomain}"
  domain = "memberhive.com"
  `sudo /usr/local/psa/bin/subdomain --remove #{subdomain} -domain #{domain}`
end

def write_local_config()
  File.open("config_local.json","w") do |f|
    f.write($config_local.to_json)
  end
end
