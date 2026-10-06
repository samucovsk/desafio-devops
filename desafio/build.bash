#!/bin/bash


limpar_ambiente(){
    echo -e "\nRemovendo dependencias\n"
    docker compose down 
    echo -e "\nRemocendo container da aplicação\n"
    docker stop teste-script
    docker rm teste-script
    echo -e "Fim."
}
# check if version.txt file exist, otherwise create one and store initial version
   if [ ! -f version.txt ]; then echo "1.0" > version.txt
   fi
# declare a variable to store current version
   CURRENT_VERSION=$(<version.txt)
# create a new version
   UPDATED_VERSION=$(echo "$CURRENT_VERSION + 0.1" | bc)
# write new version back to file
   echo "$UPDATED_VERSION" > version.txt
# then build docker image with new version


REPO=$REPO
# read -p "Digite a tag da imagem: " TAG
IMAGE="$REPO:$UPDATED_VERSION"

docker login -p $PASSWORD -u $USERNAME

docker manifest inspect $IMAGE > /dev/null 
TAG_EXIST=$?

if [ "$TAG_EXIST" == 0 ]; then
    echo -e "\nA imagem já existe no Docker Hub. Pulando o build.\n"
    exit 0
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
            exit 0
        fi
    limpar_ambiente
fi

