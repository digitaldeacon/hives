echo "Configuring git repository"
cd git
mkdir memberhive
cd memberhive
git init --bare
cd ../..
cp hooks/post-receive git/memberhive/hooks
chmod +x git/memberhive/hooks/post-receive

if [ ! -f config.json ]
then
  cat "{}" > config.json
fi

cat "{}" > config_local.json
