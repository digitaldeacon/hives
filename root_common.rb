$domain = "memberhive.com"

$owner = "memberhive:psacln"

def plesk_path_subdomain(name)
  "/hives/data/subdomains/#{name}"
end

def create_subdomain_plesk(name)
  puts "Create Dubdomain #{name}".blue
  exef("/usr/local/psa/bin/subdomain --create #{name} -domain #{$domain} -www_root httpdocs/")
end

def update_subdomain_plesk(name)
  puts "Update Subdomain #{name}".blue
  remove_subdomain_plesk(name)
  create_subdomain_plesk(name)
end

def forward_subdomain_plesk(subdomain, port)
    puts "create config #{subdomain}"

    http = "
    RedirectMatch permanent ^(?!/\.well-known/acme-challenge/).* https://#{subdomain}.#{$domain}$0
"
    https = "
<IfModule mod_headers.c>
    Header always set Strict-Transport-Security \"max-age=15768000; includeSubDomains; preload\"
</IfModule>
RewriteEngine On
ProxyPass /.well-known !
ProxyPassReverse /.well-known !
ProxyPass / http://127.0.0.1:#{port}/
ProxyPassReverse / http://127.0.0.1:#{port}/"
    
    File.write("/var/www/vhosts/system/#{subdomain}.#{$domain}/conf/vhost.conf", http)
    File.write("/var/www/vhosts/system/#{subdomain}.#{$domain}/conf/vhost_ssl.conf", https)

    exe("/usr/local/psa/admin/sbin/httpdmng --reconfigure-domain #{subdomain}.#{$domain}")
end


def install_ssl(subdomain)
  exef("plesk bin extension --exec letsencrypt cli.php run -d #{subdomain}.#{$domain}")
end
    

def remove_subdomain_plesk(subdomain)
  puts "remove subdomain #{subdomain}"
  exe("/usr/local/psa/bin/subdomain --remove #{subdomain} -domain #{$domain}")
end

def set_rights()
 
 end

