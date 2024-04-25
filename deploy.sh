#!/bin/bash
# cp -r ./source /mnt/d/jingtian/blog_back
# cp *.yml /mnt/d/jingtian/blog_back/

hexo clean

# cannot commit tokens to github
git add .
git commit -m "`date`"
git push master
hexo g
# sed -i 's/github.com\/jingtianer/jingtianer.github.io/g' public/atom.xml

sed -i "s/<my token>/`cat token.txt`/g" _config.yml
hexo d
sed -i "s/`cat token.txt`/<my token>/g" _config.yml