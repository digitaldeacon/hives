require_relative 'common'
#
puts "------ Restart all stuff ---------"


def main()
  $config_local["sites"].each do |name, config|
    puts "Checking Status of #{name}".blue
    if(server_running(name))
      puts "[#{name}] Server ok".green
    else
      puts "[#{name}] no docker instance".red
    end
    
    if(db_running(name))
      puts "[#{name}] DB ok".green
    else
      puts "[#{name}] DB not Running".red
    end
    
   
    if(web_port_open(name))
      puts "[#{name}] Web Port ok".green
    else
      puts "[#{name}] Web Port closed".red
    end
    
     if(deploy_port_open(name))
      puts "[#{name}] Deploy Port ok".green
    else
      puts "[#{name}] Deploy Port closed".red
    end
  end
end

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
def db_responding(name)
end
def server_responding(name)
end


main()
