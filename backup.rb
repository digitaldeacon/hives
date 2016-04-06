require_relative 'common'

$backups = [
  "backup_bko@148.251.133.116:/var/www/backup/bko"
]


def main()
  #create backups
  #copy backup
  exe(
  $backups.each do |target|
    exe("rsync -av #{$path}/backups #{target} > /dev/null")
  end
  
end


main()
