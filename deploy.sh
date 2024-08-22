#!/bin/bash
# cp -r ./source /mnt/d/jingtian/blog_back
# cp *.yml /mnt/d/jingtian/blog_back/

hexo clean

# enable errexit, do not deploy if master is not successfully committed
set -e
# cannot commit tokens to github
git add .
git commit -m "`date`"
git push origin master
hexo g
# sed -i 's/github.com\/jingtianer/jingtianer.github.io/g' public/atom.xml

# disable errexit, to make sure the command that remove token from _comfig.yml can be executed no matter if deployment is successful or not
set +e 
if [ `uname` == "Darwin" ]; then
    echo "MacOS"
    sed -i ".bak" "s/<my token>/`cat token.txt`/g" _config.yml
else
    sed -i "s/<my token>/`cat token.txt`/g" _config.yml
fi

hexo d > deploy.log 2>&1 || echo "fail, check deplog.log!"

if [ `uname` == "Darwin" ]; then
    echo "MacOS"
    mv _config.yml.bak _config.yml
else
    sed -i "s/<my token>/`cat token.txt`/g" _config.yml
fi