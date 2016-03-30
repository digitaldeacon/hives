require_relative 'common'
#
puts "------ Restart all stuff ---------"


def main()
  build_docker()
  $config_local["sites"].each do |name, config|
    exe("slc ctl remove #{name}")
    remove_docker(name)
    create_db_docker(name)
    create_server_docker(name)
  end
  exe("sleep 10")
  
  $config_local["sites"].each do |name, config|
    create_slc_service(name)
    set_slc_service(name)
    update_server(name)
  end
end
main()
