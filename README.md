#php-nginx-mysql-centos docker image
>php    version: 5.5.38<br>
>nginx  version: 1.7.8<br>
>mysql  version: 5.5.52<br>
>centos version: 6.6<br>

#install docker service
```
yum install -y  docker-io
service docker start
```

#build dockerfile
```
cd $path/php-nginx-mysql-centos/
docker build -f ./Dockerfile -t php-nginx-mysql-centos:1.0 ./
```

#run a container from the docker image
```
docker run -t -i -p 127.0.0.1:80:80 --name lnmp-centos $image_id
```
Then you can visit url http://127.0.0.1/index.php

#excute a interactive shell on the running container
```
docker exec -ti $container_name bash
```
