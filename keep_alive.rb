require_relative 'status_common'

def main()
  $config_local["sites"].each do |name, config|
    if(!server_running(name))
      remove_docker_server(name)
      create_server_docker(name)
    end
    if(!db_running(name))
      remove_docker_db(name)
      create_server_db(name)
    end
   
  end
end


main()
