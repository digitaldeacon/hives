echo "Configuring git repository"
base=`pwd`
rm ${base}/data -rf
mkdir ${base}/data
mkdir ${base}/data/git
mkdir ${base}/data/subdomains
mkdir ${base}/data/dist
mkdir ${base}/data/code
cd ${base}/data/code
git init
cd ${base}/data/git
git init --bare
git remote add origin ${base}/data/code
cd ${base}
cp ${base}/hooks/post-receive ${base}/data/git/hooks
chmod +x ${base}/data/git/hooks/post-receive


if [ ! -f config.json ]
then
  echo "{}" > config.json
fi
echo "{\"path\":\"`pwd`\"}" > config_local.json