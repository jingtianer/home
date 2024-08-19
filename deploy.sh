#!/bin/bash
# cp -r ./source /mnt/d/jingtian/blog_back
# cp *.yml /mnt/d/jingtian/blog_back/

hexo clean

# enable errexit
set -e
# cannot commit tokens to github
git add .
git commit -m "`date`"
git push origin master
hexo g
# sed -i 's/github.com\/jingtianer/jingtianer.github.io/g' public/atom.xml

if [ `uname` == "Darwin" ]; then
    echo "MacOS"
    sed -i ".bak" "s/<my token>/`cat token.txt`/g" _config.yml
else
    sed -i "s/<my token>/`cat token.txt`/g" _config.yml
fi

hexo d 2>&1 > deploy.log

if [ `uname` == "Darwin" ]; then
    echo "MacOS"
    mv _config.yml.bak _config.yml
else
    sed -i "s/<my token>/`cat token.txt`/g" _config.yml
fi