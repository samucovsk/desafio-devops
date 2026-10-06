#!/bin/bash
set -o pipefail


limpar_ambiente(){
    echo -e "\nRemovendo dependencias\n"
    docker compose down 
    echo -e "\nRemocendo container da aplicação\n"
    docker stop teste-script
    docker rm teste-script
    echo -e "Fim."
}


REPO=$REPO
# read -p "Digite a tag da imagem: " TAG
IMAGE="$REPO:$TAG"

docker login -p $PASSWORD -u $USERNAME --password-stdin

docker manifest inspect $IMAGE > /dev/null 
TAG_EXIST=$?

if [ "$TAG_EXIST" == 0 ]; then
    echo -e "\nA imagem já existe no Docker Hub. Pulando o build.\n"
    exit 1
else
    echo -e "\nA imagem não existe no Docker Hub. Continuando o build.\n"
    
    docker build -t $IMAGE .
    

    echo -e "\nSubindo dependencias\n"
    docker compose up -d redis mongo

    echo -e "\nSubindo container da aplicação\n"
    docker run -d --name teste-script --network desafio_default -e REDIS_URL=redis://redis:6379 -e MONGO_URL=mongodb://mongo:27017 $IMAGE
    sleep 5

    HEALTHY=$(docker exec teste-script sh -c "wget -qO- http://127.0.0.1:5000/health_redis")
        if [ "$HEALTHY" == '{"mongodb":"connected","redis":"connected","status":"healthy"}' ]; then
            echo -e "\nContainer de teste saúdavel! dando push na imagem.\n" 
            docker push $IMAGE
        else
            echo -e "\nHealthcheck falhou. Interrompendo o push.\n"
            limpar_ambiente
            exit 1
        fi
    limpar_ambiente
fi

