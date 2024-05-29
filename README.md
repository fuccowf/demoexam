## ПРАВА СУПЕРПОЛЬЗОВАТЕЛЯ (ROOT)

Суперпользователь, он же root, является пользователем с наивысшими правами.

Отдельную команду можно использовать, как Суперпользователь, вставив в начале командлету:

    sudo  COMMAND

Если необходимо выполнить несколько команд, то можно сразу сменить текущего пользователя на root:

    su - root

* su – switch user (сменить пользователя).

* Тире указывает оболочку по умолчанию (/bin/bash), иначе необходимо указывать путь к каждой команде или прописывать переменные для пользователя или приведет к ошибке прав доступа.


## ИЗМЕНЕНИЕ ИМЕНИ ХОСТА (hostname)

Изменение имени хоста с помощью ctl-журнала, хост поменяется после перезагрузки (exec  bash - перезапуск оболочки для отображения нового имени):

    hostnamectl set-hostname NAME;exec bash

Отображение текущего имени хоста:

    uname -n


## ПРОСМОТР СЕТЕВЫХ НАСТРОЕК ХОСТА

Отображение всех доступных портов хоста:

    ip a

Отображение конкретного порта хоста:

    ip addr show PORT-NAME


## ОПРЕДЕЛЕНИЕ ВЕРНОГО ИНТЕРФЕЙСА

Для настройки интерфейса нужно его определение по направлению. Нужно посмотреть его направление и сравнить с mac-адресом. После чего можно говорить о его принадлежности к какому-то соединению.

