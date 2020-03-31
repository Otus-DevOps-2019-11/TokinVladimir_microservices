# TokinVladimir_microservices
TokinVladimir microservices repository

#### Домашнее задание 22. Введение в Kubernetes

### План

* Разобрать на практике все компоненты Kubernetes, развернуть их вручную используя The Hard Way;
* Ознакомиться с описанием основных примитивов нашего приложения и его дальнейшим запуском в Kubernetes.

В качестве домашнего задания предлагается пройти разработанный инженером Google Kelsey Hightower Туториал представляет собой:
Пошаговое руководство по ручной инсталляции основных компонентов Kubernetes кластера;
Краткое описание необходимых действий и объектов.

#### Домашнее задание 21. Логирование и распреде распределенная трассировка

### План

* Сбор неструктурированных логов
* Визуализация логов
* Сбор структурированных логов
* Распределенная трасировка

Используем EFK (ElasticSearch, Fluentd, Kibana)

#### Домашнее задание 20. Мониторинг приложения и инфраструктуры.

### План

* Мониторинг Docker контейнеров
* Визуализация метрик
* Сбор метрик работы приложения и бизнес метрик
* Настройка и проверка алертинга
* Много заданий со ⭐ (необязательных)

Создадим docker-сети
```
docker network create back_net --subnet=10.0.2.0/24
docker network create front_net --subnet=10.0.1.0/24
docker network create prom_net --subnet=10.0.3.0/24
```

Оставим описание приложений в docker-compose.yml, а мониторинг выделим в отдельный файл docker-composemonitoring.yml.

cAdvisor также будем запускать в контейнере.

Используем инструмент Grafana для визуализации данных из Prometheus. Добавим новый сервис в docker-compose-monitoring.yml.

Alertmanager - дополнительный компонент для системы мониторинга Prometheus, который отвечает за первичную обработку алертов и дальнейшую отправку оповещений по заданному назначению.

Настроили алерты в тестовый канал слака.

https://hub.docker.com/u/ress72

#### Домашнее задание 19. Введение в мониторинг. Системы мониторинга.

### План

* Prometheus: запуск, конфигурация, знакомство с Web UI
* Мониторинг состояния микросервисов
* Сбор метрик хоста с использованием экспортера
* Задания со *

Создадим правило фаервола для Prometheus и Puma:

```
gcloud compute firewall-rules create prometheus-default --allow tcp:9090
gcloud compute firewall-rules create puma-default --allow tcp:9292
```
Создадим Docker хост в GCE и настроим локальное окружение на работу с ним

```
export GOOGLE_PROJECT=_ваш-проект_

# create docker host
docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-zone europe-west1-b \
    docker-host

# configure local env
eval $(docker-machine env docker-host)

docker run --rm -p 9090:9090 -d --name prometheus  prom/prometheus

docker-machine ip docker-host
```
Вся конфигурация Prometheus, в отличие от многих других систем мониторинга, происходит через
файлы конфигурации и опции командной строки. Мы определим простой конфигурационный файл
для сбора метрик с наших микросервисов

```
#prometheus.yml
---
global:
  scrape_interval: '5s'

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets:
        - 'localhost:9090'

  - job_name: 'ui'
    static_configs:
      - targets:
        - 'ui:9292'

  - job_name: 'comment'
    static_configs:
      - targets:
        - 'comment:9292'
```

Будем поднимать наш Prometheus совместно с микросервисами. Определите в вашем docker/docker-compose.yml файле новый сервис.

Самостоятельно добавьте секцию networks в определение сервиса Prometheus в docker/dockercompose.yml.

