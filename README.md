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

## docker-3
<details>
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
</details>

## docker-4
<details>
1. Установил *docker-compose*
2. Протестировал создание различные типы сетей в *docker*: *none*, *host*, *bridge*.
3. Распределил контейнера приложения по нескольким сетям:
- в *back_net* - *post_db*, *comment*, *post*
- в *front_net* - *ui*, *comment*, *post*
4. Написан [docker-compose.yml](src/docker-compose.yml). Контейнера разнесены по сетям из п.п.3, параметризованы с помощью переменных окружения параметры порт для публикации приложения, версия образов, имя пользователя из репозитория в файле [.env](src/.env.example)
5. Префикс для имени запущенного контейнера задал через переменную окружения *COMPOSE_PROJECT_NAME* в файле [.env](src/.env.example)
6. С помощью файла [docker-compose.override.yml](src/docker-compose.override.yml) переопределил команду для запуска сервера *puma*, а также для всех проектов папка с кодом приложения монтируется в */app* контейнера.

```
$ docker-compose ps
      Name                    Command              State           Ports
---------------------------------------------------------------------------------
reddit_comment_1   puma -w 2 --debug               Up
reddit_post_1      /pyenv/bin/python post_app.py   Up
reddit_post_db_1   docker-entrypoint.sh mongod     Up      27017/tcp
reddit_ui_1        puma -w 2 --debug               Up      0.0.0.0:9292->9292/tcp
```
</details>

## gitlab-ci-1
1. С помощью *docker-machine* создан экземпляр виртуальной машины в *GCP*.
2. На сервер установлен *Gitlab CI* `docker-compose up -d` [docker-compose.yml](gitlab-ci/docker-compose.yml).
3. В *Gitlab CI* был создан проект *homework* и репозиторий в нем *exmaple*
4. *CI/CD Pipeline* настроивается файлом [.gitlab-ci.yml](.gitlab-ci.yml).
5. Запущен и подключен *runner*.
```
docker run -d --name gitlab-runner --restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gitlab/gitlab-runner:latest

docker exec -it gitlab-runner gitlab-runner register --non-interactive --tag-list "linux,xenial,ubuntu,docker" --run-untagged=true --locked=false --name "my-runner" --url="http://12.34.56.78/" --registration-token "GjJjfhj*jkhfj_8" --executor "docker" --docker-image alpine:latest --docker-volumes "/var/run/docker.sock:/var/run/docker.sock"
```
Определены стадии *build*, *test*, *review* и соответсвующие задачи для них. Теперь при коммите в репозиторий автоматический запускается конвейер для сборки, тестирования и установки сервиса.
6. Определены окружения *dev*, *stage*, *production*. Окружения stage и production запускаются вручную только для коммитов с тегом (номер версии прилоджения)
```
...
when: manual
only:
    - /^\d+\.\d+\.\d+/
...
```
7. Определено динамически создаваемое окружение, в зависимости от ветки (кроме ветки master). Для этого используется переменная окружения *CI_COMMIT_REF_NAME*
```
branch review:
  stage: review
  script: echo "Deploy to $CI_ENVIRONMENT_SLUG"
  environment:
    name: branch/$CI_COMMIT_REF_NAME
    url: http://$CI_ENVIRONMENT_SLUG.example.com
  only:
    - branches
  except:
    - master
```
8. В шаг *build* добавлена сборка приложения:
```
build_job:
  image: docker:19.03.1
  before_script:
    - docker info
  stage: build
  script:
    - echo 'Building...'
    - cd reddit/
    - docker build -t reddit:$CI_COMMIT_SHORT_SHA .
```
На *runner* запускается *docker* контейнер, в котором происходит сборка приложения с использованием [Dockerfile](reddit/Dockerfile). Собранному контейнеру присваивается тег *CI_COMMIT_SHORT_SHA* (укороченный хеш последнего коммита).

В *build_job* можно еще добавить загрузку полученного образа в *docker registry*. Но так как разворачивать приложение я буду на этом же сервере, то образ сразу будет доступен.
9. Приложение разворачивается в окружении *dev*:
```
deploy_dev_job:
  image: docker:19.03.1
  stage: review
  before_script:
    - echo "Cleanup previous containers..."
    - docker stop reddit_$CI_ENVIRONMENT_SLUG || true
    - docker stop mongo_$CI_ENVIRONMENT_SLUG || true
    - docker network rm reddit_net_$CI_ENVIRONMENT_SLUG || true
  script:
    - "Deploying..."
    - docker network create reddit_net_$CI_ENVIRONMENT_SLUG
    - docker run --rm -d --name mongo_$CI_ENVIRONMENT_SLUG --network=reddit_net_$CI_ENVIRONMENT_SLUG --network-alias=$DATABASE_URL mongo:latest
    - docker run --rm -d --name reddit_$CI_ENVIRONMENT_SLUG -p 9292:9292 --network=reddit_net_$CI_ENVIRONMENT_SLUG -e DATABASE_URL=$DATABASE_URL reddit:$CI_COMMIT_SHORT_SHA
  environment:
    name: dev
    url: "http://$CI_SERVER_HOST:9292"
    on_stop: stop_deploy_dev
```
Для работы приложения дополнительно должен быть запущен контейнер с базой *mongodb*, создана сеть и определен псевдоним для подключения приложения к базе. В секции `before_script:` определены команды для очистки результатов предыдущего разворачивания. Если *deploy_dev_job* выполняется успешно, то по ссылке http://$CI_SERVER_HOST:9292 можно проверить работу приложения.

В случае остановки окружения определена задача *stop_deploy_dev*. При ее выполнении удаляются контейнеры и сеть, созданные при разворачивании.
```
stop_deploy_dev:
  image: docker:19.03.1
  stage: review
  variables:
    GIT_STRATEGY: none
  before_script:
    - echo "Destroying environment"
  script:
    - docker stop reddit_$CI_ENVIRONMENT_SLUG
    - docker stop mongo_$CI_ENVIRONMENT_SLUG
    - docker network rm reddit_net_$CI_ENVIRONMENT_SLUG
  when: manual
  environment:
    name: dev
    action: stop
```
10. Для автоматизации развертывания *gitlab-runner*:
- Создан шаблон *packer* - [gitlab-runner.json](gitlab-ci/packer/gitlab-runner.json). Сценарий *ansible* [packer.yml](gitlab-ci/ansible/packer.yml) устанавливает *docker* и *gitlab-runner* из официальных репозиториев.
- Шаблон [terraform](gitlab-ci/terraform/) запускает необходимое количество виртуальных машин с вышеуказанным образом. Количество задается переменной *count*. Всем машинам присваивается метка *ansible_group: runners*.
- Создан сценарий [gitlab-runner_register.yml](gitlab-ci/ansible/gitlab-runner_register.yml), который регистрирует виртуальные машины на gitlab сервере. Использовано динамическое инвентори. Сценарий применяется только к группе *runners*. Регистрационный, администраторский токены указаны в групповых переменных [runners.yml](gitlab-ci/ansible/group_vars/runners.yml) (для наглядности не шифровал).
11. Уведомления о событиях приходят на мой канал в Slack https://devops-team-otus.slack.com/archives/CS7GWPFQD
