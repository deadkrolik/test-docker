#!/usr/bin/env bash
sudo docker run --name music -p 8080:80 -p 8022:22 -d -v /home/alex/docker:/var/www arg/php7-phalcon:v2
