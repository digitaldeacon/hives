require_relative 'common'
#
puts "Update Scripts"
#exea("cd #{$path}/data/code && git pull origin master")

def update_static()
  FileUtils.cp_r( "#{$path}/data/dist", path_subdomain("static"))
end

def update_sites_index(name)
  FileUtils.cp_r("#{$path}/data/dist/index.html", path_subdomain("static")+"/index.html")
end
def main()
  update_static()
  $config["sites"].each do |name, config|
    update_sites_index(name)
  end
  write_local_config()
end
main()