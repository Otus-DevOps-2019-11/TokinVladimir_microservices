# TokinVladimir_microservices
TokinVladimir microservices repository

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
