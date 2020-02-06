# is217175_microservices
## Doker-2
1. Установлена программа *docker-machine* и настроено создание виртуальной машины с *docker* в *GCP*
2. С помощью написанного [Dockerfile](docker-monolith/Dockerfile) собрал образ
```
$ docker image history is217175/otus-reddit:1.0
IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
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
