require_relative 'common'
#
puts "------ Update Scripts ---------"


def update_sites_index(name, site)
  FileUtils.rm_rf(path_subdomain(name))
  FileUtils.mkpath(path_subdomain(name))
  index = path_subdomain(name)+"/index.html"
  FileUtils.cp("#{$path}/data/dist/index.html", index)
  index_content = File.read(index)
  index_content.sub! "'--replace-global-config--'", "{'apiUrl' : 'http://148.251.133.116:#{site["web_port"]}/api'}"
  File.open(index, 'w') { |file| file.write(index_content) } 
  FileUtils.ln_s("#{$path}/data/dist/fonts", path_subdomain(name) +"/fonts")                                                                                  
  FileUtils.ln_s("#{$path}/data/dist/scripts", path_subdomain(name) +"/scripts")                                                                                  
  FileUtils.ln_s("#{$path}/data/dist/styles", path_subdomain(name) +"/styles")   
  FileUtils.mkpath( path_subdomain(name) + "/app/")
  FileUtils.ln_s("#{$path}/data/dist/app/images", path_subdomain(name) +"/app/images")                                                                                  
  FileUtils.ln_s("#{$path}/data/dist/favicon.ico", path_subdomain(name) +"/favicon.ico")                                                                                  
  FileUtils.ln_s("#{$path}/data/dist/robots.txt", path_subdomain(name) +"/robots.txt")                                                                                  
  FileUtils.ln_s("#{$path}/data/dist/favicon.png", path_subdomain(name) +"/favicon.png")                                                                                  
end

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
    update_sites_index(name, config)
  end
end
main()