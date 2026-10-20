QQ_PET_OUT=`pwd`/public/qqpet-out
rm -rf $QQ_PET_OUT
pushd qqpet-web
VITE_OUTPUT_DIR=$QQ_PET_OUT npm run build:web
popd