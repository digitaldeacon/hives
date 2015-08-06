require 'json'
require 'fileutils'
require_relative 'ext/colorize'

$config = JSON.parse(File.read('config.json'))
$config_local = JSON.parse(File.read('config_local.json'))
$path = $config_local["path"]

def plesk_path_subdomain(name)
  "/hives/data/subdomains/#{name}"
end
def path_subdomain(name)
  "#{$path}/data/subdomains/#{name}"
end

def create_subdomain_plesk(subdomain)
  puts "create subdomain #{subdomain}"
  domain = "memberhive.com"
  FileUtils.mkpath path_subdomain(subdomain)
  puts "sudo /usr/local/psa/bin/subdomain --create #{subdomain} -domain #{domain} -ssi true -php true  -www_root #{plesk_path_subdomain(subdomain)}"
  exe("sudo /usr/local/psa/bin/subdomain --create #{subdomain} -domain #{domain} -ssi true -php true  -www_root #{plesk_path_subdomain(subdomain)}")
end

def remove_subdomain_plesk(subdomain)
  puts "remove subdomain #{subdomain}"
  domain = "memberhive.com"
  exe("sudo /usr/local/psa/bin/subdomain --remove #{subdomain} -domain #{domain}")
end

def write_local_config()
  File.open("config_local.json","w") do |f|
    f.write($config_local.to_json)
  end
end
def exe(cmd)
  puts "#{cmd}".green.bold
  ret = `#{cmd}`
  puts "return = #{ret}".green
end

def db_path(name)
  "#{$path}/data/db/#{name}"
end


def update_server(name)
  puts "Deploy to server #{name}".blue
  config = $config_local['sites'][name]
  exe("cd #{$path}/data/code && slc deploy --service=#{name} http://localhost:#{config['deploy_port']} master")
end