```
#docker-compose.yml
version: '3.3'
services:
  post_db:
    image: mongo:${DB_VER}
    volumes:
      - post_db:/data/db
    networks:
      - back_net
  ui:
    image: ${USERNAME}/ui:${UI_VER}
    ports:
      - ${PORT_SRC}:${PORT_DST}/${PROTOCOL}
    container_name: ui_prowerka
    networks:
      - front_net
  post:
    image: ${USERNAME}/post:${POST_VER}
    networks:
      - front_net
      - back_net
  comment:
    image: ${USERNAME}/comment:${COMMENT_VER}
    networks:
      - front_net
      - back_net
  prometheus:
    image: ${USERNAME}/prometheus
    networks:
      - front_net
      - back_net
    ports:
      - '9090:9090'
    volumes:
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention=1d'

volumes:
  post_db:
  prometheus_data:

networks:
  front_net:
    external: true
  back_net:
    external: true
```

### Мониторинг состояния микросервисов

## Healthcheck-и представляют собой проверки того, что наш сервис здоров и работает в ожидаемом режиме.

У меня ui_health и ui_health_comment_availability значения были 0, и график не строился.
Изменил #docker-compose.yml, добавил aliases

```
  post_db:
    image: mongo:${DB_VER}
    volumes:
      - post_db:/data/db
    networks:
      back_net:
        aliases:
          - post_db
          - comment_db
```

## Exporters - Экспортер похож на вспомогательного агента для сбора метрик.

В ситуациях, когда мы не можем реализовать отдачу метрик Prometheus в коде приложения, мы
можем использовать экспортер, который будет транслировать метрики приложения или системы в
формате доступном для чтения Prometheus.

## Exporters

* Программа, которая делает метрики доступными для сбора Prometheus
* Дает возможность конвертировать метрики в нужный для Prometheus формат
* Используется когда нельзя поменять код приложения
* Примеры: PostgreSQL, RabbitMQ, Nginx, Node exporter, cAdvisor

## Node exporter

```
#docker-compose.yml
services:

  node-exporter:
    image: prom/node-exporter:v0.15.2
    user: root
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points="^/(sys|proc|dev|host|etc)($$|/)"'
```
Добавим еще один job:

```
scrape_configs:
...
 - job_name: 'node'
 static_configs:
 - targets:
 - 'node-exporter:9100'
```

https://hub.docker.com/u/ress72



#### Домашнее задание 18. Устройство Gitlab CI. Построение процесса непрерывной поставки

### План

* Подготовить инсталляцию Gitlab CI
* Подготовить репозиторий с кодом приложения
* Описать для приложения этапы пайплайна
* Определить окружения

```
> git checkout -b gitlab-ci-1
> git remote add gitlab http://<your-vm-ip>/homework/example.git
> git push gitlab gitlab-ci-1
```



#### Домашнее задание 17. Docker -4. Docker: сети, docker-compose

### План

* Работа с сетями в Docker
 * none
 * host
 * bridge

```
docker network create reddit --driver bridge
```

```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post <your-dockerhub-login>/post:1.0
docker run -d --network=reddit --network-alias=comment  <your-dockerhub-login>/comment:1.0
docker run -d --network=reddit -p 9292:9292 <your-dockerhub-login>/ui:1.0
```

Создадим docker сети

```
docker network create back_net --subnet=10.0.2.0/24
docker network create front_net --subnet=10.0.1.0/24
```

```
docker run -d --network=front_net -p 9292:9292 --name ui  <your-dockerhub-login>/ui:1.0
docker run -d --network=back_net --name comment  <your-dockerhub-login>/comment:1.0
docker run -d --network=back_net --name post  <your-dockerhub-login>/post:1.0
docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db mongo:latest
```

Подключим контейнеры ко второй сети

```
docker network connect front_net post
docker network connect front_net comment
```

* Использование docker-compose
 * Установить docker-compose на локальную машину
 * Собрать образы приложения reddit с помощью docker-compose
 * Запустить приложение reddit с помощью dockercompose

docker-compose -
• Отдельная утилита
• Декларативное описание docker-инфраструктуры в YAMLформате
• Управление многоконтейнерными приложениями

Установка

```
 pip install docker-compose
```

