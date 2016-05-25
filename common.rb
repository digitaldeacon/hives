require 'json'
require 'fileutils'
require 'open3'
require 'yaml'
require_relative 'ext/colorize'

$config = JSON.parse(File.read('config.json'))
$config_local = JSON.parse(File.read('config_local.json'))
$path = $config_local["path"]
$domain = "memberhive.com"
$MONGO_VERSION = "mongo:2.4"

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
  abort("command failed") if not st.success?
end

def exe(cmd)
  puts "#{cmd}".green.bold
  out, err, st = Open3.capture3(cmd)
  puts "#{out}".green
  puts "#{err}".red
  return st.success?
end
def exe_silent(cmd)
  out, err, st = Open3.capture3(cmd)
  return st.success?
end


def db_path(name)
  "#{$path}/data/clients/#{name}/db"
end
def files_path(name)
  "#{$path}/data/clients/#{name}/files"
end
def data_path(name)
  "#{$path}/data/clients/#{name}"
end

def update_server(name)
  puts "Deploy to server #{name}".blue
  config = $config_local['sites'][name]
  deployCmd = "cd #{$path}/data/code && slc deploy --service=#{name} http://localhost:#{config['deploy_port']} master"
  
  retrys = 0
  while(!exe(deployCmd))
    retrys += 1
    exe("sleep 5");
    if(retrys > 3)
      retrys = -1
      break;
    end
  end
 
end

def complete_restart(name)
  config = $config_local['sites'][name]
  exe("slc ctl remove #{name}")
  
  remove_docker(name)
  create_db_docker(name)
  exe("sleep 5")
  create_server_docker(name)
  exe("sleep 10")
  
  while(!create_slc_service(name))
    retrys += 1
    exe("sleep 5");
    if(retrys > 10)
      puts "cannot start slc #{name}"
      return
    end
  end 
  set_slc_service(name)
  update_server(name)
end

def build_docker()
  puts "Building docker files".blue
  exef("cd docker/server && docker build -t mh-strong-pm .")
  exef("docker pull #{$MONGO_VERSION}")
end

def create_docker(name)
  config = $config_local['sites'][name]
  globalConfig = $config['sites'][name]
  db_exists = prepare_db(name)
  prepare_server(name)
  
  server = {
    'image' => 'mh-strong-pm',
    'container_name' => config['docker_server_name'],
    'depends_on' => ['db'],
    'ports' => [
      "127.0.0.1:#{config['deploy_port']}:8701",
      "127.0.0.1:#{config['web_port']}:3001"
    ],
    'volumes' => ["#{files_path(name)}:/usr/local/files"],
    'links' => ["db"]
  }
  db = {
    'image' => $MONGO_VERSION,
    'container_name' => config['docker_db_name'],
    'ports' => [
    ],
    'volumes' => ["#{db_path(name)}:/data/db"],
    'command' => '--smallfiles'
  }
  
  if(globalConfig.has_key? "exposeDB") 
   db['ports'] = ["0.0.0.0:#{globalConfig["exposeDB"]}:27017"];
  end
  
  composer = {
    'version' => '2',
    'services' => {
      'server' => server,
      'db' => db
    }
  }
  File.open(data_path(name)+'/docker-compose.yml', 'w') {|f| f.write composer.to_yaml }
  exef("cd #{data_path(name)} && docker-compose up -d")

  exef("docker exec --user root #{config['docker_server_name']} chown -R strong-pm:strong-pm /usr/local/files")
  return db_exists
end

def prepare_db(name)
  db = db_path(name)
  db_exists = true
  if not File.exists? db
    db_exists = false
    FileUtils.mkpath db
  end
  return db_exists
end
def prepare_server(name)
  files_path = files_path(name)
  FileUtils.mkpath files_path 
  FileUtils.mkpath files_path+'/avatar'
end

def remove_docker(name)
  remove_docker_db(name)
  remove_docker_server(name)
end

def remove_docker_server(name)
  config = $config_local['sites'][name]
  exe("docker stop -t 1 #{config['docker_server_name']}");
  exe("docker rm #{config['docker_server_name']}")
end
def remove_docker_db(name)
  config = $config_local['sites'][name]
  exe("docker stop -t 1 #{config['docker_db_name']}")
  exe("docker rm #{config['docker_db_name']}")
end
def stop_docker(name)
  config = $config_local['sites'][name]
  exe("docker stop -t 1 #{config['docker_server_name']}")
  exe("docker stop -t 1 #{config['docker_db_name']}")
end

def create_slc_service(name)
  config = $config_local['sites'][name]
  return exe("slc ctl -C http://127.0.0.1:#{config['deploy_port']} create #{name}")
end
def remove_slc_service(name)
  config = $config_local['sites'][name]
  return exe("slc ctl -C http://127.0.0.1:#{config['deploy_port']} remove #{name}")
end
def set_slc_service(name)
  config = $config_local['sites'][name]
  exe("slc ctl -C http://127.0.0.1:#{config['deploy_port']} env-set #{name} NODE_ENV=production MH_DB_PASSWORD=#{config['db_password']} MH_DB_NAME=#{name} MH_DB_USER=#{name} MH_ROOT_EMAIL='#{config['root_email']}' MH_ROOT_PASSWORD=#{config['root_password']} MH_ROOT_USERNAME=#{config['root_username']} PHANTOMJS_CDNURL=http://cnpmjs.org/downloads")
  return exe("slc ctl -C http://127.0.0.1:#{config['deploy_port']} set-size #{name} 4")
end




