require 'json'

$config = JSON.parse(File.read('config.json'))
$config_local = JSON.parse(File.read('config_local.json'))
def create_site(name)
  puts "creating site #{name}"
  
  # create mongodb
  # create database
  # start docker with loopback
  # create subdomain
  # copy index.html there
  # replace index.html with config
  
end

# create static domain
# copy files there

def main()
  $config["sites"].each do |name, config|
    if not $config_local.has_key? "sites" or not $config_local["sites"].has_key? name
      create_site(name)
    end
  end
end

main()