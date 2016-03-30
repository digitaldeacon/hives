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
   
    if(!fine)
      create_slc_service(name)
      set_slc_service(name)
      update_server(name)
    end
  end
end


main()
