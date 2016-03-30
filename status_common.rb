require_relative 'common'

def server_running(name)
  config = $config_local['sites'][name]
  exe_silent("docker top #{config['docker_server_name']}")
end
def db_running(name)
  config = $config_local['sites'][name]
  exe_silent("docker top #{config['docker_db_name']}")
end

def web_port_open(name)
  config = $config_local['sites'][name]
  exe_silent("nc -zvv localhost  #{config['web_port']}")
end
def db_port_open(name)
  config = $config_local['sites'][name]
  exe_silent("nc -zvv localhost  #{config['web_port']}")
end
def deploy_port_open(name)
  config = $config_local['sites'][name]
  exe_silent("nc -zvv localhost  #{config['deploy_port']}")
end

def get_status_code(weburl)
  `curl --write-out "%{http_code}\n" --silent --output /dev/null "#{weburl}"`
end
def db_responding(name)
end
def server_responding(name)
  config = $config_local['sites'][name]
  get_status_code("http://localhost:#{config['web_port']}").strip == "200" 
end