require_relative 'common'
#
puts "Update Scripts"
#exea("cd #{$path}/data/code && git pull origin master")

#def update_static()
  #FileUtils.cp_r("#{$path}/data/dist/", path_subdomain("static"))
#end

def update_sites_index(name, site)
  index = path_subdomain(name)+"/index.html"
  FileUtils.cp("#{$path}/data/dist/index.html", index)
  index_content = File.read(index)
  index_content.sub! "'--replace-global-config--'", "{'apiUrl' : 'http://148.251.133.116:#{site["web_port"]}/api'}"
  File.open(index, 'w') { |file| file.write(index_content) } 
  FileUtils.ln_s("#{$path}/data/dist/fonts", path_subdomain(name) +"/fonts")                                                                                  
  FileUtils.ln_s("#{$path}/data/dist/scripts", path_subdomain(name) +"/scripts")                                                                                  
  FileUtils.ln_s("#{$path}/data/dist/styles", path_subdomain(name) +"/styles")                                                                                  
end
def main()
  $config_local["sites"].each do |name, config|
    update_sites_index(name, config)
  end
end
main()