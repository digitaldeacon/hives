$domain = "memberhive.com"
def create_subdomain_plesk(subdomain)
  puts "create subdomain #{subdomain}"
  FileUtils.rm_rf path_subdomain(subdomain)
  FileUtils.mkpath path_subdomain(subdomain)
  exe("/usr/local/psa/bin/subdomain --create #{subdomain} -domain #{$domain} -www_root #{plesk_path_subdomain(subdomain)}")
end

def forward_subdomain_plesk(subdomain, port)
    puts "create config #{subdomain}"

    http = "
RewriteEngine On
ProxyPass /.well-known !
ProxyPassReverse /.well-known !
ProxyPass / http://localhost:#{port}/
ProxyPassReverse / http://localhost:#{port}/"

    https = "
RewriteEngine On
ProxyPass /.well-known !
ProxyPassReverse /.well-known !
ProxyPass / http://localhost:#{port}/
ProxyPassReverse / http://localhost:#{port}/"
    
    File.write("/var/www/vhosts/system/#{subdomain}.#{$domain}/conf/vhost.conf", http)
    File.write("/var/www/vhosts/system/#{subdomain}.#{$domain}/conf/vhost_ssl.conf", https)

    exe("/usr/local/psa/admin/sbin/httpdmng --reconfigure-domain #{subdomain}.#{$domain}")
end


    

def remove_subdomain_plesk(subdomain)
  puts "remove subdomain #{subdomain}"
  domain = "memberhive.com"
  exe("/usr/local/psa/bin/subdomain --remove #{subdomain} -domain #{domain}")
end

def subdomain_exists?(name)
  File.exists?(path_subdomain(name))
end

