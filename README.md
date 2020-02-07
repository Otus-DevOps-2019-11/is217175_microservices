# is217175_microservices
## doker-2
<details>
1. Установлена программа *docker-machine* и настроено создание виртуальной машины с *docker* в *GCP*
2. С помощью написанного [Dockerfile](docker-monolith/Dockerfile) собрал образ
```
$ docker image history is217175/otus-reddit:1.0
IMAGE               CREATED             CREATED BY                                      SIZE
a39a9add1cbb        25 hours ago        /bin/sh -c #(nop)  CMD ["/start.sh"]            0B
<missing>           25 hours ago        /bin/sh -c chmod 0777 /start.sh                 146B
<missing>           25 hours ago        /bin/sh -c cd /reddit && bundle install         46.1MB
<missing>           25 hours ago        /bin/sh -c #(nop) COPY file:54cff94402213cfe…   146B
<missing>           25 hours ago        /bin/sh -c #(nop) COPY file:2839de850f5b24a6…   23B
<missing>           25 hours ago        /bin/sh -c #(nop) COPY file:aaad2ee53af2f98d…   191B
<missing>           25 hours ago        /bin/sh -c git clone -b monolith https://git…   115kB
<missing>           25 hours ago        /bin/sh -c gem install bundler                  3.28MB
<missing>           25 hours ago        /bin/sh -c apt-get install -y mongodb-server…   494MB
<missing>           25 hours ago        /bin/sh -c apt-get update                       25.8MB
<missing>           2 weeks ago         /bin/sh -c #(nop)  CMD ["/bin/bash"]            0B
<missing>           2 weeks ago         /bin/sh -c mkdir -p /run/systemd && echo 'do…   7B
<missing>           2 weeks ago         /bin/sh -c set -xe   && echo '#!/bin/sh' > /…   745B
<missing>           2 weeks ago         /bin/sh -c rm -rf /var/lib/apt/lists/*          0B
<missing>           2 weeks ago         /bin/sh -c #(nop) ADD file:4b2eb5cd0b37ca015…   124MB
```

3. Получившийся образ был выгружен в репозиторий Docker Hub - https://hub.docker.com/repository/docker/is217175/otus-reddit
4. Дополнительно были созданы:
- Шаблон *packer* для сборки виртуальной машины с установленным *docker*. Провижин осуществляется при помощи сценария *ansible* [docker.yml](docker-monolith/infra/ansible/docker.yml).
- Шаблон *terraform* для создания инфраструктуры в *GCP* - виртуальных машин из собранного образа и правила для фаервола для работы приложения.
- Сценария *ansible* [run_image.yml](docker-monolith/infra/ansible/run_image.yml) для установки и запуска экземпляра приложения на каждой из созданных виртуальных машин.
- Инвентори *ansible* динамический с плагином *gcp_compute*.
</details>

## dcoker-3
1. Для сервисов приложения *comment*, *post* и *ui* были созданы *Dockerfile* для сборки
```
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
is27175/ui          1.0                 ed6e009f2bbb        11 seconds ago      784MB
is27175/comment     1.0                 b34dbe0c698e        54 seconds ago      782MB
is27175/post        1.0                 109f30e70216        2 minutes ago       110MB
mongo               latest              8e89dfef54ff        9 days ago          386MB
ubuntu              16.04               96da9143fb18        3 weeks ago         124MB
ruby                2.2                 6c8e6f9667b2        21 months ago       715MB
ruby                2.2-alpine          d212148e08f7        22 months ago       107MB
python              3.6.0-alpine        cb178ebbf0f2        2 years ago         88.6MB
```
2. Создал общую сеть для контейнеров приложения `docker network create reddit`
3. Создал *volume* для базы данных, чтобы данные сохранялись при перезапуске контейнера `docker volume create reddit_db`
4. Запуск контейнеров:
```
$ docker run -d --network=reddit --network-alias=db -v reddit_db:/data/db mongo:latest
$ docker run -d --network=reddit --network-alias=post_service -e POST_DATABASE_HOST=db is217175/post:1.0
$ docker run -d --network=reddit --network-alias=comment_service -e COMMENT_DATABASE_HOST=db is217175/comment:1.0
$ docker run -d -p 9292:9292 -e COMMENT_SERVICE_HOST=comment_service -e POST_SERVICE_HOST=post_service --network=reddit is217175/ui:2.0
```
Каждому сервису присвоен сетевой псевдоним опцией `--network-alias=...`, чтобы они могли взаимодействовать по сети. Так контейнеру с базой *mongodb* присвоен псевдоним *db*, сервису комментариев - *comment_service*, сервису постов - *post_service*. Чтобы все все контейнеры знали новые псевдонимы, их имена передаются переменными окружения с опицей `-e VAR=VALUE`
```
$ docker ps
CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS              PORTS                    NAMES
e9e725e217b0        is217175/ui:2.0        "puma"                   6 minutes ago       Up 5 minutes        0.0.0.0:9292->9292/tcp   suspicious_mclean
ceba8ef26e0c        is217175/comment:1.0   "puma"                   6 minutes ago       Up 6 minutes                                 thirsty_knuth
3df42256e1d6        is217175/post:1.0      "python3 post_app.py"    6 minutes ago       Up 6 minutes                                 strange_edison
cb93cb96077f        mongo:latest           "docker-entrypoint.s…"   6 minutes ago       Up 6 minutes        27017/tcp                admiring_golick
```
5. Для уменьшения размеров образов применил метод поэтапной cборки *Dockerfile* (тег 2.0 для сервиса *post*, 3.0 - *ui*, 2.0 - *comment*):
```
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
is217175/post       2.0                 727000af4f80        14 minutes ago      78MB
is217175/post       1.0                 109f30e70216        26 hours ago        110MB
...
is217175/ui         3.0                 1f2de9005fcf        19 hours ago        44.5MB
is217175/ui         2.0                 e203527390ed        22 hours ago        459MB
...
is217175/comment    2.0                 f33965e17c63        19 hours ago        42MB
is217175/comment    1.0                 b34dbe0c698e        26 hours ago        782MB
```
