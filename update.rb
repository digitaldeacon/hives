require_relative 'common'
# This is a script which is executed after a update to the memberhive code
puts "------ Update Scripts ---------"


def update_doc()
  puts "Updating the documentation".blue
  FileUtils.rm_rf(path_subdomain("client-docs"))
  FileUtils.ln_s("#{$path}/data/code/dist/docs/", path_subdomain("client-docs"))  
end

def main()
  update_doc()
  $config_local["sites"].each do |name, config|
    update_server(name)
  end
end
main()
