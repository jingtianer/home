# cp -r ./source /mnt/d/jingtian/blog_back
# cp *.yml /mnt/d/jingtian/blog_back/
hexo clean
git add .
git commit -m `date`
git push
hexo g
# sed -i 's/github.com\/jingtianer/jingtianer.github.io/g' public/atom.xml
hexo d
