set -e
set -x

STACK=$(basename $PWD)

echo _____________ Build stack
appsody version
appsody stack package


echo _____________ Init from stack
rm -rf ../ex-$STACK
mkdir  ../ex-$STACK
cd     ../ex-$STACK
appsody init dev.local/$STACK
