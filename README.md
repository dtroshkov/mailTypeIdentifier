# mailTypeIdentifier

mailTypeIdentifier — скрипт, определяющий принадлежность домена к определнному почтовому серверу.
Может определять принадлежность для таких почтовых серверов, как: (Google, Yandex, Mail.ru, Outlook, Exchange)

## Принцип работы

Принцип работы построен на утилитах командной строки **_dig_** и **_curl_**:

1. Скрипт с помощью утилиты dig делает запрос на dns сервер 8.8.8.8 (Google), затем парсит из ответа список MX записей.
2. Скрипт сравнивает содержимое MX записей с внутренним списком, и при совпадении выводит сообщение в Console.
3. Если в MX отсутствуют записи, соответствующие серверам: Google, Yandex, Mail.ru, Outlook, скрипт запускает функцию «ExchangeSearcher».
4. Функция «ExchangeSearcher» по списку отправляет curl запрос на возможный url для входа в Exchange и ждет httpResponseCode
5. Если httpResponseCode = 200 или 401 → выводим url адрес входа в Console.

## Запуск в Windows

Запуск происходит из **PowerShell**, по этому должна быть установлена версия не ниже **5.1**.
По-умолчанию настройки Windows запрещают запуск скриптов PowerShell, по этому перед использованием необходимо запустить **PowerShell** и ввести **_Set-ExecutionPolicy Unrestricted_**
Загрузить файл **mailTypeIdentifier_v1.1.ps1**
Нажать правой кнопкой мыши по файлу → **Выполнить с помощью PowerShell**

## Запуск в Linux и MacOS

Откройте Терминал. Используйте команду cd для перемещения в папку, в которой находится скрипт.
Как только вы попали в папку, вам нужно дать разрешение на запуск скрипта.
Используйте для этого команду **_chmod +x mailTypeIdentifier_v1.1.sh_**
После предоставления разрешения на выполнение сценария запускаем скрипт командой:
**_sh mailTypeIdentifier_v1.1.sh_** — для MacOS
**_./mailTypeIdentifier_v1.1.sh_** — для Linux