Задание:
1) Изменить docker-compose под кейс с множеством сетей, сетевых алиасов (стр 18).
2) Параметризуйте с помощью переменных окружений:
• порт публикации сервиса ui
• версии сервисов
• возможно что-либо еще на ваше усмотрение
3) Параметризованные параметры запишите в отдельный файл c расширением .env
4) Без использования команд source и export
docker-compose должен подхватить переменные из этого файла. Проверьте
P.S. Файл .env должен быть в .gitignore, в репозитории закоммичен .env.example, из
которого создается .env

```
docker-compose.yml
version: '3.3'
services:
  post_db:
    image: mongo:${DB_VER}
    volumes:
      - post_db:/data/db
    networks:
      - back_net
  ui:
    build: ./ui
    image: ${USERNAME}/ui:${UI_VER}
    ports:
      - ${PORT_SRC}:${PORT_DST}/${PROTOCOL}
    container_name: ui_prowerka
    networks:
      - front_net
  post:
    build: ./post-py
    image: ${USERNAME}/post:${POST_VER}
    networks:
      - front_net
      - back_net
  comment:
    build: ./comment
    image: ${USERNAME}/comment:${COMMENT_VER}
    networks:
      - front_net
      - back_net

volumes:
  post_db:

networks:
  front_net:
    external: true
  back_net:
    external: true
```

Задание:
Узнайте как образуется базовое имя проекта. Можно ли его задать? Если можно то как?

Базовое имя проекта можно изменить директивой container_name

```
container_name: ui_prowerka
```

Задание со *

Создайте docker-compose.override.yml для reddit проекта, который позволит
• Изменять код каждого из приложений, не выполняя сборку образа
• Запускать puma для руби приложений в дебаг режиме с двумя воркерами (флаги --debug и -w 2)

```
version: '3.3'

services:
  ui:
    volumes:
      - ui:/app
    command: puma --debug -w 2

  comment:
    volumes:
      - comment:/app

  post:
    volumes:
      - post-py:/app

volumes:
  ui:
  comment:
  post-py
```


Домашнее задание 16. Docker -3. Docker-образы. Микросервисы

План:
• Разбить наше приложение на несколько компонентов
• Запустить наше микросервисное приложение

docker-machine ls
eval $(docker-machine env docker-host)

Задание со *
Запустите контейнеры с другими сетевыми алиасами
Адреса для взаимодействия контейнеров задаются через ENV-переменные внутри Dockerfile'ов
При запуске контейнеров (docker run) задайте им переменные окружения соответствующие новым сетевым алиасам, не пересоздавая образ
Проверьте работоспособность сервиса

Изменили сетевые алиасы, сервис не работает, пишет про проблемы с бд
Добавили к запуску контейнера переменную –env POST_DATABASE_HOST=post_db_new (к примеру) и сервис заработал

Подключим volume к БД
docker volume create reddit_db
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest

Задание со *
• Попробуйте собрать образ на основе Alpine Linux
Выполнено: FROM ruby:2.7.0-alpine3.11
После установки пакетов надо бы их удалить, для этого использовал --virtual .имя apk del .имя
Так же вынес строку RUN bundle install в структуру с RUN apk add --no-cache --virtual .имя

docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
ress72/ui           4.0                 4713083e262b        11 minutes ago      104MB
ress72/comment      3.0                 2240234a4278        17 minutes ago      102MB
<none>              <none>              358f8b315ae1        21 minutes ago      102MB
<none>              <none>              99baa07c028d        24 minutes ago      102MB
<none>              <none>              6e3f3cdb3cac        26 minutes ago      101MB
<none>              <none>              95413a07c0ca        31 minutes ago      274MB
ress72/comment      2.0                 040f5bc59b50        53 minutes ago      274MB
<none>              <none>              d15198a54ae6        56 minutes ago      228MB
ress72/ui           3.0                 1d3f3aac9d21        About an hour ago   277MB
<none>              <none>              6661e1741b6d        About an hour ago   77.3MB
ress72/ui           2.0                 cdf4c975b00a        2 hours ago         459MB
ress72/ui           1.0                 52a1f9ffec51        3 hours ago         784MB
ress72/comment      1.0                 c3ef265e1716        3 hours ago         782MB
ress72/post         1.0                 c020654ffb5e        3 hours ago         110MB

