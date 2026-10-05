#!/bin/bash

read -p "Digite a tag da imagem: " TAG

docker manifest inspect samucovsk/desafio-devsecops:$TAG > /dev/null 
TAG_EXIST=$?

if [ "$TAG_EXIST" == 0 ]; then
    echo "A imagem já existe no Docker Hub. Pulando o build."
    exit 0
else
    echo "A imagem não existe no Docker Hub. Continuando o build."
    docker build -t samucovsk/desafio-devsecops:$TAG .
    docker push samucovsk/desafio-devsecops:$TAG
fi