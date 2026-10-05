#!/bin/bash

TAG=v1.0.0
docker manifest inspect samucovsk/desafio-devsecops:$TAG > /dev/null 
TAG_EXIST=$?

if [ "$TAG_EXIST" == 0 ]; then
    echo "A imagem já existe no Docker Hub. Pulando o build."
    exit 0
else
    echo "A imagem não existe no Docker Hub. Continuando o build."
fi