Уменьшены размеры ui и comment почти в 7 раз


Домашнее задани 15. Docker-2. Технология контейнеризации. Введение в Docker.

План:

• Создание docker host
• Создание своего образа
• Работа с Docker Hub

Установка docker:

sudo apt-get update
sudo apt-get install     apt-transport-https     ca-certificates     curl     gnupg-agent     software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add –
sudo add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/ubuntu   $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker USER (Пользователя надо добавить в группу docker, иначе действия с docker придется делать от sudo)

Список запущенных контейнеров
docker ps
Список всех контейнеров
docker ps -a
Список сохранненных образов
docker images
Команда run создает и запускает контейнер из image
docker run -it ubuntu:16.04 /bin/bash # пример
Docker run каждый раз запускает новый контейнер, если не указывать флаг --rm при запуске docker run, то после остановки контейнер вместе с содержимым остается на диске
start запускает остановленный(уже созданный) контейнер
attach подсоединяет терминал к созданному контейнеру
> docker start <u_container_id>
> docker attach <u_container_id>
ENTER
Ctrl + p, Ctrl + q
docker run = docker create + docker start + docker attach*
docker create используется, когда не нужно стартовать контейнер сразу
в большинстве случаев используется docker run * при наличии опции –i
Через параметры передаются лимиты(cpu/mem/disk), ip, volumes
 • -i – запускает контейнер в foreground режиме (docker attach)
 • -d – запускает контейнер в background режиме
 • -t создает TTY
• docker run -it ubuntu:16.04 bash
• docker run -dt nginx:latest
Docker exec Запускает новый процесс внутри контейнера
Например, bash внутри контейнера с приложением
Docker commit Создает image из контейнера, Контейнер при этом остается запущенным
Docker kill & stop
• kill сразу посылает SIGKILL
• stop посылает SIGTERM, и через 10 секунд(настраивается) посылает SIGKILL
• SIGTERM - сигнал остановки приложения
• SIGKILL - безусловное завершение процесса
docker system df
• Отображает сколько дискового пространства занято образами, контейнерами и volume’ами
• Отображает сколько из них не используется и возможно удалить
Docker rm & rmi
• rm удаляет контейнер, можно добавить флаг -f, чтобы удалялся работающий container(будет послан sigkill)
• rmi удаляет image, если от него не зависят запущенные контейнеры
docker rm $(docker ps -a -q) # удалит все незапущенные контейнеры

Docker machine

• docker-machine - встроенный в докер инструмент для создания хостов и установки на
них docker engine. Имеет поддержку облаков и систем виртуализации (Virtualbox, GCP и
др.)
• Команда создания - docker-machine create <имя>. Имен может быть много, переключение
между ними через eval $(docker-machine env <имя>). Переключение на локальный докер
- eval $(docker-machine env --unset). Удаление - docker-machine rm <имя>.
• docker-machine создает хост для докер демона со указываемым образом в --googlemachine-image, в ДЗ используется ubuntu-16.04. Образы которые используются для
построения докер контейнеров к этому никак не относятся.
• Все докер команды, которые запускаются в той же консоли после eval $(docker-machine
env <имя>) работают с удаленным докер демоном в GCP

Создали свой образ с приложением.
docker build -t reddit:latest . # • Точка в конце обязательна, она указывает на путь до Docker-контекста
				  • Флаг -t задает тег для собранного образа

docker run --name reddit -d --network=host reddit:latest # запустили наш контейнер

Зарегистрировался на docker hub

docker login

docker tag reddit:latest <your-login>/otus-reddit:1.0  # Загрузили наш образ на docker hub для использования в будущем

docker push <your-login>/otus-reddit:1.0

Задание со *

Нужно реализовать в виде прототипа в директории /docker-monolith/
infra/
• Поднятие инстансов с помощью Terraform, их количество задается переменной;
• Несколько плейбуков Ansible с использованием динамического инвентори для установки докера и запуска там образа приложения;
• Шаблон пакера, который делает образ с уже установленным Docker;
