require 'json'
require 'fileutils'
require_relative 'common'

puts "Create Data"

base=`pwd`
mkdir ${base}/data
mkdir ${base}/data/git
mkdir ${base}/data/subdomains
mkdir ${base}/data/dist
cd ${base}/data/git
git init --bare
cd ${base}
cp ${base}/hooks/post-receive ${base}/data/git/hooks
chmod +x ${base}/data/git/hooks/post-receive

if [ ! -f config.json ]
then
  echo "{}" > config.json
fi
echo "{\"path\":\"`pwd`\"}" > config_local.json