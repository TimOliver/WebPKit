# When running this project as an example,
# integrate WebP by downloading static binaries from
# TimOliver/WebP-Cocoa

FOLDER=$1
FRAMEWORK=$2
URL=$3

cd ${FOLDER}

if [[ ! -d ${FRAMEWORK} ]]; then
    curl -sS ${URL} > framework.zip
    unzip framework.zip
    cp -r libwebp*/${FRAMEWORK} .
    rm -r libwebp*/
    rm framework.zip
fi
