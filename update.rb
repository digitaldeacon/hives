require_relative 'common'
#FileUtils.cp_r(path_dist(), path_subdomain("static"))

exe("cd #{$path}/data/code && git pull origin master")