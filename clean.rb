require 'json'
require 'fileutils'
require_relative 'common'

remove_subdomain_plesk("static")

$config_local["sites"].each do |name, config|
  remove_subdomain_plesk(name)
end