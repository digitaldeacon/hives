require 'json'
require 'fileutils'#
require 'open3'
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
def write_local_config()
  File.open("config_local.json","w") do |f|
    f.write(JSON.pretty_generate($config_local))
  end
end
def exef(cmd)
  puts "#{cmd}".green.bold
  out, err, st = Open3.capture3(cmd)
  puts "#{out}".green
  puts "#{err}".red
  exit("command failed") if not st.success?
end

def exe(cmd)
  puts "#{cmd}".green.bold
  out, err, st = Open3.capture3(cmd)
  puts "#{out}".green
  puts "#{err}".red
  return st.success?
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
  exef("cd #{$path}/data/code && slc deploy --service=#{name} http://localhost:#{config['deploy_port']} master")
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
  exef("docker run -d -v #{db}:/data/db --name #{docker_db_name} #{ext} -d mongo:2.4")
  return db_exists
end

def create_server_docker(name, docker_server_name, deploy_port, web_port, db_name)
  puts "Create docker server for #{name}".blue
  files_path = files_path(name)
  FileUtils.mkpath files_path 
  FileUtils.mkpath files_path+'/avatar'
  exef("docker run -d -p #{deploy_port}:8701 -p #{web_port}:3001 -v #{files_path}:/usr/local/files --name #{docker_server_name} --link #{db_name}:db mh-strong-pm")
  exef("docker exec #{docker_server_name} chown -R strong-pm:strong-pm /usr/local/files")
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
  exef("slc ctl -C http://127.0.0.1:#{config['deploy_port']} create #{name}")
end
def remove_slc_service(name)
  config = $config_local['sites'][name]
  exef("slc ctl -C http://127.0.0.1:#{config['deploy_port']} remove #{name}")
end
def set_slc_service(name)
  config = $config_local['sites'][name]
  exef("slc ctl -C http://127.0.0.1:#{config['deploy_port']} env-set #{name} NODE_ENV=production MH_DB_PASSWORD=#{config['db_password']} MH_DB_NAME=#{name} MH_DB_USER=#{name} MH_ROOT_EMAIL='#{config['root_email']}' MH_ROOT_PASSWORD=#{config['root_password']} MH_ROOT_USERNAME=#{config['root_username']}")
  exef("slc ctl -C http://127.0.0.1:#{config['deploy_port']} set-size #{name} 4")
end
def build_docker()
  puts "Building docker files".colorize(:blue)
  exef("cd docker/server && docker build -t mh-strong-pm .")
  exef("docker pull mongo:2.4")
end



