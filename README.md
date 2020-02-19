# TokinVladimir_microservices
TokinVladimir microservices repository

#### Домашнее задание 17. Docker -4. Docker: сети, docker-compose

### План

* ul Работа с сетями в Docker
 * ul none
 * ul host
 * ul bridge

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

* ulИспользование docker-compose
 * ul Установить docker-compose на локальную машину
 * ul Собрать образы приложения reddit с помощью docker-compose
 * ul Запустить приложение reddit с помощью dockercompose

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
