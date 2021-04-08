add-type @"
      using System.Net;
      using System.Security.Cryptography.X509Certificates;
      public class TrustAllCertsPolicy : ICertificatePolicy {
          public bool CheckValidationResult(
              ServicePoint srvPoint, X509Certificate certificate,
              WebRequest request, int certificateProblem) {
              return true;
          }
      }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

function ExchangeSearcher {
  $SubDomains = 'mail', 'owa', 'mx', 'web', 'exchange', 'outlook'
  $SuccessStatusCodes = '401', '200'
  $TimeoutSec = 3
  $ExchangeHelper = "`n`nВ поле «Имя пользователя» нужно указать через обратный слэш: домен рабочей сети \ имя пользователя компьютера.`nЧаще всего клиенты знают его сами, но бывает, что нет. Тогда помогаем его определить по`nинструкции: https://huntflow.ru/help/knowledge-base/domain-login/ или просим узнать у их IT-специалистов.`n`nПри подключении почты для проверки корректности вводимого пароля нужно вставить адрес сервера в браузере, чтобы открылось окно авторизации и ввести в нём почту и пароль. Если получится войти, то пароль верный."

  foreach ( $sub in $SubDomains ) {
    $url = "$sub.$DomainName/EWS/Exchange.asmx"
    try {
      $Response = Invoke-WebRequest -Uri $url -TimeoutSec $TimeoutSec -MaximumRedirection 0
      $StatusCode = $Response.StatusCode
    }
    catch {
      $StatusCode = $_.Exception.Response.StatusCode.value__
    }
    if ($StatusCode -in $SuccessStatusCodes ) {
      Write-Host $url — "OK!" $ExchangeHelper -ForegroundColor green
      return
    }
    else {
      Write-Host $url — "Ошибка!" -ForegroundColor red
    }
  }
  write-host "`nОшибка! У пользователя другой тип почты." -ForegroundColor red
}
function MailDefiner {
  try {
    $ClientMail = Read-Host "Введите почту клиента:" | Select-String -Pattern '\w+\.\w{2,3}$'
    $DomainName = $ClientMail.Matches[0]
    Write-Host "Почтовый домен: $DomainName, начинаем проверку...`n"
    $MxRecord = Out-String -InputObject $(Resolve-DnsName -Name $DomainName -Type MX -Server 8.8.8.8 -ErrorAction Stop).NameExchange

    switch -wildcard ($MxRecord) {
      "*google.com*" { Write-Host  "У клиента почта от Google. «Добавить почту» → Google»`n" -ForegroundColor green }
      "*mail.ru*" { Write-Host "У клиента почта mail.ru. «Добавить почту» → Другая почта`nТип входящей почты — Imap`nервер входящей почты — imap.mail.ru → порт 993`nСервер исходящей почты — smtp.mail.ru → порт 465`nОбязательно поставьте обе галочки на «Безопасное соединение» и сохраните.`n" -ForegroundColor green }
      "*yandex*" { Write-Host "У клиента почта от yandex. «Добавить почту» → Другая почта`nСервер входящей почты — imap.yandex.ru, порт 993`nСервер исходящей почты — smtp.yandex.ru, порт 465`nПоставить обе галочки на «Безопасное соединение» и сохраните.`n" -ForegroundColor green }
      "*outlook.com*" { Write-Host "У клиента облачный Аутлук. «Добавить почту» → Outlook 365 → Разрешить доступ`nПочтовый сервер (поле «Адрес сервера») для всех клиентов с таким типом почты: https://outlook.office365.com/EWS/Exchange.asmx`nВ поле Имя пользователя вводится повторно адрес почты.`n" -ForegroundColor green }
      default {
        Write-Host "Стандартные типы серверов не подошли"
        Write-Host "Возможно у клиента Exchange — проверяем..`n"
        ExchangeSearcher
      }
    }
  }
  catch {
    #$PSCmdlet.ThrowTerminatingError($PSItem)
    Write-Host Ошибка! Имя домена → $_.Exception.Message -ForegroundColor Red
  }
  # Write-Host  "`nPress any key to continue..."
  # $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}

MailDefiner
write-host -nonewline "`nContinue? (Y/N) "
$response = read-host
if ( $response -ne "Y" ) { exit } else { MailDefiner }