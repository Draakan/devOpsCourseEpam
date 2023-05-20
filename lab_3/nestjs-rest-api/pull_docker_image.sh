#!/bin/bash

image_name=draakan/nestjs-web-app:v1.0.0

docker pull $image_name
docker run -p 3000:3000 $image_name