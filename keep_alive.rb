require_relative 'status_common'

def main()
  $config_local["sites"].each do |name, config|
    if(!server_running(name))
      create_server_docker(name)
    end
    if(!db_running(name))
      create_server_docker(name)
    end
   
  end
end


main()
