require 'json'
require 'fileutils'
require_relative 'ext/colorize'

$config = JSON.parse(File.read('config.json'))
$config_local = JSON.parse(File.read('config_local.json'))
$path = $config_local["path"]
$domain = "memberhive.com"

def plesk_path_subdomain(name)
  "/hives/data/subdomains/#{name}"
end
def path_subdomain(name)
  "#{$path}/data/subdomains/#{name}"
end

def create_subdomain_plesk(subdomain)
  puts "create subdomain #{subdomain}"
  domain = "memberhive.com"
  FileUtils.rm_rf path_subdomain(subdomain)
  FileUtils.mkpath path_subdomain(subdomain)
  puts "sudo /usr/local/psa/bin/subdomain --create #{subdomain} -domain #{domain} -ssi false -php false  -www_root #{plesk_path_subdomain(subdomain)}"
  exe("sudo /usr/local/psa/bin/subdomain --create #{subdomain} -domain #{domain} -ssi false -php false  -www_root #{plesk_path_subdomain(subdomain)}")
end

def remove_subdomain_plesk(subdomain)
  puts "remove subdomain #{subdomain}"
  domain = "memberhive.com"
  exe("sudo /usr/local/psa/bin/subdomain --remove #{subdomain} -domain #{domain}")
end

def subdomain_exists?(name)
  File.exists?(path_subdomain(name))
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
  return ret
end

def db_path(name)
  "#{$path}/data/clients/#{name}/db"
end
def files_path(name)
  "#{$path}/data/clients/#{name}/files"
end

def update_server(name)
  puts "Deploy to server #{name}".blue
  config = $config_local['sites'][name]
  exe("cd #{$path}/data/code && slc deploy --service=#{name} http://localhost:#{config['deploy_port']} master")
end


def create_db_docker(name, docker_db_name)
  puts "Create db server for #{name}".blue
  db = db_path(name)
  db_exists = true
  if not File.exists? db
    db_exists = false
    FileUtils.mkpath db
  end
  ext = ""
  if($config["sites"][name].has_key? "exposeDB") 
    ext = "-p 0.0.0.0:#{$config["sites"][name]["exposeDB"]}:27017"
  end
  exe("docker run -d -v #{db}:/data/db --name #{docker_db_name} #{ext} -d mongo:2.4")
  return db_exists
end

def create_server_docker(name, docker_server_name, deploy_port, web_port, db_name)
  puts "Create docker server for #{name}".blue
  files_path = files_path(name)
  FileUtils.mkpath files_path 
  FileUtils.mkpath(files_path+'/avatar')
  exe("docker run -d -p #{deploy_port}:8701 -p #{web_port}:3001 -v #{files_path}:/usr/local/files --name #{docker_server_name} --link #{db_name}:db mh-strong-pm")
  exe("docker exec #{docker_server_name} chown -R strong-pm:strong-pm /usr/local/files")
end

def remove_docker(name)
  config = $config_local['sites'][name]
  exe("docker stop -t 1 #{config['docker_server_name']} && docker rm #{config['docker_server_name']}")
  exe("docker stop -t 1 #{config['docker_db_name']} && docker rm #{config['docker_db_name']}")
end

def stop_docker(name)
  config = $config_local['sites'][name]
  exe("docker stop -t 1 #{config['docker_server_name']}")
  exe("docker stop -t 1 #{config['docker_db_name']}")
end

def create_slc_service(name)
  config = $config_local['sites'][name]
  exe("slc ctl -C http://127.0.0.1:#{config['deploy_port']} create #{name}")
end
def set_slc_service(name)
  config = $config_local['sites'][name]
  exe("slc ctl -C http://127.0.0.1:#{config['deploy_port']} env-set #{name} NODE_ENV=production MH_DB_PASSWORD=#{config['db_password']} MH_DB_NAME=#{name} MH_DB_USER=#{name} MH_ROOT_EMAIL='#{config['root_email']}' MH_ROOT_PASSWORD=#{config['root_password']} MH_ROOT_USERNAME=#{config['root_username']}")
  exe("slc ctl -C http://127.0.0.1:#{config['deploy_port']} set-size #{name} 4")
end
def build_docker()
  puts "Building docker files".colorize(:blue)
  exe("cd docker/server && docker build -t mh-strong-pm .")
  exe("docker pull mongo:2.4")
end



