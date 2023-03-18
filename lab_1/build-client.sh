#!/bin/bash

npm install

if [ "$ENV_CONFIGURATION" = "production" ]; then
  npm run build -- --configuration=production
else
  npm run build
fi

export ENV_CONFIGURATION="${ENV_CONFIGURATION:-development}"

buildPath=dist/client-app.zip

if [ -f $buildPath ]; then
  rm $buildPath
fi

zip -r $buildPath dist/*

echo "Build completed!"
