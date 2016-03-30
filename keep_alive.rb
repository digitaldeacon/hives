require_relative 'status_common'

def main()
  $config_local["sites"].each do |name, config|
    fine = true
    
    if(!db_running(name))
      remove_docker_db(name)
      create_server_db(name)
      fine = false
    end
    
    if(!server_running(name))
      remove_docker_server(name)
      create_server_docker(name)
      fine = false
    end
    retrys = 0
    if(!fine)
      while(!create_slc_service(name))
        retrys += 1
        exe("sleep 5");
        if(retrys > 5)
          puts "cannot start slc #{name}"
        end
      end 
      set_slc_service(name)
      update_server(name)
    end
  end
end


main()
