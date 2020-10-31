
# download.sh

# Copyright 2020 Timothy Oliver. All rights reserved.

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
# IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Downloads and integrates precompiled versions of WebP.framework 
# from TimOliver/WebP-Cocoa before building any of the project targets.

VERSION="v1.1.0"
FOLDER="WebPKitExample-${1}"
FRAMEWORK="WebP.${2}"
URL="https://github.com/TimOliver/WebP-Cocoa/releases/download/${VERSION}/libwebp-${VERSION}-framework-${3}-webp.zip"

# Move to project folder
cd ${FOLDER}

# If the folder is empty, download a copy of the framework and install
if [ ! "$(ls $FRAMEWORK)" ]; then
    curl -L -sS ${URL} > framework.zip
    unzip framework.zip
    cp -a libwebp*/${FRAMEWORK}/. ${FRAMEWORK}/
    rm -r libwebp*/
    rm framework.zip
fi
