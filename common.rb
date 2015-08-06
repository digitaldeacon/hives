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

def create_server_docker(name, deploy_port, web_port, db_name)
  puts "Create docker server for #{name}".blue
  exe("docker run -d -p #{deploy_port}:8701 -p #{web_port}:3001 --name #{name} --link #{db_name}:db mh-strong-pm")
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

def create_slc_service(name, db_password)
  exe("slc ctl create #{name}")
  exe("slc ctl env-set #{name} NODE_ENV=production")
  exe("slc ctl env-set #{name} MH_DB_PASSWORD=#{db_password}")
end

def build_docker()
  puts "Building docker files".colorize(:blue)
  exe("cd docker/server && docker build -t mh-strong-pm .")
  exe("docker pull mongo:2.4")
end


def subdomain_exists?(name)
  File.exists?(path_subdomain(name))
end

