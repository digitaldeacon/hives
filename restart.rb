require_relative 'common'
#
puts "------ Restart all stuff ---------"


def main()
  build_docker()
  $config_local["sites"].each do |name, config|
    exe("slc ctl remove #{name}")
    remove_docker(name)
    create_db_docker(name, config['docker_db_name'])
    create_server_docker(
      name,
      config['docker_server_name'], 
      config['deploy_port'], 
      config['web_port'], 
      config['docker_db_name']
    )
    exe("sleep 2")
    create_slc_service(name)
    set_slc_service(name)
    update_server(name)
  end
end
main()