![image](https://github.com/fuccowf/demoexam/assets/51357017/c87276f1-7a7f-4dee-bfe1-7022ad23baaa)
![image](https://github.com/fuccowf/demoexam/assets/51357017/e0d3067b-77fe-4539-928e-e9944d09f8e6)
![image](https://github.com/fuccowf/demoexam/assets/51357017/ca0d32bd-d562-461b-aa66-b4be15d93457)


Следовательно, в сторону HQ-R  смотрит интерфейс с именем **ens34**.


## ИСПОЛЬЗОВАНИЕ ТЕКСТОВОГО РЕДАКТОРА VIM

VIM – встроенный текстовый редактор в Alt  Linux. Он будет использоваться перед тем настроить интернет на других устройствах и установить более удобный nano.

Открытие текстового файла в vim:

    vim PATH-TO-FILE/FILE-NAME

Чтобы выполнить поиск по файлу, необходимо нажать клавишу **`/`** (слэш). В нижнем левом угу отобразиться слэш, после которого вводится запрос:

    /SEARCH

При открытии, мы находимся в режиме просмотра, чтобы перейти в режим редактирования, необходимо нажать клавишу Insert. В нижнем левом углу отобразиться:

    -- INSERT --

После завершения редактирования файла, необходимо сначала нажать клавишу Esc, чтобы выйти из режима редактирования, надпись в левом нижнем углу пропадет. После ввести символ “`:`” (двоеточие: Shift + Ж) и прописать:

    wq

*  ***wq – write&quit (записать и выйти).***

* ***Также можно использовать “q”, чтобы выйти без сохранения.***

* ***В случае если нет прав на запись (файл открыт без sudo/root’а), необходимо использовать “q!”.***


## ИЗМЕНЕНИЕ ТЕКСТОВОГО РЕДАКТОРА ПО УМОЛЧАНИЮ

Далее будут использоваться команды, в которых нельзя будет указать другой редактор и **vim**  не подходит для корректного редактирования. Можно указать, например, **nano**. Nano  в данный момент еще не установлен, но настройка будет полезна на следующих этапах.

Создаем папку интерфейса:

    export EDITOR=nano




## НАСТРОЙКА СТАТИЧЕСКОГО IP ДЛЯ ИНТЕРФЕЙСА

После определения верного интерфейса, мы задаем ему статический ip-адрес. Возьмем за пример тот же ens34.

Создаем папку интерфейса:

    mkdir /etc/net/ifaces/ens34

Создаем конфигурационный файл интерфейса с правами администратора:

    vim /etc/net/ifaces/ens34/options

Прописываем следующие параметры (с учетом регистра):

    BOOTPROTO=static
    
    TYPE=eth
    
    NM_CONTROLLED=no
    
    DISABLED=no
    
    CONFIG_WIRELESS=no
    
    SYSTEMD_BOOTPROTO=dhcp4
    
    CONFIG_IPV4=yes
    
    SYSTEMD_CONTROLLED=no
    
    ONBOOT=yes

    CONFIG_IPV6=no

* ***Параметр BOOTPROTO отвечает за способ получения сетевой картой сетевого адреса и может принимать значения:***

* ***static — адреса будут взяты из файла ipv4address (статический);***
* ***dhcp — интерфейс будет сконфигурирован по DHCP (автоматический).***

Создаем конфигурационный файл ip адреса интерфейса:

    vim /etc/net/ifaces/ens34/ipv4address

В созданном файле прописываем статический ip-адрес:

    192.168.100.1/30

Перезагружаем сетевые настройки для применения настроек:

    systemctl restart network



## НАСТРОЙКА ШЛЮЗА ДЛЯ ИНТЕРФЕЙСА

Для корректной работы сети и подключения интернета на другие роутеры, необходимо настроить между ними Default  gateway (шлюз по умолчанию), куда будут отправляться пакеты с неизвестным адресом назначения. В нашем примере, необходимо настроить шлюз с HQ-R  и BR-R  в сторону ISP, на котором настроен выход в интернет.

Создаем конфигурационный файл маршрута с правами администратора:

    vim /etc/net/ifaces/ens33/ipv4route

Прописываем маршрут на интерфейсе ens33 роутера HQ-R  в сторону ISP:

    default via 192.168.1.1

Перезагружаем сетевые настройки для применения настроек:

    systemctl restart network

Проверяем соединение к интернету:

    ping 8.8.8.8



## НАСТРОЙКА DNS ДЛЯ ИНТЕРФЕЙСА

Для установки пакета, необходим не только доступ в интернет, но и DNS, который определяет доменные имена, такие как google.com, ya.ru  и пр. В нашем случае, необходимо получить доступ к репозиторию altlinux.org.

Выбираем интерфейс в сторону роутера, который выходит в интернет. Также на этом интерфейсе уже настроен шлюз по умолчанию. Создаем конфигурационный файл DNS-серверов с правами администратора:

    vim /etc/net/ifaces/ens33/resolv.conf

Задаем DNS-сервера от Google:

    nameserver 8.8.8.8
    
    nameserver 8.8.4.4

Перезагружаем сетевые настройки для применения настроек:

    systemctl restart network

Проверяем правильную настройку:

    curl google.com

*Если все правильно, то в выводе команды curl  должен быть HTML-код.*



## ИСПОЛЬЗОВАНИЕ ТЕКСТОВОГО РЕДАКТОРА NANO

После установи соединения в интернет, мы можем установить nano.

Для этого скачиваем пакет:

    apt-get -y install nano

Для того чтобы редактировать файл достаточно перед путем к файлу написать командлету **nano**:

    nano /path/to/file

После написания предыдущей команды откроется текстовый редактор. Комбинации клавиш написана внизу редактора. Основные:
 - CTRL + O - сохранить
 - CTRL + X - выйти
 - Зажатый Shift + Стрелочки - выделить текст
 - CTRL + K - вырезать
 - CTRL + U - вставить




## ВКЛЮЧАЕМ МАРШРУТИЗАЦИЮ IP ПАКЕТОВ В СИСТЕМЕ

Добавляем параметр в системный файл sysctl.conf:

    echo net.ipv4.ip_forward=1 > /etc/sysctl.conf

Применяем новые параметры:

    sysctl -p


## УСТАНОВКА ПАКЕТА И НАСТРОЙКА МАРШРУТИЗАЦИИ ЧЕРЕЗ FRR

FRR - пакет, позволяющий осуществить настройку динамической маршрутизации через cisco-команды.

Обновляем список пакетов, иначе FRR  не найдет:

    apt-get update

Установка пакета FRR:

    apt-get -y install frr

После установки пакета требуется его дополнительная настройка. Нужно указать какие протоколы будут участвовать в маршрутизации.

Заходим в конфигурацию daemons  FRR:

    nano /etc/frr/daemons

После открытия файла в редакторе, требуется поменять указатели протоколов NO  на YES(В примере используется OSPF):

    zebra=yes
    
    ospfd=yes
    
    ospf6d=yes
    
    bgpd=no
    
    ripd=no
    
    ripngd=no
    
    isisd=no
    
    pimd=no
    
    ldpd=no
    
    nhrpd=no
    
    eigrpd=no
    
    babeld=no
    
    sharpd=no
    
    staticd=no
    
    pbrd=no
    
    bfdd=no
    
    fabricd=no

Перезапускаем работу пакета FRR:

    systemctl restart frr

Проверяем статус работы сервиса:

    systemctl status frr

Заходим в эмуляцию cisco  CLI:

    vtysh

Включаем пересылку IP пакетов, иначе маршрутизатор будет выступать только в роли шлюза и пакеты не будут пересылаться между сетями и подсетями на основе таблицы маршрутизации (динамическая маршрутизация не будет работать):

    #config terminal
    
    (config)#ip forwarding
    
    (config)#do write memory

Была обнаружена ошибка, при перезапуске устройства команда выше перезаписывается на команду «no  ip  forwarding». Во избежание этого, нужно вручную прописать команду «ip  forwarding» в конфиг-файл:

   

 ```nano /etc/frr/frr.conf```

    
    ip forwarding
    
    ipv6 forwarding

* В файле может не быть команды “no  ip  forwarding”, но нужно все равно прописать команду, как обозначено выше, желтым цветом. Так же сразу можно указать пересылку ipv6 пакетов второй командой.

Задаем IP-адреса на интерфейсы:

    #config terminal
    
    (config)#interface NAME
    
    (config-if)#ip address IP/MASK-PREFIX
    
    (config-if)#do write memory
    
    (config-if)#exit

Настраиваем OSPF(можно выбрать другой протокол исходя из задачи). Нужно указать каждую сеть, напрямую подключенную к роутеру:

    #config terminal
    
    (config)#router ospf
    
    (config-router)#router-id N.N.N.N
    
    (config-router)#network IP-NET/MASK-PREFIX area N.N.N.N
    
    (config-router)#default-information originate
    
    (config-if)#do write memory
    
    (config-if)#exit


## НАСТРОЙКА DHCP СЕРВЕРА

Установка пакета DHCP сервер:

    apt-get -y install dhcp-server

Открываем конфигурационный файл dhcp  сервера. Чтобы не писать конфиг с нуля, можно воспользоваться dhcpd.conf.sample  и изменить его:

    vim /etc/dhcp/dhcpd.conf.sample

В конфигурационном файле задаются основные параметры DHCP сервера:

    ddns-update-style  none;
    
    subnet  192.168.1.0 netmask 255.255.255.192 { #сеть и маска подсети
    
    option routers  192.168.1.1; #шлюз
    
    option subnet-mask  255.255.255.192; #маска
    
    option nis-domain  "domain.org"; #NIS-домен
    
    option domain-name  "domain.org"; #домен
    
    option domain-name-servers  8.8.8.8; #DNS-сервер
    
    range  dynamic-bootp 192.168.1.2 192.168.1.62; #пул ip
    
    #ручное резервирование адресов
    
    host HQ-SRV
    
    {
    
    hardware ethernet 00:1C:C0:45:27:14;#Mac-адрес  интерфейса
    
    fixed-address 192.168.1.2; #фиксированный адрес
    
    }
    
    #стандартное и максимальное время аренды (в секундах)
    
    #6 часов
    
    default-lease-time 21600;
    
    #12 часов
    
    max-lease-time 43200;
    
    }

Переименуем файл dhcpd.conf.sample  в dhcpd.conf:

    mv  dhcpd.conf.sample  dhcpd.conf

Указываем интерфейс, через который будет работать DHCP. В нашем примере интерфейс ens37 на HQ-R  в сторону HQ-SRV:

> vim /etc/sysconfig/dhcpd

    DHCPDARGS=ens37

Включаем автозапуск DHCP  сервера при включении:

    chkconfig dhcpd on

Запускаем DHCP сервер:

    service dhcpd start

Проверяем работу службы DHCPD:

    service dhcpd status

или

    systemctl status dhcpd




## ДОБАВЛЕНИЕ НОВОГО ПОЛЬЗОВАТЕЛЯ

Добавляем пользователя admin:

    useradd admin

Добавляем пароль для пользователя admin:

    passwd admin

Добавляем пользователя admin  в группу wheel (sudo):

    usermod -aG wheel admin

> -aG означает добавить к уже назначенным группам новую группу. Если указать только -G то все группы (в нашем случае admin) будут заменены
> на wheel.

Проверяем группы у пользователя:

    groups admin

Заходим под root:

    su - root

Открываем файл sudoers  через текстовый редактор под root’ом:

    visudo

или

    vim /etc/sudoers

Добавляем права для выполнения команды sudo  для всех пользователей группы wheel. Ищем строчку с помощью клавиши / (слэш) и удаляем # (решетку) перед командой помощью клавиши Del  перед символом, чтобы система воспринимала строку как команду, а не комментарий:

    #Uncomment to allow members of group wheel to execute any command
    
    WHEEL_USERS ALL=(ALL:ALL) ALL

Заходим под пользователем admin:

    su - admin


## ИЗМЕРЕНИЕ ПРОПУСКНОЙ СПОСОБНОСТИ ЧЕРЕЗ IPERF3

Устанавливаем iperf3:

    apt-get install iperf3

Запускаем сервер на одном из устройств:

    iperf3 -s

Запускаем клиент на втором устройстве:

    iperf3 -с IP-ADDRESS




## СОЗДАНИЕ БЭКАП СКРИПТОВ

Создаем файл скрипта с расширением .sh в папке /opt (директория для доп. программ):

```vim /opt/backup_script.sh```

    #!/bin/bash
    
    current_date=$(date +”%Y-%m-%d”)
    backup_dir=”/opt/backups”
    backup_file=”server-backup-$current_date.tar.gz”
    source_dir=”/etc/frr/frr.conf”
    
    mkdir -p “$backup_dir”
    tar -czvf “$backup_dir/$backup_file” “$source_dir”
    echo “BACKUP $source_dir COMPLETE: $backup_file”

Добавляем скрипт в таблицу CRON  для автоматического запуска каждый день в 3:00:

```crontab -e```

    0 3 * * * /opt/backup_script.sh

Добавляем права на исполнение файла скрипта:

    chmod +x /opt/backup_script.sh

Запускаем скрипт для теста:

    /opt/backup_script.sh




## ПЕРЕНАПРАВЛЕНИЕ ТРАФИКА С ПОРТА НА ПОРТ

Добавляем правило в iptables  для перенаправления трафика. В нашем примере будет перенаправление трафика с внешнего порта 2222 на внутренний порт 22 для SSH  соединения:

    iptables -t nat -A PREROUTING -p tcp --dport 2222 -j REDIRECT --to-port 22

Сохраняем правило в файл для автозапуска:

    iptables-save > /etc/sysconfig/iptables

Добавляем автозапуск для службы iptables:

    systemctl enable iptables

Подключаемся по SSH  с указанием порта (по умолчанию 22):

    ssh user@192.168.1.2 -p 2222





## БЛОКИРОВАНИЕ ТРАФИКА

Отбрасываем пакеты по SSH (22 порт) для определенного хоста (172.16.10.2):

    iptables -A INPUT -p tcp -s 172.16.10.2 --dport 22 -j DROP

> При блокировке 22 порта, 2222, как в примере выше, будет также
> заблокирован.

Разрешить пакеты для определенного хоста:

    iptables -A INPUT -p tcp -s IP-ADDRESS --dport PORT -j ACCEPT

Просмотр всех правил iptables:

    iptables -L --line-numbers

Удаление правила по его номеру в списке:

    iptables -D INPUT/OUTPUT/FORWARDING NUMBER-OF-RULE

Сохраняем правило в файл для автозапуска:

    iptables-save > /etc/sysconfig/iptables

Добавляем автозапуск для службы iptables:

    systemctl enable iptables

Подключаемся по SSH  с указанием порта (по умолчанию 22):

    ssh user@192.168.1.1 -p 2222






## УСТАНОВКА И НАСТРОЙКА DNS СЕРВЕРА

Установка пакетов bind, если не установлено

    apt-get -y install bind

Открываем конфиг-файл:

`nano /var/lib/bind/etc/options.con`f

Необходимо изменить следующие строчки в конфиг-файле (желтым отмечены изменённые значения):

    listen-on { 192.168.1.2; };
    
    forwarders {77.88.8.8; 8.8.8.8; 8.8.4.4; };
    
    recursion yes;
    
    allow-query { any; };

> * listen-on {}; - определяет сеть, на которой DNS-сервер будет слушать запрос, в нашем случае, указываем ip-интерфейса, также можно указать
> any, чтобы прослушивать на всех интерфейсах.
> 
> * forwarders {}; - пересылает записи из других DNS, если не указать, то доменные имена не будут определяться (YandexDNS и 2 GoogleDNS).
> 
> * allow_query {}; - список IP-адресов или подсетей, которым разрешено отправлять запросы на DNS-сервер, в нашем случае, любой локальный
> запрос.
> 
> * recursion  определяет разрешено ли серверу делать рекурсивные запросы. Это DNS-запрос, при котором DNS-сервер выступает в качестве
> клиента, от имени которого запрашиваются данные, и опрашивает другие
> сервера в поиске IP-адреса для определенного домена.

Проверяем наличие ошибок в конфигурационных файла, если команда ничего не выводит в терминал - ошибок нет:

    named-checkconf

Включаем автозапуск и сразу запускаем DNS  сервер:

    systemctl enable --now bind

Открываем конфиг-файл, данную настройку необходимо проделать на всех устройствах:

    nano /etc/resolv.conf

Необходимо изменить следующие строчки в конфиг-файле:

    #Указываем имя зоны
    
    search  ZONE.NAME
    
    #Указываем ip-адрес DNS-сервера
    
    nameserver 192.168.1.2




## НАСТРОЙКА DNS ЗОНЫ ПРЯМОГО ПРОСМОТРА

Открываем конфиг-файл, отвечающий за настройку информации о зонах:

    nano  /var/lib/bind/etc/local.conf

В нашем примере, у нас 2 зоны: hq.work  и br.work + 2 обратные зоны, которые будут описываться дальше. После комментариев указываем зоны:

    // Add other zones here
    
    zone “hq.work” {
    
    type master;
    
    file “hq.work.db”
    
    }
    
    zone “br.work” {
    
    type master;
    
    file “br.work.db”
    
    }

> * zone “hq.work” - название нашей зоны
> 
> * type  master; - указывает тип зоны. Мастер означает, что эта DNS-сервер содержит авторитетные записи для этой зоны. Если этой
> настройки не будет, сервер попытается перенаправить запрос на
> правильный сервер.
> 
> * file “PATH” - путь к файлу, который содержит все записи зоны.

Копируем пример-шаблон прямой зоны, который будем изменять (с помощью круглых скоб, можно сразу указать файл, который копируется и новый копированный файл в той же директории):

    cd /var/lib/bind/etc/zone/{localdomain,hq.work.db}
    
    cp /var/lib/bind/etc/zone/{localdomain,br.work.db}

Выдаем права на владение файлом системному пользователю и его группу named:named  и задает права на чтение и редактирование для владельца (600):

    chown named. /var/lib/bind/etc/zone/{hq.work,br.work}.db
    
    chmod 600 /var/lib/bind/etc/zone/{hq.work,br.work}.db

Открываем файл-конфиг прямой зоны hq.work.db:

    nano /var/lib/bind/etc/zone/hq.work.db

Изменяем файл (желтым отмечены изменения), то же самое потом проделать с br.work.db:

    $TTL 86400
    @  IN  SOA hq.work. root.hq.work. (
    2021042801  ; Serial
    3600  ; Refresh
    1800  ; Retry
    604800  ; Expire
    86400 )  ; Negative Cache TTL
    
    @  IN  NS hq.work.
    @  IN  A  192.168.1.2
    hq-r  IN  A  192.168.1.1
    hq-srv  IN  A  192.168.1.2

> * hq.work. root.hq.work. - определяет имя первичной зоны и контактный адрес лица, отвечающего за администрирование файла зоны.
> 
> * @ IN  NS  hq.work. - количество серверов, которое будет обслуживать нашу зону, в нашем случае 1 сервер - 1 запись.
> 
> * @ IN  A 192.168.1.2 - определяет ip-адрес нашего DNS-сервера.
> 
> * hq-r  IN  A 192.168.1.1 - определяет ip-адрес хоста HQ-R (hq-r.hq.work).
> 
> * hq-srv  IN  A 192.168.1.2 - определяет ip-адрес хоста HQ-SRV (hq-srv.hq.work).

Проверяем файл на ошибки синтаксиса:

    named-checkconf -z

Перезагружаем DNS-сервер:

    systemctl restart bind

Проверяем определение хостов:

    host hq.work
    
    host hq-r.hq.work
    
    host hq-srv.hq.work




## НАСТРОЙКА DNS ЗОНЫ ОБРАТНОГО ПРОСМОТРА

Открываем конфиг-файл отвечающий за настройку информации о зонах:

    nano  /var/lib/bind/etc/local.conf

В нашем примере, у нас 2 зоны: hq.work  и br.work + 2 обратные зоны, которые мы добавляем сразу после прямых зон:

    zone “hq.work” {
    
    ...
    
    }
    
    zone “1.168.192.in-addr.arpa” {
    
    type master;
    
    file “hq.work_rev.db”
    
    }
    
    zone “br.work” {
    
    ...
    
    }
    
    zone “2.168.192.in-addr.arpa” {
    
    type master;
    
    file “br.work_rev.db”
    
    }

Копируем пример-шаблон обратной зоны:

    cp /var/lib/bind/etc/zone/{127.in-addr.arpa,hq.work_rev.db}
    
    cp /var/lib/bind/etc/zone/{127.in-addr.arpa,br.work_rev.db}

Выдаем права на владение файлом системному пользователю и его группу named:named  и задает права на чтение и редактирование для владельца (600):

    chmod named. /var/lib/bind/etc/zone/{hq.work_rev,br.work_rev}.db
    
    chmod 600 /var/lib/bind/etc/zone/{hq.work_rev,br.work_rev}.db

Открываем файл-конфиг обратной зоны hq.work_rev.db:

    nano /var/lib/bind/etc/zone/hq.work_rev.db

Изменяем файл (желтым отмечены изменения), то же самое потом проделать с br.work.db:

    $TTL 86400
    
    @  IN  SOA hq.work. root.hq.work. (
    2021042801  ; Serial
    3600  ; Refresh
    1800  ; Retry
    604800  ; Expire
    86400 )  ; Negative Cache TTL
    
    @  IN  NS hq.work.
    1  IN  PTR  hq-r.hq.work.
    2  IN  PTR  hq-srv.hq.work.

> * hq.work. root.hq.work. - определяет имя первичной зоны и контактный адрес лица, отвечающего за администрирование файла зоны.
> 
> * @ IN  NS  hq.work. - количество серверов, которое будет обслуживать нашу зону, в нашем случае 1 сервер - 1 запись.
> 
> * 1  IN  PTR  hq-r.hq.work - 1 обозначает последний октет ip-адреса, PTR  запись - запись обратного просмотра, hq-r.hq.work - доменное имя,
> которое присвоено ip-адресу.
> 
> * 2  IN  PTR  hq-r.hq.work - В первом столбце стоит цифра 2, так как hq-srv.hq.work, он же HQ-SRV, имеет ip-адрес 192.168.1.2.
> 
> * То есть, если нужно прописать зону обратного просмотра для хоста 172.16.10.197/24, то в файле local.conf прописываем зону «10.16.172.in-addr.arpa», а в файле, содержащим PTR  запись, прописать
> 197 IN  PTR  domain.name.

Проверяем файл на ошибки синтаксиса:

    named-checkconf -z

Перезагружаем DNS-сервер:

    systemctl restart bind

Проверяем определение хостов, в выводе команды должна быть запись обратного просмотра:

    host 192.168.1.1
    
    host 192.168.1.2




## НАСТРОЙКА СИНХРОНИЗАЦИИ ВРЕМЕНИ С ПОМОЩЬЮ NTP

Устанавливаем NTP  сервер:

    apt-get -y install ntp

Разрешаем автозапуск:

    systemctl enable ntpd

Запускаем службу:

    systemctl start ntpd

Открываем файл конфигурации:

    nano /etc/ntp.conf

Для того чтобы подтягивать время с других серверов NTP, требуется записать их в конфигурационный файл:

    server ntp2.vniiftri.ru iburst prefer

> * ntp2.vniiftri.ru - сервер, с которого поступает корректное время.
> 
> * iburst - аттрибут записи, означающий отправку несколько пакетов, что повышает точность времени.
> 
> * prefer - аттрибут, указывающий предпочитаемый сервер

Пишем запись для развертывания локального сервера NTP:

    server 127.127.1.0

Раскомментируем записи, которые требуются для настройки безопасности. Данные записи требуются для определения сетей, которые могут синхронизировать время с NTP-сервером:

    restrict 192.168.0.0 mask 255.255.0.0 nomodify
    
    restrict 172.16.0.0 mask 255.255.0.0 nomodify

> * restrict  default —  задает значение по умолчанию для всех рестриктов.
> 
> * kod —  узлам, которые часто отправляют запросы сначала отправить поцелуй смерти (kiss  of death), затем отключить от сервера.
> 
> * notrap —  не принимать управляющие команды.
> 
> * nomodify —  запрещает команды, которые могут вносить изменения состояния.
> 
> * nopeer —  не синхронизироваться с хостом.
> 
> * noquery — не принимать запросы.
> 
> * restrict 192.168.0.0 mask 255.255.255.0 —  разрешить синхронизацию для узлов в сети  192.168.0.0/24.
> 
> * IP адреса  127.0.0.1  и  ::1  позволяют обмен данные серверу с самим собой.

По умолчанию порт NTP:123 закрыт. Откроем его через iptables:

    iptables -I INPUT 1 -p udp --dport 123 -j ACCEPT

Перезагрузим NTP  и проверим работу сервера:

    systemctl restart ntp

    ntpq -p

Для того чтобы подключить клиент к созданному локальному NTP серверу, требуется ввести в файл /etc/ntp.conf  запись:

    server 192.168.1.1 iburst prefer

После ввода записи перезагрузите демон NTP  командой и проверяем работу:

    service ntpd restart
    
    ntpq -p





## НАСТРОЙКА СЕРВЕРА ДОМЕНА SAMBA + BIND-DNS

Устанавливаем task-samba-dc  пакет:

    apt-get -y install task-samba-dc

Отключаем chroot, который используется для изоляции процессов сервера от остальной системы, повышая тем самым безопасность:

    control bind-chroot disabled

Отключить KRB5RCACHETYPE - переменная окружения, используемая в Kerberos  для указания типа кэша:

    grep -q 'bind-dns' /etc/bind/named.conf || echo 'include "/var/lib/samba/bind-dns/named.conf";' >> /etc/bind/named.conf

> * grep -q 'bind-dns' /etc/bind/named.conf - проверяет в тихом режиме, без вывода ничего в консоль, возвращая 1 или 0, в зависимости от
> результатов поиска текста в одинарных кавычках в файле по указанному
> пути.
> 
> * || - оператор ИЛИ. Если не первая команда вернет 0, то есть не найдет строку, то будет выполнятся следующая команда.
> 
> * echo 'include "/var/lib/samba/bind-dns/named.conf";' >> /etc/bind/named.conf - записывает в указанный файл после стрелочек
> строку в одинарных кавычках.

Открываем настройки bind:

    nano /etc/bind/options.conf

После строки recursing-file “...”; вводим следующие команды:

    tkey-gssapi-keytab “/var/lib/samba/bind-dns/dns.keytab”;

    minimal-responses yes;

В разделе logging, в конце раздела, добавляем строку:

    category lame-servers {null;};

Останавливаем bind:

    systemctl stop bind

Устанавливаем доменное имя хоста:

    nano /etc/sysconfig/network
    
    HOSTNAME=hq-srv.demo.first

Задаем hostname  с учетом доменного имени (exec  bash - перезапуск оболочки для отображения нового имени):

    hostnamectl set-hostname hq-srv.demo.first;exec bash

Задаем доменное имя:

    domainname demo.first

Очищаем базы и конфиг samba (в случае если ранее создавался):

    rm -f /etc/samba/smb.conf
    
    rm -rf /var/lib/samba
    
    rm -rf /var/cache/samba
    
    mkdir -p /var/lib/samba/sysvol

Запускаем установку, можно через интерактивную установку, можно через команду. 
Интерактивная установка:

    samba-tool domain provision

> * Все параметры будут уже заданы, необходимо только указать BIND9_DNZ в пункте DNS  backend. После задать пароль админа.

Пакетный режим установки:

    samba-tool domain provision --realm=demo.first --domain=demo --adminpass='P@ssw0rd' --dns-backend=BIND9_DLZ --server-role=dc --use-rfc2307

> * --realm=demo.first - имя области Kerberos (LDAP), и DNS имя домена;
> 
> * --domain=demo  - имя домена (имя рабочей группы);
> 
> * --adminpass='P@ssw0rd' - пароль основного администратора домена;
> 
> * --dns-backen=BIND9_DLZ - бэкенд DNS-сервера;
> 
> * --server-role=dc - тип серверной роли;
> 
> * --use-rfc2307 - позволяет поддерживать расширенные атрибуты типа UID и GID в схеме LDAP и ACL на файловой системе Linux.

Включаем и добавляем в автозагрузку службы samba и bind:

    systemctl enable --now {samba,bind}

Проверяем наши настройки:

	host -t SRV _kerberos._udp.demo.first.

	host -t SRV _ldap._tcp.demo.first.

	host -t A hq-srv.demo.first

	kinit [administrator@DEMO.FIRST]

	klist




## ВВОД В ДОМЕН SAMBA ЧЕРЕЗ ГРАФИЧЕСКИЙ ИНТЕРФЕЙС

Устанавливаем task-auth-ad-sssd:

    apt-get update && apt-get dist-upgrade && apt-get install -y task-auth-ad-sssd

Необходимо в настройках сетевого соединения указать ip нашего локального DNS сервера и указываем поисковый домен demo.first. Заходим Меню -> Центр управления -> Расширенная конфигурация сети -> Выбираем настроенное соединение -> Параметры IPv4.

![image](https://github.com/fuccowf/demoexam/assets/51357017/83b259ab-a35c-470d-a429-2398d6b784a5)

Далее заходим снова в Центр управления -> Центр управления системой -> В разделе Пользователи, выбираем Аутентификация:

![image](https://github.com/fuccowf/demoexam/assets/51357017/a53dee1a-25d5-4747-ae28-55000cf3819e)

Выбираем Домен Active  Directory, вводим домен и рабочую группу, которые мы указывали при настройке сервера. Применяем и указываем пароль Администратора Домена, который мы так же задавали при настройке сервера:

![image](https://github.com/fuccowf/demoexam/assets/51357017/699c8af4-dd7f-4602-be2a-e1a64c3358b8)

Мы вошли в домен. Теперь необходимо перезагрузить устройство и при следующем входе войти, используя учетную запись домена, которую мы использовали для входа в домен выше.




## ВВОД В ДОМЕН SAMBA ЧЕРЕЗ КОНСОЛЬ

Устанавливаем task-auth-ad-sssd:

    apt-get update && apt-get install -y task-auth-ad-sssd

Прописываем адрес локального DNS  сервера и поисковый домен:

    echo nameserver 192.168.1.2 > /etc/net/ifaces/ens33/resolv.conf
    
    echo search demo.first >> /etc/net/ifaces/ens33/resolv.conf

Перезагружаем сеть:

    systemctl restart network

Используем команду для ввода в домен:

    system-auth write ad demo.first br-srv demo 'administrator' 'P@ssw0rd'

> * Demo-first - имя домена
> 
> * Br-srv - имя хоста
> 
> * Administrator - имя пользователя администратора домена
> 
> * P@ssw0rd - пароль админа домена

И перезагружаем систему:

    reboot

Проверяем подключение:

    system-auth status




## УСТАНОВКА МОДУЛЯ УДАЛЕННОГО УПРАВЛЕНИЯ БАЗОЙ ДАННЫХ КОНФИГУРАЦИИ (ADMC)

Устанавливаем ADMC. Модуль используется для управления учетными записями, подключенными устройствами внутри Домена:

    apt-get install -y admc

Для использования ADMC  необходимо предварительно получить ключ Kerberos  для администратора домена, грубо говоря авторизироваться под админом домена:

    kinit administrator

Открываем приложение через Меню в левом нижнем углу, в поиске пишем ADMC  или пункт Системные -> ADMC. В Computers можно отследить подключенные устройства к домену. В Users администрировать учетные записи внутри домена:

![image](https://github.com/fuccowf/demoexam/assets/51357017/2357aa39-e760-4181-a67f-bdfdac25560a)

## ДОБАВЛЕНИЕ УЧЕТНЫХ ЗАПИСЕЙ ПОЛЬЗОВАТЕЛЕЙ В ДОМЕН

В нашем примере необходимо создать 3 учетные записи: Admin, Branch  admin, Network  admin с паролем P@ssw0rd. В ADMC  нажимаем ПКМ по строке Users, выбираем Создать -> Пользователь:

![image](https://github.com/fuccowf/demoexam/assets/51357017/140f7d59-d30a-4e63-96ee-83e6ede5c5b1)

## ДОБАВЛЕНИЕ ГРУПП ПОЛЬЗОВАТЕЛЕЙ В ДОМЕН

В нашем примере необходимо создать 3 группы пользователей: Admin, Branch  admin, Network  admin. В ADMC  нажимаем ПКМ по строке Users, выбираем Создать -> Группа и прописываем название группы.

## ДОБАВЛЕНИЕ ПОЛЬЗОВАТЕЛЕЙ В ГРУППЫ В ДОМЕНЕ

После создания учетных записей и групп пользователей, во вкладке Users, нажимаем ПКМ по пользователю и нажимаем «Добавить в группу», откроется окно поиска группы, в котором необходимо указать название группы, после чего нажать Добавить справа:

![image](https://github.com/fuccowf/demoexam/assets/51357017/49746850-120f-434d-ac4c-97ecd33406d6)

## ФАЙЛОВЫЙ SMB СЕРВЕР НА SAMBA

Файловый сервер можно разворачивать не только на основе протокола SMB  на Samba, но и NFS  сервер. В нашем случае будет использоваться именно SMB, так как SMB аббревиатура Samba  пакет Samba  уже установлен на HQ-SRV  и протокол SMB  чаще используется. Для начала создаем директории для общих папок, которые будут шариться по сети (в плане, share):

    mkdir /opt/{branch,network,admin}

> Директория /opt/ используется для доп. программ и директив.

Задаем права на созданные директории:

    chmod 777 /opt/{branch,network,admin}

> 777 - чтение, запись, выполение для владельца, группы и всех остальных.

Описываем общие папки для публикации в конфиге:

	 nano /etc/samba/smb.conf

В файле: 

    [Branch_Files]
	    path = /opt/branch
	    writable = yes
	    read only = no
	    valid users = @”DEMO\Branch admins”
    
    [Network]
	    path = /opt/network
	    writable = yes
	    read only = no
	    valid users = @”DEMO\Network admins”
    
    [Admin_Files]
        path = /opt/admin
	    writable = yes
	    read only = no
	    valid users = @”DEMO\Admins”

> [Branch_Files] - имя общей папки, для публикации требуемое по заданию;
> 
> path—указывает каталог, к которому должен быть предоставлен доступ;
> 
>writable—инвертированный синоним для read  only (по умолчанию: writeable = no);
>
>read  only—если для этого параметра задано значение «yes», то пользователи службы не могут создавать или изменять файлы в каталоге (по умолчанию: read  only = yes);
>
>valid  users - это список пользователей, которым должно быть разрешено входить в эту службу, в данном случае с использованием доменных пользователей указываем группу к которой они принадлежат (группы создавались ранее, через ADMC).

Перезапускаем службу samba:

    systemctl restart samba

Проверяем работу:

    smbclient -L localhost -Uadministrator





## ПОДКЛЮЧЕНИЕ КЛИЕНТОВ К СЕТЕВОЙ ДИРЕКТОРИИ SAMBA

Устанавливаем пакет, с помощью которого будет осуществляться автоматическое подключение к сетевому ресурсу при каждом входе доменным пользователем:

    apt-get install -y pam_mount

Устанавливаем пакет для работы с smb (CIFS):

    apt-get install -y cifs-utils

Устанавливаем пакет для корректного отключения файловых ресурсов при завершении работы:

    apt-get install -y system-settings-enable-kill-user-process

Перезагружаем:

    reboot

Прописываем pam_mount  в схему аутентификации по умолчанию:

    nano /etc/pam.d/system-auth

В конец файла прописываем:

    session [success=1 default=ignore] pam_succeed_if.so service = systemd-user quiet
    
    session optional pam_mount.so disable_interactive

> Первая строка для того, чтобы не монтировать дважды при запуске
> 
> Disable_interactive - pam_mount не будет спрашивать пароль

Прописываем правила монтирования ресурса в файле:

    nano /etc/security/pam_mount.conf.xml

После комментария `<!-- Volume  definitions -->` прописываем.:

    <!-- Volume definitions -->
    
    <volume uid=”Admin”
	    fstype=”cifs”
	    server=hq-srv.demo.first”
	    path=”Admin_Files”
	    mountpoint=”/mnt/All_files”
	    options=”sec=krb5i,cruid=%(USERUID),nounix,uid=%(USERUID),gid=%(USERGID),file_mode=0664,dir_mode=0775”
    />
    
    <volume uid=”Network admin”
	    fstype=”cifs”
	    server=hq-srv.demo.first”
	    path=”Network”
	    mountpoint=”/mnt/All_files”
	    options=”sec=krb5i,cruid=%(USERUID),nounix,uid=%(USERUID),gid=%(USERGID),file_mode=0664,dir_mode=0775”
    />
    
    <volume uid=”Branch admin”
	    fstype=”cifs”
	    server=hq-srv.demo.first”
	    path=”Branch_Files”
	    mountpoint=”/mnt/All_files”
	    options=”sec=krb5i,cruid=%(USERUID),nounix,uid=%(USERUID),gid=%(USERGID),file_mode=0664,dir_mode=0775”
    />

>uid="NAME_or_UID" — имя пользователя или диапазон присваиваемых для доменных пользователей UID (подходит и для Winbind и для SSSD);
>
>server="hq-srv.demo.first" — имя сервера с ресурсом;
>
>path="" — имя файлового ресурса;
>
>mountpoint="/mnt/All_files" — путь монтирования на устройстве.

После перезапускаем систему:

    reboot

Заходим под обычным локальным пользователем user, далее переходим под root. Появляются сообщения об ошибке, которые означаю, что ключи Kerberos  недоступны:

    mount error(126): Required key not available

    Refer to the mount.cifs(8) manual page (e.g. man mount.cifs)

Чтобы их получить, снова прописываем команду и вводим пароль от учетной записи:

    kinit USERNAME@DOMAIN

>USERNAME - вводим имя пользователя внутри домена (в нашем случае это: admin,bradmin,netadmin)
>
>DOMAIN - наш домен (DEMO.FIRST)

Снова заходим под рутом, чтобы терминал перезапустился:

    su - root

Вместо предыдущей ошибки, теперь другое сообщение, доступ недоступен. Так как мы заходим под одной из учеток, то доступ к другим папкам нам соответственно недоступен, поэтому сообщение всегда будет появляться при смене пользователя:

    mount error(13): Permission denied

    Refer to the mount.cifs(8) manual page (e.g. man mount.cifs)

Проверяем подключенную папку. 
   

    df  

В самом низу будет директория по такому примеру:

    Файловая система Размер Использовано Дост Использовано% Смонтировано в

    //hq-srv.demo.first/Network 28G 8,4G 198M 31% /mnt/All_Files

Для дополнительной проверки можно создать на HQ-SRV  в папке Network (в любой другой папке, которая сейчас удаленно смонтирована) текстовый файл с любым содержанием для теста:

    HQ-SRV# nano /opt/test

После сохранения файла на HQ-SRV, на BR-SRV  он сразу же появится в папке /mnt/All_Files

    BR-SRV# ls /mnt/All_Files





## УСТАНОВКА LMS MOODLE + APACHE + MYSQL-SERVER

Устанавливаем пакеты, в фигурных скобках указан перечень модулей с префиксом “apache2”:

    apt-get install -y apache2 apache2-{base,httpd-prefork,mod_php8.0,mods}

Устанавливаем пакеты php, в фигурных скобках указан перечень модулей с префиксом “php”:

    apt-get  install -y  php8.0 php8.0-{curl,fileinfo,fpm-fcgi,gd,intl,ldap,mbstring,mysqlnd,mysqlnd-mysqli,opcache,soap,sodium,xmlreader,xmlrpc,zip,openssl}

Запускаем веб-сервер и добавляем в автозагрузку:

    systemctl enable --now httpd2

Установка СУБД MySQL:

    apt-get install -y MySQL-server

Включаем и добавляем в автозагрузку MySQL:

    systemctl enable --now mysqld

Подключаемся к MySQL, создаём базу данных и пользователя:

    mysql

Вводим команды по очереди, не забываем про точку с запятой в конце каждой строк:

    > CREATE DATABASE moodle DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
    
    > CREATE USER 'moodle'@'localhost' IDENTIFIED WITH mysql_native_password BY 'moodle';
    
    > GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,CREATE TEMPORARY TABLES,DROP,INDEX,ALTER ON moodle.* TO 'moodle'@'localhost';

    > EXIT;

> Первая строка - создаем базу данных moodle, задаем кодировку utf8 и
> utf8_unicode_ci;
> 
> Вторая строка - создаем пользователя moodle  в локальной группе с
> паролем moodle;
> 
> Выдать права на перечисленные действия во все таблицы с префиксом
> moodle  для пользователя moodle  в локальной группе.

Устанавливаем git:

    apt-get install -y git

Загружаем код проекта Moodle из репозитория GitHub:

    git clone git://git.moodle.org/moodle.git

Переходим в загруженный каталог:

    cd moodle

Извлекаем список каждой доступной ветки (каждая ветка - отдельная версия). Выходим используя Q:

    git branch -a

Меняем текущую ветку на последнюю версию Moodle:

    git checkout MOODLE_404_STABLE

Выходим из директории moodle:

    cd ../

Копируем файлы Moodle  в рабочую директорию веб-сервера Apache (-R  обозначает полный перенос всех директорий внутри директории):

    cp -R moodle /var/www/html/

Создаем необходимые директории для работы платформы Moodle:

    mkdir /var/moodledata

Выдаем права владению системному пользователю apache2, который используется веб-сервером для доступа к файлам:

    chown -R apache2. /var/moodledata

Выдаем полные права (чтение, запись, исполнение) для всех:

    chmod -R 777 /var/moodledata

Выдаем полные права для владельца, чтение и выполнение для группы, чтение выполнение для всех остальных. Цифра 0 в начале означает, что необходимо заменить существующие права доступа на указанные в маске, без добавления нуля новые права будут добавляться к уже имеющимся:

    chmod -R 0755 /var/www/html/moodle

Назначаем владельца на директорию:

    chown -R apache2:apache2 /var/www/html/moodle

Изменяем конфиг-файл веб-сервера:

    nano /etc/httpd2/conf/sites-available/moodle.conf
  В файле: 

    <VirtualHost *:80>
	    ServerName demo.first
	    ServerAlias moodle.demo.first
	    DocumentRoot /var/www/html/moodle
	    <Directory “/var/www/html/moodle”>
		    AllowOverride All
		    Options -Indexes +FollowSymLinks
	    </Directory>
    </VirtualHost>

> ServerName - доменное имя сайта
> 
> ServerAlias - доп. Имя по которому доступен сайт
> 
> DocumentRoot - путь к локальной директории с файлами сайта
> 
> Directory “...” - блок с настройками для директории
> 
> AllowOverride  All - настройки из файла .htaccess  могут
> перезаписывать настройки выше
> 
> Options -Indexes +FollowSymLinks - если каталог является символьной
> ссылкой (ярлыком), необходимо перейти по его ссылке.

Создаём символьную ссылку (ярлык) из sites-available на sites-enabled:

    ln -s /etc/httpd2/conf/sites-available/moodle.conf /etc/httpd2/conf/sites-enabled/

Проверяем синтаксис:

    apachectl configtest

Изменяем настройки php.ini. Изменяем количество входных переменных, которые могут быть приняты в одном запросе, вместо 1000, ставим 5000. Это необходимо для корректной работы Moodle:

    sed -i "s/; max_input_vars = 1000/max_input_vars = 5000/g" /etc/php/8.0/apache2-mod_php/php.ini

Проверяем синтаксис:

    systemctl restart httpd2


## НАСТРОЙКА MOODLE

Переходим на систему, на которой есть визуальный интерфейс, не консоль. Для удобства укажем доменное имя, вместо ip  в файле hosts:

    echo 192.168.200.1 moodle.demo.first moodle >> /etc/hosts

Заходим в браузер, в поисковой строке вводим домен moodle.demo.first, откроется сайт Moodle  с установкой. Выбираем Русский язык и нажимаем Далее:

![image](https://github.com/fuccowf/demoexam/assets/51357017/b2b4e42c-81e8-49ad-a70c-2c988f986ac1)

Изменяем каталог данных на созданный нами каталог:

![image](https://github.com/fuccowf/demoexam/assets/51357017/02c691e6-63b1-4c2e-ab9b-d3a21e7af0ee)

Выбираем базу данных Усовершенствованный MySQL  и нажимаем Далее:

![image](https://github.com/fuccowf/demoexam/assets/51357017/d0ab26fc-e3e4-4a3e-9e61-5a57c5153293)

Вводим данные для подключения к базе данных, которую мы создавали ранее:

![image](https://github.com/fuccowf/demoexam/assets/51357017/788a4d87-2338-4662-85cb-2c65acef470c)

Соглашаемся с условиями, нажимая Продолжить:

![image](https://github.com/fuccowf/demoexam/assets/51357017/87cec79c-7a65-490d-ab1d-646f3455884e)

На этом этапе система Moodle  проверяет настройку Систему: зависимости, подскажет рекомендации по улучшению системы. На этом этапе не должно возникнуть проблем. Если выдает ошибку по каким-либо зависимостям, необходимо проверить установку php-модулей в начале:

![image](https://github.com/fuccowf/demoexam/assets/51357017/58046dbc-c397-4b99-8f6a-045ef9531c17)

На след. странице необходимо создать учетную запись администратора и внизу страницы нажимаем Обновить Профиль:

![image](https://github.com/fuccowf/demoexam/assets/51357017/e12f0303-1add-431f-8ffa-18e88abd4242)

По заданию необходимо указать в названии сайта Номер места, внизу нажимаем Сохранить изменения:

![image](https://github.com/fuccowf/demoexam/assets/51357017/c42f9162-93cf-4884-996d-001d296e1242)

На этом установка LMS  Moodle  на веб-сервер Apache2 окончена.

## ДОБАВЛЕНИЕ ГЛОБАЛЬНОЙ ГРУППЫ В MOODLE

Переходим во вкладку Администрирование:

![image](https://github.com/fuccowf/demoexam/assets/51357017/4279b60a-bf22-4125-a147-827d3d67f81a)

Выбираем Пользователи - выбираем Глобальные группы:

![image](https://github.com/fuccowf/demoexam/assets/51357017/36f88111-1d84-4512-a5fb-7b30bac24928)

Нажимаем Добавить глобальную группу:

![image](https://github.com/fuccowf/demoexam/assets/51357017/d76a95c5-f4a9-4553-af65-e6ed1de7526f)

Указываем название группы в соответствии с заданием. Подобным образом создаем остальные группы (Admin,Manager,Team,WS):

![image](https://github.com/fuccowf/demoexam/assets/51357017/55f979d0-fb11-45d5-92ff-d9614b6d6c7d)

## ДОБАВЛЕНИЕ ПОЛЬЗОВАТЕЛЕЙ В MOODLE

Возвращаемся на вкладку Администрирование. Нажимаем Список пользователей:

![image](https://github.com/fuccowf/demoexam/assets/51357017/b1598cf1-07fc-4549-9c1c-3cb355cc0426)

Нажимаем Добавить пользователя:

![image](https://github.com/fuccowf/demoexam/assets/51357017/1cda98f5-1927-403d-86d5-a8857dca585c)

Указываем данные пользователя и внизу нажимаем создать. Создаем подобным образом несколько учетных записей, в соответствии с заданием:

![image](https://github.com/fuccowf/demoexam/assets/51357017/46faed99-ae44-4465-87b6-9274168c9e61)

## ДОБАВЛЕНИЕ ПОЛЬЗОВАТЕЛЕЙ В ГРУППЫ В MOODLE

Во вкладке Глобальные группы, где мы создавали группы, нажимаем на шестеренку напротив нужной группы и выбираем Назначить:

![image](https://github.com/fuccowf/demoexam/assets/51357017/2b89a09d-f328-4139-a0e3-56be08db4df7)

Откроется окно выбранной группы. Слева текущие участники, справа все пользователи. Выбираем справа пользователя, которого необходимо добавить в группу и нажимаем кнопку Добавить по середине:

![image](https://github.com/fuccowf/demoexam/assets/51357017/9c66021c-d775-4cf6-bc0d-66f63e1a47e2)

## УСТАНОВКА И ИСПОЛЬЗОВАНИЕ DOCKER-КОНТЕЙНЕРОВ

**Контейнеризация** - метод виртуализации, при котором ядро ОС поддерживает несколько изолированных друг от друга пространства, так называемые контейнеры. Каждый контейнер полностью изолирован друг от друга и не может взаимодействовать с другими. Каждый контейнер представляет собой отдельный образ ОС, в который можно внести любые настройки: установка пакетов, программ, настройки на уровне ядра. Это позволяет не настраивать каждый раз сервис на каждой системе, лишь развернуть контейнер, в котором уже будут настроены все зависимости и настройки ОС.

**Docker** - ПО для работы с подобными контейнерами. Позволяет упаковать приложение со всем его окружением и зависимостями в контейнер. Может использоваться на любой Linux-системе. Так же может использоваться на Windows, но используя WSL (Windows  Subsystem  for  Linux).

**Docker-compose** - надстройка над докером, написанная на Python, которая позволяет запускать множество контейнеров одновременно и маршрутизировать потоки данных между ними (создавать кластеры). Выше было написано, что контейнеры никак не могут взаимодействовать между собой, Docker-compose  позволяет это сделать.

Устанавливаем docker, docker-compose (в Alt  Linux  пакет docker  называется docker-ce):

    apt-get install -y docker-{ce,compose}

Проверяем установку docker:

    docker --version

Проверяем установку docker-compose:

    docker-compose --version

Включаем и добавляем в автозагрузку:

    systemctl enable --now docker.service




## УСТАНОВКА И ИСПОЛЬЗОВАНИЕ MEDIAWIKI ЧЕРЕЗ DOCKER

Создаем docker-файл в директории /opt, в котором будут описаны настройки контейнеров. В нашем случае, будет 2 контейнера - MediaWiki  и MySQL:

    nano /opt/wiki.yml
   В файле:

    version: “3”
    services:
	    MediaWiki:
		    container_name: wiki
		    image: mediawiki
		    restart: always
		    ports:
		    - 22080:80
		    links:
		    - database
		    volumes:
		    - images:/var/www/html/images
		    # - ./LocalSettings.php:/var/www/html/LocalSettings.php
	    database:
		    container_name: db
		    image: mysql
		    restart: always
		    environment:
			    MYSQL_DATABASE: mediawiki
			    MYSQL_USER: wiki
			    MYSQL_PASSWORD: P@ssw0rd
			    MYSQL_RANDOM_ROOT_PASSWORD: ‘yes’
		    volumes:
			    - dbvolume:/var/lib/mysql
    volumes:
	    images:
	    dbvolume:
	    external: true

> **!!!ВНИМАТЕЛЬНО СОБЛЮДАЕМ ТАБУЛЯЦИЮ!!!**
> 
> Version - указываем версию спецификации Docker  Compose, используемую
> в файле
> 
> Services - основной раздел, где будут описываться сервисы (контейнеры
> docker). В нашем случае: mediawiki  и database (медиа вики и база
> данных, соответственно)
> 
> Container_name - имя, которое получит созданный контейнер
> 
> Image - имя образа, который будет использоваться для создания
> контейнера
> 
> Restart - задаем поведение контейнера при падении. В случае Always 
> будет автоматически перезапускаться в случае остановки контейнера.
> 
> Ports - с помощью данной опции мы указываем на каких портах должен
> слушать контейнер и на какие порты должен пробрасывать запросы. То
> есть 22080 - внешний порт хоста, на котором запущен контейнер, а 80 -
> порт внутри контейнера, на котором будет работать mediawiki. Чтобы
> зайти на страницу mediawiki через браузер, мы будем использовать
> именно порт 22080
> ([https://localhost:22080](https://localhost:22080)). Можно выбрать
> любой другой порт, в данном случае был выбран 22080, так как 8080 был
> уже занят. Если при запуске контейнера выдает ошибку bind: address 
> already  in  use, то необходимо изменить порт на другой.
> 
> Environment - задаем переменные окружения (MYSQL  переменные)
> 
> Volumes - монтирование томов. Указываем название тома и куда он будет
> смонтирован /var/www/html/images. Что позволяет изображения,
> загруженные в MediaWiki  хранить на хост-машине.
> 
> LocalSettings.php - закомментированная строка, которая будет
> использоваться после установка MediaWiki. После установки самой Вики,
> автоматически скачается файл LocalSettings.php, в котором будут
> настройки. Только после этого мы раскомментируем строчку и будем
> использовать настройки из этого файл. Пока оставляем как есть.
> 
> Links - ссылка на другой контейнер (в нашем случае база данных MySQL)
> 
> Volume: images - определение тома с именем images
> 
> Dbvolume - определение тома с именем dbvolume.
> 
> External: true - том dbvolume  объявлен как внешний, это означает, что
> том будет создан и управляться внешним инструментом, например,
> инструментом управления хранилищем.

Создаем вручную том для базы данных, так как автоматически он может создаться некорректно:

    docker volume create dbvolume

Выполняем сборку и запуск стека контейнеров с приложением MediaWiki  и базой данных, описанных в файле wiki.yml:

    docker-compose -f wiki.yml up -d

> -f  /opt/wiki.yml - указываем путь к файлу, содержащий конфигурацию. Можно сразу перейти в /opt  и не использовать флаг -f, тогда
> docker-compose  будет искать файл в текущей директории.
> 
> Up - команда, запускающая контейнеры
> 
> -d  - запускает контейнеры в фоновом режиме, что позволяет им продолжить работу после выполнения команды.

Проверяем запущенные контейнеры:

    docker ps

![image](https://github.com/fuccowf/demoexam/assets/51357017/7645fb5c-2b69-4292-ad46-9f8eb70554f9)

Проверяем созданный том для контейнеров:

    docker volume ls

Если MediaWiki  разворачивается на системе с визуальным интерфейсом, то следующий шаг пропускаем. В случае если на системе нет интерфейса, только терминал, то необходимо зайти на системе с интерфейсом в браузер. В поисковой строке вводим IP  или доменной имя, если было назначено с внешним портом (192.168.1.100:22080 или hq-srv.hq.work:22080). Для удобства можно указать в локальной файле hosts доменное имя, не затрагивая DNS  сервер:

    echo 192.168.1.100 mediawiki.demo.first mediawiki >> /etc/hosts

Переходим в браузер и вводим в поисковую строку [https://mediawiki.demo.first:22080](https://mediawiki.demo.first:22080) или другой порт, который был указан в настройках. Сначала мы выполняем установку и базовую настройку медиа Вики, по итогу, который платформу создаст файл LocalSettings.php со всеми настройками. Нажимаем на set  up  the  wiki.:

![image](https://github.com/fuccowf/demoexam/assets/51357017/a720d3f2-137c-435e-b4fd-ab99672f8b6b)

Выбираем Русский Язык и нажимаем Далее:

![image](https://github.com/fuccowf/demoexam/assets/51357017/8468f7a7-91d3-4230-852e-32dc52773687)

Система проверит все зависимости и должна писать зеленым, что можно установить МедиаВики. Нажимаем Далее:

![image](https://github.com/fuccowf/demoexam/assets/51357017/a34eb1cc-1d4a-4084-ad71-5efba86ddc0a)

Заполняем данные для подключения к базе данных, которые были прописаны в файле wiki.yml (хост БД - bd, имя БД - mediawiki, имя пользователя - wiki, пароль - P@ssw0rd):

![image](https://github.com/fuccowf/demoexam/assets/51357017/6ca74e80-1671-487d-be75-e62f3d70a66d)

Нажимаем Далее:

![image](https://github.com/fuccowf/demoexam/assets/51357017/d85feabb-4c0f-4975-9886-f48f2b883866)

Заполняем данные Админской учетки, отмечаем внизу Хватит, установить вики и нажимаем Далее:

![image](https://github.com/fuccowf/demoexam/assets/51357017/6c3cbb67-e725-4012-883d-8ea41ad3d7f2)

![image](https://github.com/fuccowf/demoexam/assets/51357017/9404e812-ceac-4a47-b1f0-c0888003b174)

![image](https://github.com/fuccowf/demoexam/assets/51357017/21e28fe5-b6fc-4be4-9c13-38819d0d522f)

![image](https://github.com/fuccowf/demoexam/assets/51357017/e6fe166c-6003-4a18-9bd2-11cc0295e26a)

На финальном этапе будет автоматически установлен файл LocalSettings.php, в котором сохранены все базовые настройки:

![image](https://github.com/fuccowf/demoexam/assets/51357017/aabf6e33-9040-4e53-a82d-c519b474ebf7)

Если сервер с MediaWiki  не имеет визуального интерфейса и визуальная настройка производилась на другом сервере, то необходимо перекинуть файл на наш сервер. Используем для этого scp.

Если имеет интерфейс и файл был сразу скачан на наш сервер, то пропускаем шаг.

Забрать файл с удаленного хоста из папки Загрузки, куда автоматически скачается:

    scp USER@IP-ADDRESS:~/Загрузки/LocalSettings.php ./

> USER@IP-ADDRESS - синтаксис как при подключении по SSH, так как
> работает scp (Secure  Copy  Command) именно по протоколу SSH.
> 
> :~/Загрузки/LocalSettings.php - указываем путь к файлу на удаленном
> хосте, не забываем про двоеточие после данных подключения выше
> 
> ./ - локальный путь, куда будет сохранен файл с удаленного хоста

Если есть необходимость передать файл с локальной машины на удаленный хост, то используем:

    scp ~/Загрузки/LocalSettings.php USER@IP-ADDRESS:/tmp

> ~/Загрузки/LocalSettings.php - путь к файлу на локальной машине
> 
> USER@IP-ADDRESS - данные для подключения к удаленному хосту
> 
> :/tmp  - папка, куда будет сохранен локальный файл на удаленном хосте,
> не забываем про двоеточие после данных подключения выше

Переносим файл LocalSettings.php в папку с docker-файлом wiki.yml:

    mv ~/Загрузки/LocalSettings.php /opt

Открываем файл wiki.yml:

    nano /opt/wiki.yml

Раскомментируем строчку:

    - ./LocalSettings.php:/var/www/html/LocalSettings.php

Останавливаем контейнер:

    docker-compose -f wiki.yml stop
Запускаем контейнер:

    docker-compose -f wiki.yml up -d

Проверяем контейнер:

    docker ps

![image](https://github.com/fuccowf/demoexam/assets/51357017/093a3f37-7560-4ef6-a734-704f1fa37b0c)

Снова заходим через браузер на МедиаВики. Теперь отобразится заглавная страница и нажимаем Войти.

![image](https://github.com/fuccowf/demoexam/assets/51357017/d513f304-ea2f-473d-80f7-ca4c756f6f34)

Нажимаем Войти, вводим данные:

![image](https://github.com/fuccowf/demoexam/assets/51357017/6c6a93cb-7941-4c0f-9da1-26abf393669b)

Установка МедиаВики завершена.
