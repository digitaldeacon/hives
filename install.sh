echo "Configuring git repository"
base=`pwd`
rm ${base}/data -rf
mkdir ${base}/data
mkdir ${base}/data/git
mkdir ${base}/data/subdomains
mkdir ${base}/data/dist
mkdir ${base}/data/code
mkdir ${base}/data/db

cd ${base}/data/git
git init --bare

cd ${base}/data/code
git init
git remote add origin ${base}/data/git

cp ${base}/hooks/post-receive ${base}/data/git/hooks
chmod +x ${base}/data/git/hooks/post-receive

cd ${base}
if [ ! -f config.json ]
then
  echo "{}" > config.json
fi
echo "{\"path\":\"`pwd`\"}" > config_local.json