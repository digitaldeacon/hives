require_relative 'common'
require_relative 'root_common'

def main()
  raise 'Must run as root' unless Process.uid == 0
  
  $config_local["sites"].each do |name, config|
    forward_subdomain_plesk(name, config['web_port'])
  end
end
main()
