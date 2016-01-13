require_relative 'common'
#
puts "------ Update Scripts ---------"


def update_doc()
  if(not subdomain_exists? "client-docs")
    create_subdomain_plesk("client-docs")
  end
  FileUtils.rm_rf(path_subdomain("client-docs"))
  FileUtils.ln_s("#{$path}/data/dist/docs/", path_subdomain("client-docs"))  
end
def main()
  update_doc()
  
  $config_local["sites"].each do |name, config|
    update_server(name)
  end
end
main()