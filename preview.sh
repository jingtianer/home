set -e 
hexo clean
hexo g
./build_qqpet.sh
hexo s