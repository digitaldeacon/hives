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
def db_responding(name)
end
def server_responding(name)
end


main()
