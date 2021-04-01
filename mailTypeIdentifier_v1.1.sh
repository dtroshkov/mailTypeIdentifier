#!/bin/bash
#Устанавливаем цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

function ExchangeSearcher {
	echo -e "Возможно у клиента Exchange — проверяем..\n"
	SubDomains=('mail' 'owa' 'mx' 'web' 'exchange' 'outlook')
	SuccessStatusCodes=(401 200)
	TimeoutSec=3
	ExchangeHelper="\n\nВ поле «Имя пользователя» нужно указать через обратный слэш: домен рабочей сети \ имя пользователя компьютера.\nЧаще всего клиенты знают его сами, но бывает, что нет. Тогда помогаем его определить по\nинструкции: https://huntflow.ru/help/knowledge-base/domain-login/ или просим узнать у их IT-специалистов."
	
	for sub in "${SubDomains[@]}"
		do
			url="https://$sub.$DomainName/EWS/Exchange.asmx"
			resStatus=$(curl -LIs -m $TimeoutSec -o /dev/null -w '%{http_code}\n' $url)
				
			if [[ " ${SuccessStatusCodes[@]} " =~ " ${resStatus} " ]] ; then
					echo -e ${GREEN}$url — "OK!" ${NC} $ExchangeHelper
					exit 
			else
					echo -e ${RED}$url — "Ошибка!"${NC}
			fi
		done
	echo -e "\n${RED}Ошибка! У пользователя другой тип почты.${NC}\n"
}
function MailDefiner {
	printf 'Введите почтовый домен клиента:'
	read DomainName
	MxRecord=$(dig @8.8.8.8 $DomainName mx +short)
	if [[ -n  $MxRecord ]] #Проверяем, что строка не пустая
	then
		echo -e "Почтовый домен: $DomainName, начинаем проверку...\n" 
		case $MxRecord in
			*"google.com"*)
				echo -e "У клиента почта от ${GREEN}Google${NC} «Добавить почту» → Google»\n"
				;;
			*"mail.ru"*)
				echo -e "у клиента почта ${GREEN}mail.ru${NC} «Добавить почту» →  Другая почта\nТип входящей почты — Imap\nСервер входящей почты—imap.mail.ru→ порт 993\nСервер исходящей почты — smtp.mail.ru→  порт 465\nОбязательно поставьте обе галочки на «Безопасное соединение» и сохраните.\n"
				;;
			*"yandex"*)
				echo -e "У клиента почта от ${GREEN}yandex${NC} «Добавить почту» → Другая почта\nСервер входящей почты — imap.yandex.ru, порт 993\nСервер исходящей почты — smtp.yandex.ru, порт 465\nПоставить обе галочки на «Безопасное соединение» и сохраните.\n"
				;;
			*"outlook.com"*)
				echo -e "У клиента ${GREEN}облачный Аутлук${NC} «Добавить почту» → Outlook 365 → Разрешить доступ\nПочтовый сервер (поле «Адрес сервера») для всех клиентов с таким типом почты:\nhttps://outlook.office365.com/EWS/Exchange.asmx\nВ поле «Имя пользователя» вводится повторно адрес почты.\n"
				;;
			*)
				echo "Стандартные типы серверов не подошли"
				ExchangeSearcher
				;;
		esac
	else
	echo -e "${RED}Ошибка! Не удалось получить доступ к сайту: $DomainName ${NC}\n"
	fi
}

MailDefiner

