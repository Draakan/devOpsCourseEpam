#!/bin/bash

image_name=draakan/nestjs-web-app:v1.0.0

docker build . -t $image_name
docker push $image_name

echo "successful"