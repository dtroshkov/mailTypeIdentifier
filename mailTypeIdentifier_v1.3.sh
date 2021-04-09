#!/bin/bash
#Устанавливаем цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

function ExchangeSearcher {
	Protocols=('http' 'https')
	SubDomains=('mail' 'owa' 'mx' 'web' 'exchange' 'outlook')
	SuccessStatusCodes=(401 200 302)
	TimeoutSec=3
	ResReceived=1
	ExchangeHelper="\nВ поле «Имя пользователя» нужно указать через обратный слэш: домен рабочей сети \ имя пользователя компьютера.\nЧаще всего клиенты знают его сами, но бывает, что нет. Тогда помогаем его определить по\nинструкции: https://huntflow.ru/help/knowledge-base/domain-login/ или просим узнать у их IT-специалистов.\n\nПри подключении почты для проверки корректности вводимого пароля нужно вставить адрес сервера в браузере, чтобы открылось окно авторизации и ввести в нём почту и пароль. Если получится войти, то пароль верный.\n"
	
	for proto in "${Protocols[@]}"
		do
			for sub in "${SubDomains[@]}"
				do
					url="$proto://$sub.$DomainName/EWS/Exchange.asmx"
					resStatus=$(curl -LIs -m $TimeoutSec -o /dev/null -w '%{http_code}\n' $url)	
					if [[ " ${SuccessStatusCodes[@]} " =~ " ${resStatus} " ]]; then
						echo -e ${GREEN}$url — "OK!"${NC}
						ResReceived=0 
					else
						echo -e ${RED}$url — "Ошибка!"${NC}
					fi
				done
		done
	if [ "$ResReceived" -eq "0" ]; then
		echo -e "${GREEN}$ExchangeHelper${NC}"
	else
		echo -e "\n${RED}Ошибка! У пользователя другой тип почты.${NC}\n"
	fi
}
function MailDefiner {
	printf 'Введите почту клиента:'
	read ClientMail
	DomainName=$( echo $ClientMail |  egrep -o '\w+\.\w{2,3}$')
	if [ -n "$DomainName" ]; then
		echo -e "Почтовый домен: $DomainName, начинаем проверку..." 
		MxRecord=$(dig @8.8.8.8 $DomainName mx +short)
		if [ -n "$MxRecord" ]; then
			case $MxRecord in
				*"google.com"*)
					echo -e "У клиента почта от ${GREEN}Google${NC} «Добавить почту» → Google»\n";;
				*"mail.ru"*)
					echo -e "у клиента почта ${GREEN}mail.ru${NC} «Добавить почту» →  Другая почта\nТип входящей почты — Imap\nСервер входящей почты—imap.mail.ru→ порт 993\nСервер исходящей почты — smtp.mail.ru→  порт 465\nОбязательно поставьте обе галочки на «Безопасное соединение» и сохраните.\n";;
				*"yandex"*)
					echo -e "У клиента почта от ${GREEN}yandex${NC} «Добавить почту» → Другая почта\nСервер входящей почты — imap.yandex.ru, порт 993\nСервер исходящей почты — smtp.yandex.ru, порт 465\nПоставить обе галочки на «Безопасное соединение» и сохраните.\n";;
				*"outlook.com"*)
					echo -e "У клиента ${GREEN}облачный Аутлук${NC} «Добавить почту» → Outlook 365 → Разрешить доступ\nПочтовый сервер (поле «Адрес сервера») для всех клиентов с таким типом почты:\nhttps://outlook.office365.com/EWS/Exchange.asmx\nВ поле «Имя пользователя» вводится повторно адрес почты.\n";;
				*)
				echo -e "Стандартные типы серверов не подошли\nВозможно у клиента Exchange — проверяем..\n"
				ExchangeSearcher
			esac
		else
			echo -e "${RED}Ошибка в MX запросе!${NC}"
		fi
	else
		echo -e "${RED}Ошибка в имени домена!${NC}"
	fi
	read -r -p "Continue? [y/N] " response
	if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
	then
		MailDefiner
	else
		exit
	fi
}
MailDefiner

