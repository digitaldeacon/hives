echo "Configuring git repository"
mkdir git
cd git
mkdir memberhive
cd memberhive
git init --bare
cd ../..
cp hooks/post-receive git/memberhive/hooks
chmod +x git/memberhive/hooks/post-receive

if [ ! -f config.json ]
then
  echo "{}" > config.json
fi
a=
echo "{\"path\":\"`pwd`\"}" > config_local.json


mkdir subdomains