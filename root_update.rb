require_relative 'common'
require_relative 'root_common'

def main()
  $config_local["sites"].each do |name, config|
    forward_subdomain_plesk(name, config['web_port'])
  end
end
main()
