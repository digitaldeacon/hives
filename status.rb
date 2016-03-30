require_relative 'status_common'

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
    
    if(server_responding(name))
      puts "[#{name}] Webserver ok".green
    else
      puts "[#{name}] webserver not responding".red
    end
  end
end


main()
