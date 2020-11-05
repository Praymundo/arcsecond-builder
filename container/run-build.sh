#!/bin/bash

set -ex

if [[ ${EUID} -eq 0 ]]; then
    echo "This script must NOT be run as root"
    exit 1
fi

BUILDER_DIR=/tmp/builder
DIST_DIR=/dist
ENTRY_FILENAME=Arcsecond.js
CONFIG_FILENAME=webpack.config.js

mkdir -p "${BUILDER_DIR}"
git clone "https://github.com/francisrstokes/arcsecond.git" "${BUILDER_DIR}"

cat << EOF > "${BUILDER_DIR}/${ENTRY_FILENAME}"
const _Arcsecond = require('./index.mjs');
self.Arcsecond = _Arcsecond;
EOF

cat << EOF > "${BUILDER_DIR}/${CONFIG_FILENAME}"
const webpack = require("webpack");
module.exports = {
  "entry": {
    "Arcsecond": "./${ENTRY_FILENAME}"
  },
  "output": {
    "filename": "[name].js"
  }
};
EOF

cd "${BUILDER_DIR}" && npm install && npm install --save-dev webpack webpack-cli && npx webpack --config "${CONFIG_FILENAME}"

cp -f "${BUILDER_DIR}/dist/Arcsecond.js" "${DIST_DIR}"

