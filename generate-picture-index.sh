#!/bin/bash

set -e

BIN="$(cd "$(dirname "$0")" ; pwd)"

source "${BIN}/lib-verbose.sh"
source "${BIN}/lib-sed.sh"

if [[ "$#" -lt 1 ]]
then
  set -- '.'
fi

for D in "$@"
do
  log "Directory: [${D}]"
done

BASE_DIR="$(pwd)"

function docker-djpeg() {
  docker run --rm -v "${BASE_DIR}:${BASE_DIR}" -w "${BASE_DIR}" zarmin/imageoptimizer djpeg "$@"
}

function docker-cjpeg() {
  docker run --rm -v "${BASE_DIR}:${BASE_DIR}" -w "${BASE_DIR}" zarmin/imageoptimizer cjpeg "$@"
}

function docker-netpbm() {
  docker run --rm -v "${BASE_DIR}:${BASE_DIR}" -w "${BASE_DIR}" mapsherpa/ubuntu-build "$@"
}

## TAB="$(echo -n -e '\t')"

tee style.css > /dev/null <<EOT
img {
  border: 2px solid white;
}
img:hover {
  border: 2px solid black;
}
.float-box {
    position: fixed;
    bottom: 10px;
    right: 10px;
    background: yellow;
    border: 2px solid black;
    padding: 5px;
}
.fixed-width {
    width: 475px;
}
.fixed-height {
    height: 600px;
}
.hidden {
    display: none;
}
EOT

tee gallery.js > /dev/null <<EOT
function clickOnImage(event) {
    const imagePath = event.target.getAttribute('title');
    console.log('Click on image:', imagePath);
    if (imagePath){
        const selectedImage = document.getElementById('selected-image');
        selectedImage.setAttribute('src', imagePath);
        const imageLabel = document.getElementById('image-label');
        imageLabel.innerHTML = imagePath;
        const innerBox = document.getElementById('inner-box');
        innerBox.className = '';
    }
}
function toggleInnerBox(event) {
    const innerBox = document.getElementById('inner-box');
    const oldClass = innerBox.className;
    console.log('Class of inner box:', oldClass);
    if (oldClass === 'hidden') {
        innerBox.className = '';
    } else {
        innerBox.className = 'hidden';
    }
}
function toggleFixedAspect(event) {
    const image = document.getElementById('selected-image');
    const oldClass = image.className;
    if (oldClass === 'fixed-width') {
        image.className = 'fixed-height';
    } else {
        image.className = 'fixed-width';
    }
}
function onLoad() {
    console.log("On load event handler")
    const toggle = document.getElementById('toggle');
    toggle.onclick = toggleInnerBox
    const aspectToggle = document.getElementById('aspect-toggle');
    aspectToggle.onclick = toggleFixedAspect
    const collection = document.getElementsByTagName("img");
    var l = collection.length;
    for (var i = 0; i < l; i++) {
        var image = collection[i];
        console.log('Image:', image.getAttribute('title'));
        image.onclick = clickOnImage;
    }
}
EOT

exec > index.html

cat <<EOT
<html>
<head>
  <title>Image gallery</title>
  <link rel="stylesheet" href="style.css"/>
  <script type="text/javascript" src="gallery.js"></script>
</head>

<body onload="onLoad()">

<div class='float-box'><div id='inner-box' class='hidden'><span id='image-label'>XXX</span><br/><image id='selected-image' class='fixed-width' src='#'/></div><span id='toggle'>^</span> <span id='aspect-toggle'>@</span></div>

EOT

find "$@" -type f \( -name '*.jpg' -o -name '*.png' \) \! -name picture.png -print \
  | sed "${SED_EXT}" \
      -e 's:^./::' \
      -e 's/^/%/' \
      -e 's/^%((.*\/)?(T1-)?)([0-9]{4}-[0-9]{2}-[0-9]{2})([^0-9])/\4%\1\4\5/' \
      -e 's/^%((.*\/)?(T1-|IMG_|PANO_)?)([0-9]{4})([0-9]{2})([0-9]{2})/\4-\5-\6%\1\4\5\6/' \
      -e 's/%/ /' \
  | sort -r \
  | while read D F
    do
      EXT="$(expr "+${F}" : '.*[.]\([^.]*\)$')"
      if [[ -n "${EXT}" ]]
      then
        EXT_LC="$(echo "${EXT}" | tr 'A-Z' 'a-z')"
        DERIVED="$(dirname "${F}")/$(basename "${F}" ".${EXT}")"
        if [[ -f "${DERIVED}/picture.png" ]]
        then
          log "Thumbnail exists for [${F}]"
        else
          mkdir -p "${DERIVED}"
          case "${EXT_LC}" in
          png)
            log "PNG: [${F}] -> [${DERIVED}/*]"
            docker-netpbm pngtopnm "${F}" > "${DERIVED}/bitmap.ppm"
            docker-netpbm pnmscale -height=200 "${DERIVED}/bitmap.ppm" > "${DERIVED}/bitmap-small.ppm"
            docker-netpbm pnmtopng "${DERIVED}/bitmap-small.ppm" > "${DERIVED}/picture.png"
            ;;
          jpg)
            log "JPEG: [${F}] -> [${DERIVED}/*]"
            docker-djpeg "${F}" > "${DERIVED}/bitmap.ppm"
            docker-netpbm pnmscale -height=200 "${DERIVED}/bitmap.ppm" > "${DERIVED}/bitmap-small.ppm"
            docker-netpbm pnmtopng "${DERIVED}/bitmap-small.ppm" > "${DERIVED}/picture.png"
            ;;
          esac
          rm -f "${DERIVED}"/bitmap*
        fi
        echo "<img src='${DERIVED}/picture.png' height='200' title='${F}'/>"
      fi
    done

echo ''
echo '</body>'